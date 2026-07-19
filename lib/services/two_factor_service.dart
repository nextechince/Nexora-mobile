import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:totp/totp.dart';

class TwoFactorService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TOTP _totp = TOTP();

  Future<Map<String, dynamic>> enableTwoFactor() async {
    final user = _supabase.auth.currentUser!;
    final secret = _totp.generateSecret();
    final accountName = user.email ?? user.phone ?? 'user';
    final issuer = 'NEXORA CHQT';
    final uri = _totp.generateTOTPURI(accountName, issuer, secret);
    await _supabase.from('user_2fa').insert({
      'user_id': user.id,
      'secret': secret,
      'verified': false,
    });
    return {'secret': secret, 'uri': uri};
  }

  Future<bool> verifyCode(String secret, String code) async {
    return _totp.verifyCode(secret, code);
  }

  Future<void> completeSetup(String code) async {
    final user = _supabase.auth.currentUser!;
    final setup = await _supabase
        .from('user_2fa')
        .select()
        .eq('user_id', user.id)
        .eq('verified', false)
        .single();
    if (await verifyCode(setup['secret'], code)) {
      await _supabase.from('user_2fa').update({
        'verified': true,
        'enabled_at': DateTime.now().toIso8601String(),
      }).eq('user_id', user.id);
      await _generateBackupCodes();
    } else {
      throw Exception('Invalid verification code');
    }
  }

  Future<List<String>> _generateBackupCodes() async {
    final user = _supabase.auth.currentUser!;
    final codes = List.generate(10, (_) => _generateRandomCode());
    await _supabase.from('user_2fa').update({'backup_codes': codes}).eq('user_id', user.id);
    return codes;
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var code = '';
    for (var i = 0; i < 8; i++) {
      code += chars[(random + i) % chars.length];
    }
    return code;
  }

  Future<void> disableTwoFactor(String code) async {
    final user = _supabase.auth.currentUser!;
    final setup = await _supabase
        .from('user_2fa')
        .select()
        .eq('user_id', user.id)
        .eq('verified', true)
        .single();
    if (await verifyCode(setup['secret'], code)) {
      await _supabase.from('user_2fa').delete().eq('user_id', user.id);
    } else {
      throw Exception('Invalid verification code');
    }
  }

  Future<bool> verifyWithBackupCode(String code) async {
    final user = _supabase.auth.currentUser!;
    final setup = await _supabase
        .from('user_2fa')
        .select()
        .eq('user_id', user.id)
        .single();
    final backupCodes = setup['backup_codes'] as List? ?? [];
    if (backupCodes.contains(code)) {
      backupCodes.remove(code);
      await _supabase.from('user_2fa').update({'backup_codes': backupCodes}).eq('user_id', user.id);
      return true;
    }
    return false;
  }

  Future<List<String>> getBackupCodes() async {
    final user = _supabase.auth.currentUser!;
    final setup = await _supabase
        .from('user_2fa')
        .select()
        .eq('user_id', user.id)
        .single();
    return (setup['backup_codes'] as List? ?? []).cast<String>();
  }

  Future<List<String>> regenerateBackupCodes() async {
    final user = _supabase.auth.currentUser!;
    final setup = await _supabase
        .from('user_2fa')
        .select()
        .eq('user_id', user.id)
        .eq('verified', true)
        .single();
    if (setup == null) throw Exception('2FA is not enabled');
    return await _generateBackupCodes();
  }

  Future<bool> isTwoFactorEnabled() async {
    final user = _supabase.auth.currentUser!;
    final setup = await _supabase
        .from('user_2fa')
        .select()
        .eq('user_id', user.id)
        .eq('verified', true)
        .maybeSingle();
    return setup != null;
  }

  Future<List<Map<String, dynamic>>> getTrustedDevices() async {
    final user = _supabase.auth.currentUser!;
    final data = await _supabase
        .from('trusted_devices')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return data;
  }

  Future<void> addTrustedDevice(String deviceName) async {
    final user = _supabase.auth.currentUser!;
    await _supabase.from('trusted_devices').insert({
      'user_id': user.id,
      'device_name': deviceName,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeTrustedDevice(String deviceId) async {
    await _supabase.from('trusted_devices').delete().eq('id', deviceId);
  }

  Future<bool> verifyLogin(String code) async {
    final user = _supabase.auth.currentUser!;
    final setup = await _supabase
        .from('user_2fa')
        .select()
        .eq('user_id', user.id)
        .eq('verified', true)
        .single();
    return await verifyCode(setup['secret'], code);
  }

  Future<String> generateSessionToken() async {
    final user = _supabase.auth.currentUser!;
    final token = _generateRandomCode();
    await _supabase.from('session_tokens').insert({
      'user_id': user.id,
      'token': token,
      'created_at': DateTime.now().toIso8601String(),
      'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    });
    return token;
  }
}