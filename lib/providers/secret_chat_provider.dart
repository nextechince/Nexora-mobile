import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/secret_chat_service.dart';

part 'secret_chat_provider.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> secretChats(Ref ref) async {
  final service = ref.watch(secretChatServiceProvider);
  return service.getSecretChats();
}

@riverpod
Stream<Map<String, dynamic>> secretMessages(Ref ref, String chatId) {
  final service = ref.watch(secretChatServiceProvider);
  return service.watchSecretMessages(chatId);
}