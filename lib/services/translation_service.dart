import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/env.dart';

class TranslationService {
  final String _apiKey = Env.googleTranslateApiKey ?? '';
  final String _baseUrl = 'https://translation.googleapis.com/language/translate/v2';

  final Map<String, String> supportedLanguages = {
    'en': 'English', 'es': 'Spanish', 'fr': 'French', 'de': 'German',
    'it': 'Italian', 'pt': 'Portuguese', 'ru': 'Russian', 'ja': 'Japanese',
    'ko': 'Korean', 'zh': 'Chinese', 'ar': 'Arabic', 'hi': 'Hindi',
  };

  Future<String> translateText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    if (_apiKey.isEmpty) throw Exception('Google Translate API key not configured');
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'target': targetLanguage,
          'source': sourceLanguage,
          'format': 'text',
          'key': _apiKey,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['translations'][0]['translatedText'];
      } else {
        throw Exception('Translation failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Translation error: $e');
    }
  }

  Future<List<String>> translateMultiple({
    required List<String> texts,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    final results = <String>[];
    for (var text in texts) {
      final translated = await translateText(
        text: text,
        targetLanguage: targetLanguage,
        sourceLanguage: sourceLanguage,
      );
      results.add(translated);
    }
    return results;
  }

  Future<String> detectLanguage(String text) async {
    if (_apiKey.isEmpty) throw Exception('Google Translate API key not configured');
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': text, 'key': _apiKey}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['detections'][0][0]['language'];
      } else {
        throw Exception('Language detection failed');
      }
    } catch (e) {
      throw Exception('Detection error: $e');
    }
  }

  final List<Map<String, dynamic>> _translationHistory = [];

  void saveTranslationHistory({
    required String original,
    required String translated,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    _translationHistory.add({
      'original': original,
      'translated': translated,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (_translationHistory.length > 100) _translationHistory.removeAt(0);
  }

  List<Map<String, dynamic>> getTranslationHistory() => List.from(_translationHistory);
  void clearTranslationHistory() => _translationHistory.clear();
  String getLanguageName(String code) => supportedLanguages[code] ?? code;
}