import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/wallet_service.dart';
import '../models/transaction_model.dart';

part 'wallet_provider.g.dart';

@riverpod
Future<int> walletBalance(Ref ref) async {
  final service = ref.watch(walletServiceProvider);
  return service.getBalance();
}

@riverpod
Future<int> coinsBalance(Ref ref) async {
  final service = ref.watch(walletServiceProvider);
  return service.getCoinsBalance();
}

@riverpod
Future<List<Transaction>> transactions(Ref ref) async {
  final service = ref.watch(walletServiceProvider);
  return service.getTransactions();
}