import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/channel_model.dart';

class ChannelService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Channel>> getChannels() async {
    final user = _supabase.auth.currentUser!;
    final participantData = await _supabase
        .from('chat_participants')
        .select('chat_id')
        .eq('user_id', user.id);
    final chatIds = participantData.map((e) => e['chat_id'] as String).toList();
    if (chatIds.isEmpty) return [];
    final channelsData = await _supabase
        .from('chats')
        .select('*')
        .eq('type', 'channel')
        .in_('id', chatIds);
    return channelsData.map((json) => Channel.fromJson(json)).toList();
  }

  Future<Channel> createChannel({
    required String title,
    required bool isPublic,
    String? description,
    String? photoUrl,
  }) async {
    final user = _supabase.auth.currentUser!;
    final chatData = {
      'type': 'channel',
      'title': title,
      'photo_url': photoUrl,
      'created_by': user.id,
      'channel_settings': {'is_public': isPublic, 'description': description},
    };
    final response = await _supabase
        .from('chats')
        .insert(chatData)
        .select()
        .single();
    return Channel.fromJson(response);
  }

  Future<void> subscribe(String channelId) async {
    final user = _supabase.auth.currentUser!;
    await _supabase.from('chat_participants').insert({
      'chat_id': channelId,
      'user_id': user.id,
      'role': 'member',
    });
  }

  Future<void> unsubscribe(String channelId) async {
    final user = _supabase.auth.currentUser!;
    await _supabase
        .from('chat_participants')
        .delete()
        .match({'chat_id': channelId, 'user_id': user.id});
  }

  Future<void> updateChannel(String channelId, Map<String, dynamic> updates) async {
    await _supabase.from('chats').update(updates).eq('id', channelId);
  }
}