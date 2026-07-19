import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';
import '../models/withdrawal_model.dart';

class WalletService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> getBalance() async {
    final user = _supabase.auth.currentUser!;
    final data = await _supabase
        .from('users')
        .select('wallet_balance, coins_balance')
        .eq('id', user.id)
        .single();
    return data['wallet_balance'] ?? 0;
  }

  Future<int> getCoinsBalance() async {
    final user = _supabase.auth.currentUser!;
    final data = await _supabase
        .from('users')
        .select('coins_balance')
        .eq('id', user.id)
        .single();
    return data['coins_balance'] ?? 0;
  }

  Future<List<Transaction>> getTransactions() async {
    final user = _supabase.auth.currentUser!;
    final data = await _supabase
        .from('transactions')
        .select('*, users(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return data.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<void> addCoins(int amount, {String? reference}) async {
    final user = _supabase.auth.currentUser!;
    await _supabase.rpc('add_coins', params: {
      'user_id': user.id,
      'amount': amount,
    });
    await _supabase.from('transactions').insert({
      'user_id': user.id,
      'type': 'coin_purchase',
      'amount': amount,
      'currency': 'coin',
      'status': 'completed',
      'reference': reference ?? 'manual_${DateTime.now().millisecondsSinceEpoch}',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> purchasePremium(int cost) async {
    final user = _supabase.auth.currentUser!;
    await _supabase.rpc('purchase_premium', params: {
      'user_id': user.id,
      'cost': cost,
    });
  }

  Future<void> withdrawCoins(int amount, Withdrawal withdrawal) async {
    final user = _supabase.auth.currentUser!;
    await _supabase.from('withdrawals').insert({
      'user_id': user.id,
      'bank_name': withdrawal.bankName,
      'account_number': withdrawal.accountNumber,
      'account_name': withdrawal.accountName,
      'amount': amount,
      'status': 'pending',
    });
  }

  Future<void> transferCoins(String toUserId, int amount) async {
    final user = _supabase.auth.currentUser!;
    await _supabase.rpc('transfer_coins', params: {
      'sender_id': user.id,
      'receiver_id': toUserId,
      'amount': amount,
    });
  }
}