import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/group_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class GroupInfoScreen extends ConsumerWidget {
  final String groupId;
  const GroupInfoScreen({super.key, required this.groupId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));
    return Scaffold(
      appBar: AppBar(title: const Text('Group Info')),
      body: groupAsync.when(
        data: (group) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(radius: 60, backgroundImage: group.photoUrl != null ? NetworkImage(group.photoUrl!) : null, child: group.photoUrl == null ? Text(group.title[0].toUpperCase()) : null),
                    const SizedBox(height: 8),
                    Text(group.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('${group.memberCount ?? 0} members', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Group Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(leading: const Icon(Icons.people), title: const Text('Members'), trailing: const Icon(Icons.arrow_forward_ios), onTap: () => context.push('/group/${group.id}/members')),
              ListTile(leading: const Icon(Icons.admin_panel_settings), title: const Text('Admins & Moderators'), onTap: () {}),
              ListTile(leading: const Icon(Icons.link), title: const Text('Invite Link'), onTap: () {}),
              if (group.isMuted == true)
                ListTile(leading: const Icon(Icons.notifications_off), title: const Text('Unmute'), onTap: () {})
              else
                ListTile(leading: const Icon(Icons.notifications), title: const Text('Mute Notifications'), onTap: () {}),
              const Divider(),
              ListTile(leading: const Icon(Icons.exit_to_app, color: Colors.red), title: const Text('Leave Group', style: TextStyle(color: Colors.red)), onTap: () {}),
            ],
          ),
        ),
        loading: () => const LoadingWidget(),
        error: (err, stack) => const ErrorWidget('Failed to load group'),
      ),
    );
  }
}