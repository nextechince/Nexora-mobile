import 'package:freezed_annotation/freezed_annotation.dart';
part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class Notification with _$Notification {
  const factory Notification({
    required String id,
    required String userId,
    required String type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) = _Notification;
  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);
}