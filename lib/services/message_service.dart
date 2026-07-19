import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class MessageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Message>> getMessages(String chatId) async {
    final data = await _supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('sent_at', ascending: false);
    return data.map((json) => Message.fromJson(json)).toList();
  }

  Future<Message> sendMessage({
    required String chatId,
    required String content,
    String? type,
    List<String>? mediaUrls,
    String? replyToId,
    DateTime? scheduledAt,
  }) async {
    final user = _supabase.auth.currentUser!;
    final messageData = {
      'chat_id': chatId,
      'sender_id': user.id,
      'content': content,
      'type': type ?? 'text',
      'media_urls': mediaUrls ?? [],
      'reply_to_id': replyToId,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'sent_at': DateTime.now().toIso8601String(),
    };
    final response = await _supabase
        .from('messages')
        .insert(messageData)
        .select()
        .single();
    return Message.fromJson(response);
  }

  Future<void> editMessage(String messageId, String newContent) async {
    await _supabase
        .from('messages')
        .update({'content': newContent, 'is_edited': true})
        .eq('id', messageId);
  }

  Future<void> deleteMessage(String messageId) async {
    await _supabase
        .from('messages')
        .update({'is_deleted': true})
        .eq('id', messageId);
  }

  Future<void> addReaction(String messageId, String emoji) async {
    final user = _supabase.auth.currentUser!;
    final current = await _supabase
        .from('messages')
        .select('reactions')
        .eq('id', messageId)
        .single();
    Map reactions = current['reactions'] ?? {};
    reactions[emoji] = reactions[emoji] ?? [];
    if (!reactions[emoji].contains(user.id)) {
      reactions[emoji].add(user.id);
    }
    await _supabase
        .from('messages')
        .update({'reactions': reactions})
        .eq('id', messageId);
  }

  Future<void> markAsRead(String messageId) async {
    final user = _supabase.auth.currentUser!;
    await _supabase
        .from('messages')
        .update({
          'read_by': _supabase.sql('array_append(read_by, ${user.id})'),
        })
        .eq('id', messageId);
  }

  Stream<List<Message>> watchMessages(String chatId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('sent_at', ascending: false);
  }
}