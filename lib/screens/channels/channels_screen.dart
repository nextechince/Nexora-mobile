import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/channel_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class ChannelsScreen extends ConsumerWidget {
  const ChannelsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(channelListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Channels')),
      body: channelsAsync.when(
        data: (channels) {
          if (channels.isEmpty) return const Center(child: Text('No channels yet.'));
          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              return ListTile(
                leading: CircleAvatar(backgroundImage: channel.photoUrl != null ? NetworkImage(channel.photoUrl!) : null, child: channel.photoUrl == null ? Text(channel.title[0].toUpperCase()) : null),
                title: Text(channel.title),
                subtitle: Text('${channel.subscribers ?? 0} subscribers • ${channel.isPublic == true ? 'Public' : 'Private'}'),
                onTap: () => context.push('/channel/${channel.id}'),
              );
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (err, stack) => const ErrorWidget('Failed to load channels'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-channel'),
        child: const Icon(Icons.rss_feed),
      ),
    );
  }
}