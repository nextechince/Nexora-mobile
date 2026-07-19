import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/premium_service.dart';

part 'premium_provider.g.dart';

@riverpod
Future<bool> isPremium(Ref ref) async {
  final service = ref.watch(premiumServiceProvider);
  return service.isPremium();
}

@riverpod
Future<List<String>> premiumFeatures(Ref ref) async {
  final service = ref.watch(premiumServiceProvider);
  return service.getPremiumFeatures();
}