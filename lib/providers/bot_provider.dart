import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/bot_service.dart';
import '../models/bot_model.dart';
import '../models/bot_command_model.dart';

part 'bot_provider.g.dart';

@riverpod
Future<List<Bot>> userBots(Ref ref) async {
  final service = ref.watch(botServiceProvider);
  return service.getUserBots();
}

@riverpod
Future<Bot> botDetail(Ref ref, String botId) async {
  final service = ref.watch(botServiceProvider);
  return service.getBot(botId);
}

@riverpod
Future<List<BotCommand>> botCommands(Ref ref, String botId) async {
  final service = ref.watch(botServiceProvider);
  return service.getBotCommands(botId);
}

@riverpod
class CreateBot extends _$CreateBot {
  @override
  Future<void> build() async {}

  Future<Bot> create({
    required String name,
    required String username,
    String? description,
    String? avatarUrl,
  }) async {
    final service = ref.watch(botServiceProvider);
    return service.createBot(
      name: name,
      username: username,
      description: description,
      avatarUrl: avatarUrl,
    );
  }
}