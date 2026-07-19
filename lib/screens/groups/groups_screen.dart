import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/group_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: groupsAsync.when(
        data: (groups) {
          if (groups.isEmpty) return const Center(child: Text('No groups yet. Create one!'));
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: group.photoUrl != null ? NetworkImage(group.photoUrl!) : null,
                  child: group.photoUrl == null ? Text(group.title[0].toUpperCase()) : null,
                ),
                title: Text(group.title),
                subtitle: Text('${group.memberCount ?? 0} members'),
                onTap: () => context.push('/group/${group.id}'),
              );
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (err, stack) => const ErrorWidget('Failed to load groups'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-group'),
        child: const Icon(Icons.group_add),
      ),
    );
  }
}