import 'package:freezed_annotation/freezed_annotation.dart';
part 'bot_model.freezed.dart';
part 'bot_model.g.dart';

@freezed
class Bot with _$Bot {
  const factory Bot({
    required String id,
    required String botId,
    required String name,
    required String username,
    required String apiKey,
    required String ownerId,
    String? description,
    String? avatarUrl,
    String? status,
    String? webhookUrl,
    List<String>? allowedDomains,
    Map<String, dynamic>? permissions,
    List<Map<String, dynamic>>? commands,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastUsedAt,
    int? totalRequests,
    int? totalUsers,
  }) = _Bot;
  factory Bot.fromJson(Map<String, dynamic> json) => _$BotFromJson(json);
}