import 'dart:convert';
import 'package:http/http.dart' as http;

class BotSDKService {
  final String apiKey;
  final String baseUrl;

  BotSDKService({required this.apiKey, this.baseUrl = 'https://api.nexora.com/v1'});

  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String text,
    Map<String, dynamic>? options,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'chat_id': chatId,
        'text': text,
        ...?options,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getUpdates({int offset = 0, int limit = 100}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/updates?offset=$offset&limit=$limit'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    return jsonDecode(response.body);
  }

  Future<void> setWebhook(String url) async {
    await http.post(
      Uri.parse('$baseUrl/webhook'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'url': url}),
    );
  }

  Future<void> deleteWebhook() async {
    await http.delete(
      Uri.parse('$baseUrl/webhook'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    return jsonDecode(response.body);
  }
}