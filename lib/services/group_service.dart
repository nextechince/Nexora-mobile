import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_model.dart';

class GroupService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Group>> getGroups() async {
    final user = _supabase.auth.currentUser!;
    final participantData = await _supabase
        .from('chat_participants')
        .select('chat_id')
        .eq('user_id', user.id);
    final chatIds = participantData.map((e) => e['chat_id'] as String).toList();
    if (chatIds.isEmpty) return [];
    final groupsData = await _supabase
        .from('chats')
        .select('*')
        .eq('type', 'group')
        .in_('id', chatIds);
    return groupsData.map((json) => Group.fromJson(json)).toList();
  }

  Future<Group> createGroup({
    required String title,
    List<String>? memberIds,
    String? photoUrl,
  }) async {
    final user = _supabase.auth.currentUser!;
    final chatData = {
      'type': 'group',
      'title': title,
      'photo_url': photoUrl,
      'created_by': user.id,
    };
    final response = await _supabase
        .from('chats')
        .insert(chatData)
        .select()
        .single();
    final group = Group.fromJson(response);
    final participants = [user.id, ...?memberIds];
    for (final userId in participants) {
      await _supabase.from('chat_participants').insert({
        'chat_id': group.id,
        'user_id': userId,
        'role': userId == user.id ? 'owner' : 'member',
      });
    }
    return group;
  }

  Future<void> addMembers(String groupId, List<String> userIds) async {
    for (final userId in userIds) {
      await _supabase.from('chat_participants').insert({
        'chat_id': groupId,
        'user_id': userId,
        'role': 'member',
      });
    }
  }


Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
  final data = await _supabase
      .from('chat_participants')
      .select('*, users!user_id(*)')
      .eq('chat_id', groupId);
  return data;
}

  Future<void> promoteToAdmin(String groupId, String userId) async {
    await _supabase
        .from('chat_participants')
        .update({'role': 'admin'})
        .match({'chat_id': groupId, 'user_id': userId});
  }

  Future<void> removeMember(String groupId, String userId) async {
    await _supabase
        .from('chat_participants')
        .delete()
        .match({'chat_id': groupId, 'user_id': userId});
  }

  Future<void> updateGroup(String groupId, Map<String, dynamic> updates) async {
    await _supabase.from('chats').update(updates).eq('id', groupId);
  }


Future<void> promoteToModerator(String groupId, String userId) async {
  await _supabase
      .from('chat_participants')
      .update({'role': 'moderator'})
      .match({'chat_id': groupId, 'user_id': userId});
}

Future<void> demoteFromAdmin(String groupId, String userId) async {
  await _supabase
      .from('chat_participants')
      .update({'role': 'member'})
      .match({'chat_id': groupId, 'user_id': userId});
}

Future<void> demoteFromModerator(String groupId, String userId) async {
  await _supabase
      .from('chat_participants')
      .update({'role': 'member'})
      .match({'chat_id': groupId, 'user_id': userId});
}

  Future<void> approveJoinRequest(String groupId, String userId) async {
    await _supabase
        .from('chat_participants')
        .update({'role': 'member'})
        .match({'chat_id': groupId, 'user_id': userId});
  }

  Future<void> declineJoinRequest(String groupId, String userId) async {
    await _supabase
        .from('chat_participants')
        .delete()
        .match({'chat_id': groupId, 'user_id': userId});
  }
}