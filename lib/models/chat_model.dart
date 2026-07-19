import 'package:freezed_annotation/freezed_annotation.dart';
part 'chat_model.freezed.dart';
part 'chat_model.g.dart';

@freezed
class Chat with _$Chat {
  const factory Chat({
    required String id,
    required String type,
    String? title,
    String? photoUrl,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    bool? isMuted,
    String? pinnedMessageId,
    Map<String, dynamic>? permissions,
    Map<String, dynamic>? groupSettings,
    Map<String, dynamic>? channelSettings,
    User? otherUser,
    Message? lastMessage,
    int? unreadCount,
  }) = _Chat;
  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
}