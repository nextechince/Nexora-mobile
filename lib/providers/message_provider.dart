import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/message_service.dart';
import '../models/message_model.dart';

part 'message_provider.g.dart';

@riverpod
Future<List<Message>> messages(Ref ref, String chatId) async {
  final service = ref.watch(messageServiceProvider);
  return service.getMessages(chatId);
}

@riverpod
Stream<List<Message>> messagesStream(Ref ref, String chatId) {
  final service = ref.watch(messageServiceProvider);
  return service.watchMessages(chatId);
}

@riverpod
class SendMessage extends _$SendMessage {
  @override
  Future<void> build() async {}

  Future<void> send({
    required String chatId,
    required String content,
    String? type,
    List<String>? mediaUrls,
    String? replyToId,
    DateTime? scheduledAt,
  }) async {
    final service = ref.watch(messageServiceProvider);
    await service.sendMessage(
      chatId: chatId,
      content: content,
      type: type,
      mediaUrls: mediaUrls,
      replyToId: replyToId,
      scheduledAt: scheduledAt,
    );
  }
}