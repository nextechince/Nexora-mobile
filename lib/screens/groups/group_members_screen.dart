import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/group_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/group_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class GroupMembersScreen extends ConsumerStatefulWidget {
  final String groupId;
  const GroupMembersScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends ConsumerState<GroupMembersScreen> {
  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(groupMembersProvider(widget.groupId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddMemberDialog(context),
          ),
        ],
      ),
      body: membersAsync.when(
        data: (members) {
          if (members.isEmpty) {
            return const Center(child: Text('No members found.'));
          }
          // Sort: owners first, then admins, then moderators, then members.
          final sortedMembers = List.from(members)
            ..sort((a, b) {
              final roleOrder = {'owner': 0, 'admin': 1, 'moderator': 2, 'member': 3};
              final aRole = a['role'] ?? 'member';
              final bRole = b['role'] ?? 'member';
              return roleOrder[aRole]!.compareTo(roleOrder[bRole]!);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedMembers.length,
            itemBuilder: (context, index) {
              final member = sortedMembers[index];
              final user = member['users'] as Map<String, dynamic>?;
              if (user == null) return const SizedBox.shrink();

              final role = member['role'] ?? 'member';
              final isCurrentUser = user['id'] == currentUser?.id;
              final canManage = currentUser != null && 
                (member['role'] == 'owner' || member['role'] == 'admin');

              return Card(
                color: Colors.grey.shade900,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user['avatar_url'] != null
                        ? NetworkImage(user['avatar_url'])
                        : null,
                    child: user['avatar_url'] == null
                        ? Text((user['display_name']?[0] ?? '?').toUpperCase())
                        : null,
                  ),
                  title: Text(
                    user['display_name'] ?? user['username'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Row(
                    children: [
                      _buildRoleChip(role),
                      const SizedBox(width: 8),
                      if (isCurrentUser)
                        const Text('(You)', style: TextStyle(fontSize: 12, color: Colors.blue)),
                    ],
                  ),
                  trailing: canManage && !isCurrentUser
                      ? PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white54),
                          onSelected: (value) => _handleMemberAction(value, user['id'], context),
                          itemBuilder: (context) => [
                            if (role != 'admin')
                              const PopupMenuItem(
                                value: 'promote_admin',
                                child: Text('Promote to Admin'),
                              ),
                            if (role == 'admin')
                              const PopupMenuItem(
                                value: 'demote_admin',
                                child: Text('Demote to Member'),
                              ),
                            if (role != 'moderator' && role != 'owner' && role != 'admin')
                              const PopupMenuItem(
                                value: 'promote_moderator',
                                child: Text('Promote to Moderator'),
                              ),
                            if (role == 'moderator')
                              const PopupMenuItem(
                                value: 'demote_moderator',
                                child: Text('Demote to Member'),
                              ),
                            const PopupMenuItem(
                              value: 'remove',
                              child: Text('Remove from Group', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        )
                      : null,
                  onTap: () {
                    // Navigate to user profile
                    context.push('/profile/${user['id']}');
                  },
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (err, stack) => ErrorWidget(err.toString()),
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    Color color;
    String label;
    switch (role) {
      case 'owner':
        color = Colors.amber;
        label = 'Owner';
        break;
      case 'admin':
        color = Colors.blue;
        label = 'Admin';
        break;
      case 'moderator':
        color = Colors.green;
        label = 'Moderator';
        break;
      default:
        color = Colors.grey;
        label = 'Member';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: SizedBox(
          height: 300,
          width: double.maxFinite,
          child: _ContactPicker(groupId: widget.groupId),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleMemberAction(String action, String userId, BuildContext context) {
    final service = ref.read(groupServiceProvider);
    switch (action) {
      case 'promote_admin':
        service.promoteToAdmin(widget.groupId, userId);
        break;
      case 'demote_admin':
        service.demoteFromAdmin(widget.groupId, userId);
        break;
      case 'promote_moderator':
        service.promoteToModerator(widget.groupId, userId);
        break;
      case 'demote_moderator':
        service.demoteFromModerator(widget.groupId, userId);
        break;
      case 'remove':
        _confirmRemove(userId);
        break;
    }
    // Refresh the list
    ref.invalidate(groupMembersProvider(widget.groupId));
  }

  void _confirmRemove(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: const Text('Are you sure you want to remove this member from the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final service = ref.read(groupServiceProvider);
              service.removeMember(widget.groupId, userId);
              ref.invalidate(groupMembersProvider(widget.groupId));
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Internal widget to pick contacts to add
class _ContactPicker extends ConsumerStatefulWidget {
  final String groupId;
  const _ContactPicker({required this.groupId});

  @override
  ConsumerState<_ContactPicker> createState() => _ContactPickerState();
}

class _ContactPickerState extends ConsumerState<_ContactPicker> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    final currentGroupMembersAsync = ref.watch(groupMembersProvider(widget.groupId));

    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search contacts...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: contactsAsync.when(
            data: (contacts) {
              final filtered = contacts.where((user) {
                final name = (user.displayName ?? user.phone ?? '').toLowerCase();
                return name.contains(_searchQuery);
              }).toList();

              // Exclude users already in the group
              final existingUserIds = currentGroupMembersAsync.value
                  ?.map((m) => m['user_id'] as String)
                  .toSet() ?? {};

              final available = filtered.where((user) => !existingUserIds.contains(user.id)).toList();

              if (available.isEmpty) {
                return const Center(child: Text('No contacts available to add.'));
              }

              return ListView.builder(
                itemCount: available.length,
                itemBuilder: (context, index) {
                  final user = available[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? Text(user.displayName?[0] ?? user.phone?[0] ?? '?')
                          : null,
                    ),
                    title: Text(user.displayName ?? user.phone ?? 'Unknown'),
                    subtitle: Text(user.phone ?? ''),
                    onTap: () => _addMember(user.id),
                    trailing: const Icon(Icons.add_circle, color: Colors.blue),
                  );
                },
              );
            },
            loading: () => const LoadingWidget(),
            error: (err, stack) => ErrorWidget(err.toString()),
          ),
        ),
      ],
    );
  }

  void _addMember(String userId) async {
    final service = ref.read(groupServiceProvider);
    await service.addMembers(widget.groupId, [userId]);
    ref.invalidate(groupMembersProvider(widget.groupId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Member added!'), backgroundColor: Colors.green),
    );
    Navigator.pop(context); // Close the dialog
  }
}