import 'package:freezed_annotation/freezed_annotation.dart';
part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String chatId,
    required String senderId,
    String? replyToId,
    String? content,
    String? type,
    List<String>? mediaUrls,
    String? thumbnailUrl,
    String? fileName,
    int? fileSize,
    int? duration,
    Map<String, dynamic>? pollOptions,
    Map<String, dynamic>? pollVotes,
    bool? isEdited,
    bool? isDeleted,
    bool? isForwarded,
    String? forwardedFrom,
    DateTime? scheduledAt,
    DateTime? sentAt,
    Map<String, List<String>>? reactions,
    List<String>? readBy,
    List<String>? deliveredTo,
    int? viewCount,
    User? sender,
    Message? replyTo,
  }) = _Message;
  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}