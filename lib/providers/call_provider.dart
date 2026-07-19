import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/call_service.dart';
import '../models/call_model.dart';

part 'call_provider.g.dart';

@riverpod
Future<List<Call>> callHistory(Ref ref) async {
  final service = ref.watch(callServiceProvider);
  return service.getCallHistory();
}