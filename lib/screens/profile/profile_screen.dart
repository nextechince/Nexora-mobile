import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/premium_provider.dart';
import '../../widgets/badge_widget.dart';

class ProfileScreen extends ConsumerWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isPremium = ref.watch(isPremiumProvider);
    if (user == null) return const Scaffold(body: Center(child: Text('User not found')));
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Profile'), actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () => context.push('/edit-profile'))]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(height: 150, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: user.coverUrl != null ? DecorationImage(image: NetworkImage(user.coverUrl!), fit: BoxFit.cover) : null, color: Colors.grey.shade800)),
            const SizedBox(height: -50),
            CircleAvatar(radius: 50, backgroundColor: Colors.grey.shade800, backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null, child: user.avatarUrl == null ? Text(user.displayName?.substring(0, 1).toUpperCase() ?? user.username?.substring(0, 1).toUpperCase() ?? '?', style: const TextStyle(fontSize: 40)) : null),
            const SizedBox(height: 12),
            Text(user.displayName ?? user.username ?? 'User', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            if (user.username != null) Text('@${user.username}', style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            if (user.bio != null) Text(user.bio!, style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Wrap(spacing: 8, children: user.badges?.map((badge) {
              Color color = Colors.grey;
              if (badge == 'owner_gold') color = Colors.amber;
              else if (badge == 'premium_blue') color = Colors.blue;
              else if (badge == 'verified_white') color = Colors.white;
              else if (badge == 'developer_purple') color = Colors.purple;
              else if (badge == 'moderator_green') color = Colors.green;
              return BadgeWidget(label: badge, color: color);
            }).toList() ?? []),
            const SizedBox(height: 20),
            isPremium.when(
              data: (premium) => premium ? const BadgeWidget(label: 'PREMIUM', color: Colors.amber) : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _buildStat('Wallet', '\$${user.walletBalance ?? 0}'),
              _buildStat('Coins', '${user.coinsBalance ?? 0}'),
              _buildStat('Status', user.isOnline == true ? 'Online' : 'Offline'),
            ]),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.message), label: const Text('Message'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white)),
              const SizedBox(width: 12),
              ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.phone), label: const Text('Call'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) => Column(children: [Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), Text(label, style: TextStyle(color: Colors.grey.shade500))]);
}