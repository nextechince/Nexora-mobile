import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(walletBalanceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.grey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text('Balance', style: TextStyle(color: Colors.white70)),
                    balanceAsync.when(
                      data: (balance) => Text('\$${balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      loading: () => const LoadingWidget(),
                      error: (err, stack) => const Text('Error'),
                    ),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      ElevatedButton.icon(onPressed: () => context.push('/wallet/deposit'), icon: const Icon(Icons.add), label: const Text('Deposit')),
                      ElevatedButton.icon(onPressed: () => context.push('/wallet/withdraw'), icon: const Icon(Icons.remove), label: const Text('Withdraw')),
                      ElevatedButton.icon(onPressed: () => context.push('/wallet/transactions'), icon: const Icon(Icons.history), label: const Text('History')),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              children: [
                _buildAction(Icons.star, 'Premium', () => context.push('/premium')),
                _buildAction(Icons.monetization_on, 'Buy Coins', () => context.push('/wallet/buy-coins')),
                _buildAction(Icons.send, 'Send', () => context.push('/p2p-payment')),
                _buildAction(Icons.attach_money, 'Crypto', () => context.push('/crypto-wallet')),
                _buildAction(Icons.qr_code, 'QR Pay', () => context.push('/p2p-payment')),
                _buildAction(Icons.history, 'History', () => context.push('/wallet/transactions')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, VoidCallback onTap) {
    return Card(
      color: Colors.grey.shade900,
      child: InkWell(
        onTap: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.blue, size: 32), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 12))]),
      ),
    );
  }
}