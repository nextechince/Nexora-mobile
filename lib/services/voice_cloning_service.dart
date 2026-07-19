import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../config/env.dart';

class VoiceCloningService {
  final String _apiKey = Env.elevenLabsApiKey ?? '';
  final String _baseUrl = 'https://api.elevenlabs.io/v1';

  Future<String> cloneVoice({
    required String audioFilePath,
    required String voiceName,
  }) async {
    final url = '$_baseUrl/voices/add';
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['xi-api-key'] = _apiKey;
    request.files.add(await http.MultipartFile.fromPath('file', audioFilePath));
    request.fields['name'] = voiceName;

    final response = await request.send();
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      return jsonDecode(data)['voice_id'];
    } else {
      throw Exception('Failed to clone voice');
    }
  }

  Future<String> generateSpeech({
    required String text,
    required String voiceId,
  }) async {
    final url = '$_baseUrl/text-to-speech/$voiceId';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'xi-api-key': _apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': text,
        'model_id': 'eleven_monolingual_v1',
        'voice_settings': {
          'stability': 0.5,
          'similarity_boost': 0.75,
        },
      }),
    );

    if (response.statusCode == 200) {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final file = File(path);
      await file.writeAsBytes(response.bodyBytes);
      return path;
    } else {
      throw Exception('Failed to generate speech');
    }
  }

  Future<List<Map<String, dynamic>>> getVoices() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/voices'),
      headers: {'xi-api-key': _apiKey},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['voices'] as List).map((v) => {
        'id': v['voice_id'],
        'name': v['name'],
        'category': v['category'],
        'is_cloned': v['is_cloned'] ?? false,
      }).toList();
    }
    return [];
  }

  Future<void> deleteVoice(String voiceId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/voices/$voiceId'),
      headers: {'xi-api-key': _apiKey},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete voice');
    }
  }

  Future<String> transcribeAudio(String audioFilePath) async {
    final url = 'https://api.openai.com/v1/audio/transcriptions';
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer ${Env.openAIApiKey}';
    request.files.add(await http.MultipartFile.fromPath('file', audioFilePath));
    request.fields['model'] = 'whisper-1';

    final response = await request.send();
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      return jsonDecode(data)['text'];
    } else {
      throw Exception('Failed to transcribe audio');
    }
  }
}