import 'package:supabase_flutter/supabase_flutter.dart';

class StickerService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getStickerPacks() async {
    final data = await _supabase
        .from('sticker_packs')
        .select('*, stickers(*)')
        .order('is_premium', ascending: true)
        .order('name', ascending: true);
    return data;
  }

  Future<Map<String, dynamic>> getStickerPack(String packId) async {
    final data = await _supabase
        .from('sticker_packs')
        .select('*, stickers(*)')
        .eq('id', packId)
        .single();
    return data;
  }

  Future<void> createStickerPack({
    required String name,
    required List<String> stickerUrls,
    bool isPremium = false,
    String? coverUrl,
  }) async {
    final user = _supabase.auth.currentUser!;
    await _supabase.from('sticker_packs').insert({
      'name': name,
      'creator_id': user.id,
      'is_premium': isPremium,
      'cover_url': coverUrl,
      'stickers': stickerUrls.map((url) => {'url': url}).toList(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> addStickerToCollection(String stickerId) async {
    final user = _supabase.auth.currentUser!;
    await _supabase.from('user_stickers').insert({
      'user_id': user.id,
      'sticker_id': stickerId,
    });
  }

  Future<List<Map<String, dynamic>>> getUserStickers() async {
    final user = _supabase.auth.currentUser!;
    final data = await _supabase
        .from('user_stickers')
        .select('*, stickers(*)')
        .eq('user_id', user.id);
    return data;
  }

  Future<List<Map<String, dynamic>>> searchStickers(String query) async {
    final data = await _supabase
        .from('stickers')
        .select('*, sticker_packs(*)')
        .ilike('name', '%$query%')
        .limit(20);
    return data;
  }

  Future<List<Map<String, dynamic>>> getTrendingStickers() async {
    final data = await _supabase
        .from('stickers')
        .select('*, sticker_packs(*)')
        .order('usage_count', ascending: false)
        .limit(20);
    return data;
  }
}