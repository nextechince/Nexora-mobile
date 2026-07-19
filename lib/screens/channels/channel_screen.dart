import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/channel_provider.dart';
import '../../providers/message_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class ChannelScreen extends ConsumerStatefulWidget {
  final String channelId;
  const ChannelScreen({super.key, required this.channelId});
  @override
  ConsumerState<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends ConsumerState<ChannelScreen> {
  @override
  Widget build(BuildContext context) {
    final channelAsync = ref.watch(channelDetailProvider(widget.channelId));
    final messagesAsync = ref.watch(messagesStreamProvider(widget.channelId));
    return Scaffold(
      appBar: AppBar(title: channelAsync.when(data: (c) => Text(c.title ?? 'Channel'), loading: () => const Text('Loading...'), error: (_, __) => const Text('Error'))),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (msgs) => ListView.builder(
                itemCount: msgs.length,
                itemBuilder: (_, i) => ListTile(title: Text(msgs[i].content ?? '')),
              ),
              loading: () => const LoadingWidget(),
              error: (_, __) => const ErrorWidget('Failed to load messages'),
            ),
          ),
          // In channel, only admins can post. For simplicity, we add a text field.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(decoration: const InputDecoration(hintText: 'Write a post...'))),
                IconButton(icon: const Icon(Icons.send), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}