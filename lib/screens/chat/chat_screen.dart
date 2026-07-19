import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/message_provider.dart';
import '../../providers/chat_provider.dart';
import 'message_bubble.dart';
import 'input_bar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatDetailProvider(widget.chatId));
    final messagesAsync = ref.watch(messagesStreamProvider(widget.chatId));

    return Scaffold(
      appBar: AppBar(
        title: chatAsync.when(
          data: (chat) => Text(chat.title ?? 'Chat'),
          loading: () => const Text('Loading...'),
          error: (err, stack) => const Text('Error'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () => context.push('/chat-info/${widget.chatId}')),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) return const Center(child: Text('No messages yet. Say hello!', style: TextStyle(color: Colors.white54)));
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(message: message);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
          ChatInputBar(chatId: widget.chatId),
        ],
      ),
    );
  }
}