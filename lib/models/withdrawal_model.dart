import 'package:freezed_annotation/freezed_annotation.dart';
part 'withdrawal_model.freezed.dart';
part 'withdrawal_model.g.dart';

@freezed
class Withdrawal with _$Withdrawal {
  const factory Withdrawal({
    required String id,
    required String userId,
    required String bankName,
    required String accountNumber,
    required String accountName,
    required int amount,
    String? status,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
  }) = _Withdrawal;
  factory Withdrawal.fromJson(Map<String, dynamic> json) => _$WithdrawalFromJson(json);
}