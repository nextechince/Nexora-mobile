import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class I18nService {
  static final I18nService _instance = I18nService._internal();
  factory I18nService() => _instance;
  I18nService._internal();

  String _currentLanguage = 'en';
  Map<String, String> _translations = {};

  final Map<String, String> languages = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'pt': 'Português',
    'ru': 'Русский',
    'ja': '日本語',
    'ko': '한국어',
    'zh': '中文',
    'ar': 'العربية',
    'hi': 'हिन्दी',
  };

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'en';
    await loadLanguage(_currentLanguage);
  }

  Future<void> loadLanguage(String code) async {
    try {
      final jsonString = await rootBundle.loadString('assets/i18n/$code.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      _translations = data.map((key, value) => MapEntry(key, value.toString()));
      _currentLanguage = code;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', code);
    } catch (e) {
      if (code != 'en') await loadLanguage('en');
    }
  }

  String translate(String key, [Map<String, String>? args]) {
    var text = _translations[key] ?? key;
    if (args != null) {
      args.forEach((key, value) {
        text = text.replaceAll('{{$key}}', value);
      });
    }
    return text;
  }

  String get currentLanguage => _currentLanguage;
  Future<void> setLanguage(String code) async => await loadLanguage(code);
  Map<String, String> get translations => _translations;
}