import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Chat>> getChats() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];
    final participantData = await _supabase
        .from('chat_participants')
        .select('chat_id')
        .eq('user_id', user.id);
    final chatIds = participantData.map((e) => e['chat_id'] as String).toList();
    if (chatIds.isEmpty) return [];
    final chatsData = await _supabase
        .from('chats')
        .select('*, messages(*)')
        .in_('id', chatIds)
        .order('updated_at', ascending: false);
    return chatsData.map((json) => Chat.fromJson(json)).toList();
  }

  Future<Chat> getChat(String chatId) async {
    final data = await _supabase
        .from('chats')
        .select('*, messages(*)')
        .eq('id', chatId)
        .single();
    return Chat.fromJson(data);
  }

  Future<Chat> createPrivateChat(String userId) async {
    final currentUser = _supabase.auth.currentUser!;
    final chatData = {
      'type': 'private',
      'created_by': currentUser.id,
      'participants': [currentUser.id, userId],
    };
    final response = await _supabase.from('chats').insert(chatData).select().single();
    return Chat.fromJson(response);
  }

  Future<void> updateChat(String chatId, Map<String, dynamic> updates) async {
    await _supabase.from('chats').update(updates).eq('id', chatId);
  }

  Future<int> getUnreadCount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;
    // Simple count: total unread messages where user is not in read_by
    final chats = await getChats();
    int count = 0;
    for (var chat in chats) {
      final messages = await _supabase
          .from('messages')
          .select('id')
          .eq('chat_id', chat.id)
          .not('read_by', 'cs', '{"${user.id}"}')
          .count(exact: true);
      count += messages.count ?? 0;
    }
    return count;
  }

  Stream<List<Chat>> watchChats() {
    return _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false);
  }
}