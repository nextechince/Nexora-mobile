import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> signInWithPhone(String phone) async {
    await _supabase.auth.signInWithOtp(
      phone: phone,
      shouldCreateUser: true,
    );
  }

  Future<User> verifyOTP(String phone, String otp) async {
    final response = await _supabase.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
    final session = response.session;
    if (session == null) throw Exception('Session null');
    await _secureStorage.write(key: 'access_token', value: session.accessToken);
    await _secureStorage.write(key: 'refresh_token', value: session.refreshToken);
    final userData = await _supabase
        .from('users')
        .select()
        .eq('auth_id', response.user!.id)
        .single();
    return User.fromJson(userData);
  }

  Future<User?> getCurrentUser() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;
    final userData = await _supabase
        .from('users')
        .select()
        .eq('auth_id', session.user.id)
        .single();
    return User.fromJson(userData);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    await _secureStorage.deleteAll();
  }

  Future<void> deleteAccount() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await _supabase.auth.admin.deleteUser(user.id);
      await _supabase.from('users').delete().eq('auth_id', user.id);
    }
    await logout();
  }
}