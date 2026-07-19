import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/coin_packages.dart';
import '../../providers/wallet_provider.dart';
import '../../services/payment_service.dart';

class BuyCoinsScreen extends ConsumerStatefulWidget {
  const BuyCoinsScreen({super.key});
  @override
  ConsumerState<BuyCoinsScreen> createState() => _BuyCoinsScreenState();
}

class _BuyCoinsScreenState extends ConsumerState<BuyCoinsScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buy Coins')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.2),
        itemCount: coinPackages.length,
        itemBuilder: (context, index) {
          final pkg = coinPackages[index];
          return Card(
            color: Colors.grey.shade900,
            child: InkWell(
              onTap: _isProcessing ? null : () => _buyCoins(pkg),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${pkg.coins}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                  Text('coins', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                  const SizedBox(height: 8),
                  Text(pkg.priceNaira, style: const TextStyle(fontSize: 16, color: Colors.white)),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  void _buyCoins(CoinPackage pkg) async {
    setState(() => _isProcessing = true);
    try {
      // Integrate payment gateway
      // For demo, just add coins.
      await Future.delayed(const Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase successful!'), backgroundColor: Colors.green));
      ref.invalidate(walletBalanceProvider);
      ref.invalidate(coinsBalanceProvider);
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _isProcessing = false); }
  }
}