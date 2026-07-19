import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/stories_carousel.dart';
import 'chat_list_tile.dart';
import 'bottom_nav_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatListProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NEXORA CHQT'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => context.push('/search')),
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications), onPressed: () => context.push('/notifications')),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const StoriesCarousel(),
          Expanded(
            child: chatsAsync.when(
              data: (chats) {
                if (chats.isEmpty) return const Center(child: Text('No chats yet. Start a new conversation!', style: TextStyle(color: Colors.white54)));
                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) => ChatListTile(chat: chats[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatOptions(context),
        child: const Icon(Icons.chat),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() => _currentTab = index);
          switch (index) {
            case 0: break;
            case 1: context.push('/groups'); break;
            case 2: context.push('/channels'); break;
            case 3: context.push('/calls'); break;
            case 4: context.push('/profile/${user?.id}'); break;
          }
        },
        unreadCount: unreadCount,
      ),
    );
  }

  void _showNewChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.person_add, color: Colors.blue), title: const Text('New Private Chat'), onTap: () => context.push('/new-chat')),
            ListTile(leading: const Icon(Icons.group_add, color: Colors.green), title: const Text('New Group'), onTap: () => context.push('/create-group')),
            ListTile(leading: const Icon(Icons.rss_feed, color: Colors.orange), title: const Text('New Channel'), onTap: () => context.push('/create-channel')),
          ],
        ),
      ),
    );
  }
}