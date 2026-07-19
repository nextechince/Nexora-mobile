import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String phone,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? coverUrl,
    String? bio,
    String? status,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    int? walletBalance,
    int? coinsBalance,
    List<String>? badges,
    Map<String, dynamic>? settings,
  }) = _User;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}