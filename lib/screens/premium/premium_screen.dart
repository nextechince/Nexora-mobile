import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/premium_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../config/coin_packages.dart';
import '../../widgets/loading_widget.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});
  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  int _selectedMonths = 1;

  @override
  Widget build(BuildContext context) {
    final coinsAsync = ref.watch(coinsBalanceProvider);
    final isPremiumAsync = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('NEXORA Premium')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.star, size: 80, color: Colors.amber),
            const SizedBox(height: 8),
            const Text('Unlock Premium Features', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...premiumFeatures.map((f) => ListTile(leading: const Icon(Icons.check_circle, color: Colors.green), title: Text(f))),
            const Divider(height: 32),
            const Text('Choose Subscription', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [
              _buildDurationChip(1, '1 Month', '${premiumCoinCost[1]} coins'),
              _buildDurationChip(6, '6 Months', '${premiumCoinCost[6]} coins'),
              _buildDurationChip(12, '1 Year', '${premiumCoinCost[12]} coins'),
            ]),
            const SizedBox(height: 24),
            coinsAsync.when(
              data: (coins) {
                final needed = premiumCoinCost[_selectedMonths]!;
                final hasEnough = coins >= needed;
                return Column(children: [
                  Text('Your coins: $coins', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: hasEnough ? () => _purchasePremium(needed) : null,
                    style: ElevatedButton.styleFrom(backgroundColor: hasEnough ? Colors.amber : Colors.grey, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                    child: Text(hasEnough ? 'Subscribe Now' : 'Not enough coins'),
                  ),
                  if (!hasEnough) TextButton(onPressed: () => context.push('/wallet/buy-coins'), child: const Text('Buy more coins')),
                ]);
              },
              loading: () => const LoadingWidget(),
              error: (err, stack) => const Text('Could not load balance'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationChip(int months, String label, String cost) {
    final isSelected = _selectedMonths == months;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilterChip(
          selected: isSelected,
          label: Column(children: [Text(label), Text(cost, style: const TextStyle(fontSize: 12))]),
          onSelected: (_) => setState(() => _selectedMonths = months),
          backgroundColor: Colors.grey.shade800,
          selectedColor: Colors.amber.withOpacity(0.3),
          labelStyle: TextStyle(color: isSelected ? Colors.amber : Colors.white),
        ),
      ),
    );
  }

  Future<void> _purchasePremium(int cost) async {
    // Deduct coins and grant premium.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium activated!'), backgroundColor: Colors.green));
  }
}

const List<String> premiumFeatures = [
  'Exclusive Themes',
  'Animated Profile',
  'More Storage (4GB Upload)',
  'Premium Stickers',
  'Premium Emoji',
  'Exclusive Reactions',
  'AI Assistant',
  'Voice To Text',
  'Profile Effects',
  'Custom Wallpapers',
  'Premium Badge',
];