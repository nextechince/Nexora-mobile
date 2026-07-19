import 'package:freezed_annotation/freezed_annotation.dart';
part 'story_model.freezed.dart';
part 'story_model.g.dart';

@freezed
class Story with _$Story {
  const factory Story({
    required String id,
    required String userId,
    required String type,
    required String mediaUrl,
    String? caption,
    int? duration,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? viewCount,
    Map<String, List<String>>? reactions,
    bool? isHighlight,
    User? user,
  }) = _Story;
  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);
}