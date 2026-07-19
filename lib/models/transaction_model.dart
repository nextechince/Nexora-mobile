import 'package:freezed_annotation/freezed_annotation.dart';
part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String userId,
    required String type,
    required int amount,
    String? currency,
    String? status,
    String? reference,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
  }) = _Transaction;
  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}