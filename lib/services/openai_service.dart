import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final String _apiKey = Env.openAIApiKey;

  Future<String> getChatCompletion({
    required List<Map<String, String>> messages,
    String model = 'gpt-3.5-turbo',
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'temperature': temperature,
          'max_tokens': maxTokens,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }

  Future<List<String>> getSmartReplies(String message) async {
    final prompt = '''
      Given this message: "$message"
      Generate 3 short smart reply suggestions. Format as a JSON array of strings.
      Example: ["That's great!", "Interesting.", "Tell me more."]
    ''';

    final response = await getChatCompletion(
      messages: [
        {'role': 'system', 'content': 'You are a helpful assistant that generates reply suggestions.'},
        {'role': 'user', 'content': prompt},
      ],
      maxTokens: 100,
    );

    try {
      return List<String>.from(jsonDecode(response));
    } catch (_) {
      return ['👍', '👀', 'Thanks!'];
    }
  }

  Future<String> summarizeConversation(String messages) async {
    return await getChatCompletion(
      messages: [
        {'role': 'system', 'content': 'You summarize conversations concisely.'},
        {'role': 'user', 'content': 'Summarize this chat:\n\n$messages'},
      ],
      maxTokens: 200,
    );
  }

  Future<String> translateMessage(String message, String targetLanguage) async {
    return await getChatCompletion(
      messages: [
        {'role': 'system', 'content': 'You translate text accurately.'},
        {'role': 'user', 'content': 'Translate to $targetLanguage:\n\n$message'},
      ],
      maxTokens: 200,
    );
  }

  Future<String> generateImage(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'prompt': prompt,
        'n': 1,
        'size': '512x512',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'][0]['url'];
    } else {
      throw Exception('Failed to generate image');
    }
  }
}