import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/message_provider.dart';

class ChatInputBar extends ConsumerStatefulWidget {
  final String chatId;
  const ChatInputBar({super.key, required this.chatId});
  @override
  ConsumerState<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send, color: Colors.blue),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() => _isLoading = true);
    try {
      await ref.read(sendMessageProvider).send(chatId: widget.chatId, content: text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally { if (mounted) setState(() => _isLoading = false); }
  }
}