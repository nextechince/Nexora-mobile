import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/story_model.dart';

class StoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Story>> getStories() async {
    final user = _supabase.auth.currentUser!;
    final data = await _supabase
        .from('stories')
        .select('*, users(*)')
        .gte('expires_at', DateTime.now().toIso8601String())
        .order('created_at', ascending: false);
    return data.map((json) => Story.fromJson(json)).toList();
  }

  Future<Story> createStory({
    required String mediaUrl,
    required String type,
    String? caption,
    int? duration,
  }) async {
    final user = _supabase.auth.currentUser!;
    final storyData = {
      'user_id': user.id,
      'media_url': mediaUrl,
      'type': type,
      'caption': caption,
      'duration': duration ?? 5,
      'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    };
    final response = await _supabase
        .from('stories')
        .insert(storyData)
        .select()
        .single();
    return Story.fromJson(response);
  }

  Future<void> viewStory(String storyId) async {
    final user = _supabase.auth.currentUser!;
    try {
      await _supabase.from('story_views').insert({
        'story_id': storyId,
        'viewer_id': user.id,
      });
    } catch (_) {}
    await _supabase
        .rpc('increment_story_view', params: {'story_id': storyId});
  }

  Future<void> deleteStory(String storyId) async {
    await _supabase.from('stories').delete().eq('id', storyId);
  }

  Future<void> addReaction(String storyId, String emoji) async {
    final user = _supabase.auth.currentUser!;
    final current = await _supabase
        .from('stories')
        .select('reactions')
        .eq('id', storyId)
        .single();
    Map reactions = current['reactions'] ?? {};
    reactions[emoji] = reactions[emoji] ?? [];
    if (!reactions[emoji].contains(user.id)) {
      reactions[emoji].add(user.id);
    }
    await _supabase
        .from('stories')
        .update({'reactions': reactions})
        .eq('id', storyId);
  }
}