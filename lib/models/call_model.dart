import 'package:freezed_annotation/freezed_annotation.dart';
part 'call_model.freezed.dart';
part 'call_model.g.dart';

@freezed
class Call with _$Call {
  const factory Call({
    required String id,
    required String callerId,
    required String calleeId,
    required String type,
    required String status,
    DateTime? startedAt,
    DateTime? endedAt,
    int? duration,
    String? callSid,
    Map<String, dynamic>? metadata,
    User? caller,
    User? callee,
  }) = _Call;
  factory Call.fromJson(Map<String, dynamic> json) => _$CallFromJson(json);
}