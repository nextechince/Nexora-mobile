import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: txAsync.when(
        data: (txs) {
          if (txs.isEmpty) return const Center(child: Text('No transactions yet'));
          return ListView.builder(
            itemCount: txs.length,
            itemBuilder: (context, index) {
              final tx = txs[index];
              return ListTile(
                leading: Icon(tx.type == 'credit' ? Icons.arrow_downward : Icons.arrow_upward, color: tx.type == 'credit' ? Colors.green : Colors.red),
                title: Text(tx.type ?? ''),
                subtitle: Text(tx.status ?? ''),
                trailing: Text('${tx.type == 'credit' ? '+' : '-'}${tx.amount}', style: TextStyle(color: tx.type == 'credit' ? Colors.green : Colors.red)),
              );
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (err, stack) => const ErrorWidget('Failed to load transactions'),
      ),
    );
  }
}