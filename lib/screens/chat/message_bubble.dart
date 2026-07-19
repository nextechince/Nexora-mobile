import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/message_model.dart';
import '../../providers/message_provider.dart';
import '../../utils/date_formatter.dart';

class MessageBubble extends ConsumerWidget {
  final Message message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMe = message.senderId == ref.read(authStateProvider).value?.id;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue.shade700 : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.replyTo != null) _buildReplyPreview(),
                      _buildContent(),
                      if (message.reactions != null && message.reactions!.isNotEmpty) _buildReactions(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8),
                  child: Text(
                    DateFormatter.formatMessageTime(message.sentAt!),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildAvatar() => CircleAvatar(
    radius: 16,
    backgroundImage: message.sender?.avatarUrl != null ? NetworkImage(message.sender!.avatarUrl!) : null,
    child: message.sender?.avatarUrl == null ? Text(message.sender?.displayName?[0] ?? '?') : null,
  );

  Widget _buildReplyPreview() => Container(
    padding: const EdgeInsets.all(8),
    margin: const EdgeInsets.only(bottom: 6),
    decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(8)),
    child: Text(message.replyTo!.content ?? 'Reply', style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
  );

  Widget _buildContent() {
    if (message.type == 'text') return SelectableText(message.content ?? '', style: const TextStyle(color: Colors.white));
    else if (message.type == 'image') return CachedNetworkImage(imageUrl: message.mediaUrls!.first, width: 200, fit: BoxFit.cover);
    else return Text(message.content ?? '[${message.type}]');
  }

  Widget _buildReactions() => Wrap(
    spacing: 4,
    children: message.reactions!.entries.map((entry) {
      return InkWell(
        onTap: () => ref.read(messageServiceProvider).addReaction(message.id, entry.key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(entry.key),
              const SizedBox(width: 4),
              Text('${entry.value.length}', style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      );
    }).toList(),
  );
}