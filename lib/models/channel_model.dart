import 'package:freezed_annotation/freezed_annotation.dart';
part 'channel_model.freezed.dart';
part 'channel_model.g.dart';

@freezed
class Channel with _$Channel {
  const factory Channel({
    required String id,
    required String title,
    String? photoUrl,
    String? description,
    required String createdBy,
    DateTime? createdAt,
    int? subscribers,
    bool? isPublic,
    bool? isMuted,
    bool? isArchived,
    String? pinnedMessageId,
    Map<String, dynamic>? analytics,
  }) = _Channel;
  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);
}