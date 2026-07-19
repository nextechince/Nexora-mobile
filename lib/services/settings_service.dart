import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsService {
  late Box _settingsBox;

  Future<void> init() async {
    _settingsBox = await Hive.openBox('settings');
  }

  ThemeMode getThemeMode() {
    final value = _settingsBox.get('themeMode');
    if (value == 'light') return ThemeMode.light;
    if (value == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    final value = mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system';
    _settingsBox.put('themeMode', value);
  }

  String? getTranslationLanguage() {
    return _settingsBox.get('translation_language') as String?;
  }

  void setTranslationLanguage(String code) {
    _settingsBox.put('translation_language', code);
  }

  bool? getAutoTranslate() {
    return _settingsBox.get('auto_translate') as bool?;
  }

  void setAutoTranslate(bool value) {
    _settingsBox.put('auto_translate', value);
  }

  bool? getShowTranslation() {
    return _settingsBox.get('show_translation') as bool?;
  }

  void setShowTranslation(bool value) {
    _settingsBox.put('show_translation', value);
  }
}