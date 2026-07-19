import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

@freezed
class Settings with _$Settings {
  const factory Settings({
    PrivacySettings? privacy,
    NotificationSettings? notifications,
    AppearanceSettings? appearance,
    String? language,
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);
}

@freezed
class PrivacySettings with _$PrivacySettings {
  const factory PrivacySettings({
    String? lastSeen, // 'everyone', 'contacts', 'nobody'
    String? profilePhoto,
    String? status,
  }) = _PrivacySettings;

  factory PrivacySettings.fromJson(Map<String, dynamic> json) => _$PrivacySettingsFromJson(json);
}

@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    bool? messages,
    bool? calls,
    bool? stories,
    bool? wallet,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);
}

@freezed
class AppearanceSettings with _$AppearanceSettings {
  const factory AppearanceSettings({
    String? theme, // 'dark', 'light'
    String? chatWallpaper,
  }) = _AppearanceSettings;

  factory AppearanceSettings.fromJson(Map<String, dynamic> json) => _$AppearanceSettingsFromJson(json);
}