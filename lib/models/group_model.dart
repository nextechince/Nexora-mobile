import 'package:freezed_annotation/freezed_annotation.dart';
part 'group_model.freezed.dart';
part 'group_model.g.dart';

@freezed
class Group with _$Group {
  const factory Group({
    required String id,
    required String title,
    String? photoUrl,
    String? description,
    required String createdBy,
    DateTime? createdAt,
    int? memberCount,
    List<String>? admins,
    List<String>? moderators,
    Map<String, dynamic>? permissions,
    bool? isMuted,
    bool? isArchived,
    String? pinnedMessageId,
    Map<String, dynamic>? joinRequests,
  }) = _Group;
  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}