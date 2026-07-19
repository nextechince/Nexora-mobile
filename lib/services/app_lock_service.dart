import 'package:local_auth/local_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppLockService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  late Box _settingsBox;

  Future<void> init() async {
    _settingsBox = await Hive.openBox('settings');
  }

  Future<bool> isBiometricAvailable() async {
    return await _localAuth.canCheckBiometrics;
  }

  Future<void> enableLock({
    String? pin,
    bool useBiometric = false,
  }) async {
    await _settingsBox.put('app_lock_enabled', true);
    await _settingsBox.put('app_lock_pin', pin);
    await _settingsBox.put('app_lock_biometric', useBiometric);
  }

  Future<void> disableLock() async {
    await _settingsBox.put('app_lock_enabled', false);
    await _settingsBox.put('app_lock_pin', null);
    await _settingsBox.put('app_lock_biometric', false);
  }

  bool isLockEnabled() {
    return _settingsBox.get('app_lock_enabled') ?? false;
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = _settingsBox.get('app_lock_pin');
    return pin == storedPin;
  }

  Future<bool> authenticateWithBiometrics() async {
    if (!_settingsBox.get('app_lock_biometric') ?? false) return false;
    try {
      final result = await _localAuth.authenticate(
        localizedReason: 'Unlock NEXORA CHQT',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return result;
    } catch (_) {
      return false;
    }
  }

  Future<void> setHideSensitiveContent(bool hide) async {
    await _settingsBox.put('hide_sensitive_content', hide);
  }

  bool getHideSensitiveContent() {
    return _settingsBox.get('hide_sensitive_content') ?? false;
  }

  Future<void> setAutoLockTimer(int seconds) async {
    await _settingsBox.put('auto_lock_timer', seconds);
  }

  int getAutoLockTimer() {
    return _settingsBox.get('auto_lock_timer') ?? 300;
  }

  Map<String, dynamic> getLockStatus() {
    return {
      'enabled': isLockEnabled(),
      'has_pin': _settingsBox.get('app_lock_pin') != null,
      'biometric': _settingsBox.get('app_lock_biometric') ?? false,
      'hide_content': getHideSensitiveContent(),
      'auto_lock': getAutoLockTimer(),
    };
  }
}