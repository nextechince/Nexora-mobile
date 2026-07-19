import 'package:supabase_flutter/supabase_flutter.dart';

class ChannelCommentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final user = _supabase.auth.currentUser!;
    await _supabase.from('channel_comments').insert({
      'post_id': postId,
      'user_id': user.id,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final data = await _supabase
        .from('channel_comments')
        .select('*, users!user_id(*)')
        .eq('post_id', postId)
        .order('created_at', ascending: false);
    return data;
  }

  Stream<List<Map<String, dynamic>>> watchComments(String postId) {
    return _supabase
        .from('channel_comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at', ascending: false);
  }

  Future<void> voteComment(String commentId, int vote) async {
    final user = _supabase.auth.currentUser!;
    await _supabase.from('comment_votes').upsert({
      'comment_id': commentId,
      'user_id': user.id,
      'vote': vote,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> getCommentVotes(String commentId) async {
    final data = await _supabase
        .from('comment_votes')
        .select('vote')
        .eq('comment_id', commentId);
    return data.fold(0, (sum, v) => sum + (v['vote'] ?? 0));
  }

  Future<void> pinComment(String commentId) async {
    await _supabase
        .from('channel_comments')
        .update({'is_pinned': true})
        .eq('id', commentId);
  }

  Future<void> deleteComment(String commentId) async {
    await _supabase.from('channel_comments').delete().eq('id', commentId);
  }
}