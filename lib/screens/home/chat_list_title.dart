import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../models/chat_model.dart';
import '../../utils/date_formatter.dart';

class ChatListTile extends StatelessWidget {
  final Chat chat;
  const ChatListTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(chat.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {}, // archive toggle
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: chat.isArchived == true ? Icons.unarchive : Icons.archive,
            label: chat.isArchived == true ? 'Unarchive' : 'Archive',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(onPressed: (_) {}, backgroundColor: Colors.amber, foregroundColor: Colors.white, icon: Icons.push_pin, label: 'Pin'),
          SlidableAction(onPressed: (_) {}, backgroundColor: Colors.grey, foregroundColor: Colors.white, icon: chat.isMuted == true ? Icons.notifications_off : Icons.notifications, label: chat.isMuted == true ? 'Unmute' : 'Mute'),
          SlidableAction(onPressed: (_) {}, backgroundColor: Colors.red, foregroundColor: Colors.white, icon: Icons.delete, label: 'Delete'),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: chat.photoUrl != null ? NetworkImage(chat.photoUrl!) : null,
          child: chat.photoUrl == null ? Text(chat.title?[0] ?? '?') : null,
        ),
        title: Text(
          chat.title ?? 'Chat',
          style: TextStyle(fontWeight: chat.unreadCount != null && chat.unreadCount! > 0 ? FontWeight.bold : FontWeight.normal),
        ),
        subtitle: Text(chat.lastMessage?.content ?? 'No messages yet', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (chat.unreadCount != null && chat.unreadCount! > 0)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                child: Text('${chat.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
            if (chat.lastMessage != null)
              Text(
                DateFormatter.formatMessageTime(chat.lastMessage!.sentAt!),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
        onTap: () => context.push('/chat/${chat.id}'),
        onLongPress: () {}, // extra options
      ),
    );
  }
}