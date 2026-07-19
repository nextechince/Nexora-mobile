import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class BackupService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> createBackup() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backup_${DateTime.now().millisecondsSinceEpoch}');
    await backupDir.create(recursive: true);

    final user = _supabase.auth.currentUser!;
    await _exportData(backupDir.path, user.id);

    final zipPath = '${directory.path}/nexora_backup_${DateTime.now().millisecondsSinceEpoch}.zip';
    await ZipFile.createFromDirectory(sourceDir: backupDir, zipFile: File(zipPath), includeHiddenFiles: false);
    await backupDir.delete(recursive: true);
    return zipPath;
  }

  Future<void> _exportData(String path, String userId) async {
    final userData = await _supabase.from('users').select().eq('id', userId).single();
    await File('$path/profile.json').writeAsString(jsonEncode(userData));

    final participantData = await _supabase
        .from('chat_participants')
        .select('chat_id')
        .eq('user_id', userId);
    final chatIds = participantData.map((e) => e['chat_id'] as String).toList();
    if (chatIds.isNotEmpty) {
      final chats = await _supabase.from('chats').select().in_('id', chatIds);
      await File('$path/chats.json').writeAsString(jsonEncode(chats));
      final messages = await _supabase.from('messages').select().in_('chat_id', chatIds);
      await File('$path/messages.json').writeAsString(jsonEncode(messages));
    }

    final settings = await _supabase
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (settings != null) {
      await File('$path/settings.json').writeAsString(jsonEncode(settings));
    }
  }

  Future<void> restoreBackup(String zipPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final tempDir = Directory('${directory.path}/temp_restore');
    await tempDir.create();
    await ZipFile.extractToDirectory(zipFile: File(zipPath), destinationDir: tempDir);

    final profileFile = File('${tempDir.path}/profile.json');
    if (await profileFile.exists()) {
      final profileData = jsonDecode(await profileFile.readAsString());
      await _restoreProfile(profileData);
    }

    final chatsFile = File('${tempDir.path}/chats.json');
    if (await chatsFile.exists()) {
      final chatsData = jsonDecode(await chatsFile.readAsString());
      await _restoreChats(chatsData);
    }
    await tempDir.delete(recursive: true);
  }

  Future<void> _restoreProfile(Map<String, dynamic> data) async {
    final user = _supabase.auth.currentUser!;
    await _supabase.from('users').update(data).eq('id', user.id);
  }

  Future<void> _restoreChats(List<Map<String, dynamic>> chats) async {
    // Implementation for chat restoration
  }

  Future<void> scheduleBackup({
    required String interval,
    required bool autoBackup,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backup_interval', interval);
    await prefs.setBool('auto_backup', autoBackup);
  }

  Future<Map<String, dynamic>> getBackupSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'interval': prefs.getString('backup_interval') ?? 'weekly',
      'auto_backup': prefs.getBool('auto_backup') ?? false,
      'last_backup': prefs.getString('last_backup'),
    };
  }

  Future<List<File>> getExistingBackups() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = await directory.list()
        .where((file) => file.path.endsWith('.zip') && file.path.contains('nexora_backup'))
        .toList();
    return files.cast<File>();
  }

  Future<void> deleteOldBackups(int keepCount) async {
    final backups = await getExistingBackups();
    if (backups.length > keepCount) {
      final sorted = backups..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      for (var i = keepCount; i < sorted.length; i++) {
        await sorted[i].delete();
      }
    }
  }
}