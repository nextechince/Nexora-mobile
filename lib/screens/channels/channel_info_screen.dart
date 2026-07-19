import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/channel_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class ChannelInfoScreen extends ConsumerWidget {
  final String channelId;
  const ChannelInfoScreen({super.key, required this.channelId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelAsync = ref.watch(channelDetailProvider(channelId));
    return Scaffold(
      appBar: AppBar(title: const Text('Channel Info')),
      body: channelAsync.when(
        data: (channel) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(radius: 60, backgroundImage: channel.photoUrl != null ? NetworkImage(channel.photoUrl!) : null, child: channel.photoUrl == null ? Text(channel.title[0].toUpperCase()) : null),
                    const SizedBox(height: 8),
                    Text(channel.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    if (channel.description != null) Text(channel.description!, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text('${channel.subscribers ?? 0} subscribers', style: const TextStyle(color: Colors.white70)),
                    if (channel.isPublic == true) const Chip(label: Text('Public'), backgroundColor: Colors.green) else const Chip(label: Text('Private'), backgroundColor: Colors.red),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Channel Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(leading: const Icon(Icons.people), title: const Text('Subscribers'), trailing: const Icon(Icons.arrow_forward_ios), onTap: () {}),
              ListTile(leading: const Icon(Icons.bar_chart), title: const Text('Analytics'), onTap: () {}),
              ListTile(leading: const Icon(Icons.push_pin), title: const Text('Pinned Posts'), onTap: () {}),
              const Divider(),
              ListTile(leading: const Icon(Icons.exit_to_app, color: Colors.red), title: const Text('Unsubscribe', style: TextStyle(color: Colors.red)), onTap: () {}),
            ],
          ),
        ),
        loading: () => const LoadingWidget(),
        error: (err, stack) => const ErrorWidget('Failed to load channel'),
      ),
    );
  }
}