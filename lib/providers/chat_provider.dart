import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/chat_service.dart';
import '../models/chat_model.dart';

part 'chat_provider.g.dart';

@riverpod
Future<List<Chat>> chatList(Ref ref) async {
  final service = ref.watch(chatServiceProvider);
  return service.getChats();
}

@riverpod
Future<Chat> chatDetail(Ref ref, String chatId) async {
  final service = ref.watch(chatServiceProvider);
  return service.getChat(chatId);
}

@riverpod
int unreadCount(Ref ref) {
  final service = ref.watch(chatServiceProvider);
  return service.getUnreadCount();
}

@riverpod
Stream<List<Chat>> chatListStream(Ref ref) {
  final service = ref.watch(chatServiceProvider);
  return service.watchChats();
}