import 'package:freezed_annotation/freezed_annotation.dart';
part 'bot_command_model.freezed.dart';
part 'bot_command_model.g.dart';

@freezed
class BotCommand with _$BotCommand {
  const factory BotCommand({
    required String id,
    required String botId,
    required String command,
    String? description,
    String? permission,
    String? handlerUrl,
    DateTime? createdAt,
  }) = _BotCommand;
  factory BotCommand.fromJson(Map<String, dynamic> json) => _$BotCommandFromJson(json);
}