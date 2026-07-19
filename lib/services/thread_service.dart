import 'package:supabase_flutter/supabase_flutter.dart';

class ThreadService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createThreadReply({
    required String parentMessageId,
    required String chatId,
    required String content,
    required String senderId,
  }) async {
    await _supabase.from('messages').insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'reply_to_id': parentMessageId,
      'is_thread_reply': true,
      'sent_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getThreadMessages(String parentMessageId) async {
    final data = await _supabase
        .from('messages')
        .select('*, users!sender_id(*)')
        .eq('reply_to_id', parentMessageId)
        .eq('is_thread_reply', true)
        .order('sent_at', ascending: true);
    return data;
  }

  Future<int> getThreadCount(String parentMessageId) async {
    final data = await _supabase
        .from('messages')
        .select('id', count: 'exact')
        .eq('reply_to_id', parentMessageId)
        .eq('is_thread_reply', true);
    return data.count ?? 0;
  }

  Stream<List<Map<String, dynamic>>> watchThread(String parentMessageId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('reply_to_id', parentMessageId)
        .eq('is_thread_reply', true)
        .order('sent_at', ascending: true);
  }

  Future<void> deleteThreadReply(String messageId) async {
    await _supabase.from('messages').delete().eq('id', messageId);
  }

  Future<void> editThreadReply(String messageId, String newContent) async {
    await _supabase
        .from('messages')
        .update({'content': newContent, 'is_edited': true})
        .eq('id', messageId);
  }
}