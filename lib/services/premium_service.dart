import 'package:supabase_flutter/supabase_flutter.dart';

class PremiumService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> isPremium() async {
    final user = _supabase.auth.currentUser!;
    final data = await _supabase
        .from('users')
        .select('is_premium, premium_expires_at')
        .eq('id', user.id)
        .single();
    if (data['is_premium'] == true) {
      final expires = DateTime.parse(data['premium_expires_at']);
      return expires.isAfter(DateTime.now());
    }
    return false;
  }

  Future<void> grantPremium(int months) async {
    final user = _supabase.auth.currentUser!;
    final expires = DateTime.now().add(Duration(days: months * 30));
    await _supabase.from('users').update({
      'is_premium': true,
      'premium_expires_at': expires.toIso8601String(),
    }).eq('id', user.id);
  }

  Future<void> revokePremium() async {
    final user = _supabase.auth.currentUser!;
    await _supabase.from('users').update({
      'is_premium': false,
      'premium_expires_at': null,
    }).eq('id', user.id);
  }

  Future<List<String>> getPremiumFeatures() async {
    return [
      'Exclusive Themes',
      'Animated Profile',
      'More Storage (4GB Upload)',
      'Premium Stickers',
      'Premium Emoji',
      'Exclusive Reactions',
      'AI Assistant',
      'Voice To Text',
      'Profile Effects',
      'Custom Wallpapers',
      'Premium Badge',
    ];
  }
}