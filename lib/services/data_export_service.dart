import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class DataExportService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> exportAllData() async {
    final user = _supabase.auth.currentUser!;
    final directory = await getTemporaryDirectory();
    final exportDir = Directory('${directory.path}/nexora_export_${DateTime.now().millisecondsSinceEpoch}');
    await exportDir.create(recursive: true);

    // Export user profile
    final userData = await _exportUserProfile(user.id);
    await _saveFile(exportDir.path, 'profile.json', jsonEncode(userData));

    // Export chats
    final chats = await _exportChats(user.id);
    await _saveFile(exportDir.path, 'chats.json', jsonEncode(chats));

    // Export messages
    final messages = await _exportMessages(user.id);
    await _saveFile(exportDir.path, 'messages.json', jsonEncode(messages));

    // Export contacts
    final contacts = await _exportContacts(user.id);
    await _saveFile(exportDir.path, 'contacts.json', jsonEncode(contacts));

    // Export media
    await _exportMedia(exportDir.path, user.id);

    final zipPath = '${directory.path}/nexora_export_${DateTime.now().millisecondsSinceEpoch}.zip';
    await ZipFile.createFromDirectory(sourceDir: exportDir, zipFile: File(zipPath), includeHiddenFiles: false);
    await exportDir.delete(recursive: true);
    return zipPath;
  }

  Future<Map<String, dynamic>> _exportUserProfile(String userId) async {
    final data = await _supabase.from('users').select().eq('id', userId).single();
    return data;
  }

  Future<List<Map<String, dynamic>>> _exportChats(String userId) async {
    final participantData = await _supabase
        .from('chat_participants')
        .select('chat_id')
        .eq('user_id', userId);
    final chatIds = participantData.map((e) => e['chat_id'] as String).toList();
    if (chatIds.isEmpty) return [];
    final chats = await _supabase.from('chats').select().in_('id', chatIds);
    return chats;
  }

  Future<List<Map<String, dynamic>>> _exportMessages(String userId) async {
    final participantData = await _supabase
        .from('chat_participants')
        .select('chat_id')
        .eq('user_id', userId);
    final chatIds = participantData.map((e) => e['chat_id'] as String).toList();
    if (chatIds.isEmpty) return [];
    final messages = await _supabase
        .from('messages')
        .select()
        .in_('chat_id', chatIds)
        .order('sent_at', ascending: true);
    return messages;
  }

  Future<List<Map<String, dynamic>>> _exportContacts(String userId) async {
    final contacts = await _supabase.from('contacts').select().eq('user_id', userId);
    return contacts;
  }

  Future<void> _exportMedia(String exportPath, String userId) async {
    final mediaDir = Directory('$exportPath/media');
    await mediaDir.create();
    // Download media files
  }

  Future<void> _saveFile(String path, String fileName, String content) async {
    final file = File('$path/$fileName');
    await file.writeAsString(content);
  }

  Future<String> exportChatHistory(String chatId) async {
    final messages = await _supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('sent_at', ascending: true);
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/chat_${chatId}_${DateTime.now().millisecondsSinceEpoch}.txt';
    final file = File(filePath);
    final buffer = StringBuffer();
    for (var msg in messages) {
      buffer.writeln('[${DateTime.parse(msg['sent_at']).toString().substring(0, 16)}] ${msg['sender_id']}: ${msg['content']}');
    }
    await file.writeAsString(buffer.toString());
    return filePath;
  }

  Future<String> exportAsHTML(String chatId) async {
    final messages = await _supabase
        .from('messages')
        .select('*, users!sender_id(display_name, username)')
        .eq('chat_id', chatId)
        .order('sent_at', ascending: true);
    final html = '''
    <!DOCTYPE html>
    <html>
    <head><title>Chat Export</title>
    <style>body { font-family: Arial; padding: 20px; background: #1a1a1a; color: white; }
    .message { margin: 10px 0; padding: 10px; border-radius: 8px; background: #2a2a2a; }
    .sender { font-weight: bold; color: #4a9eff; }
    .time { color: #666; font-size: 12px; float: right; }
    </style></head>
    <body>
    ${messages.map((msg) => '''
      <div class="message">
        <span class="sender">${msg['users']['display_name'] ?? msg['users']['username']}</span>
        <span class="time">${DateTime.parse(msg['sent_at']).toString().substring(0, 16)}</span>
        <br>${msg['content']}
      </div>
    ''').join('')}
    </body>
    </html>
    ''';
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/chat_${chatId}_export.html';
    await File(filePath).writeAsString(html);
    return filePath;
  }
}