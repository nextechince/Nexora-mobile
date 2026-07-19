import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/group_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/loading_widget.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});
  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController _titleController = TextEditingController();
  String? _photoUrl;
  final List<String> _selectedMembers = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        actions: [
          if (_isLoading) const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          else TextButton(onPressed: _selectedMembers.isEmpty ? null : _createGroup, child: const Text('Create')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final url = await ref.read(storageServiceProvider).pickAndUploadImage(bucket: 'avatars');
                if (url != null) setState(() => _photoUrl = url);
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                child: _photoUrl == null ? const Icon(Icons.add_photo_alternate, size: 40) : null,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Group Name', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            const Text('Add Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final contactsAsync = ref.watch(contactsProvider);
                return contactsAsync.when(
                  data: (contacts) => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final user = contacts[index];
                      final isSelected = _selectedMembers.contains(user.id);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (_) => setState(() {
                          if (isSelected) _selectedMembers.remove(user.id);
                          else _selectedMembers.add(user.id);
                        }),
                        title: Text(user.displayName ?? user.phone),
                        subtitle: Text(user.phone),
                        secondary: CircleAvatar(
                          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                          child: user.avatarUrl == null ? Text(user.displayName?[0] ?? user.phone[0]) : null,
                        ),
                      );
                    },
                  ),
                  loading: () => const LoadingWidget(),
                  error: (err, stack) => const Text('Failed to load contacts'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGroup() async {
    if (_titleController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final group = await ref.read(createGroupProvider).create(
        title: _titleController.text,
        memberIds: _selectedMembers,
        photoUrl: _photoUrl,
      );
      if (mounted) context.go('/group/${group.id}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally { if (mounted) setState(() => _isLoading = false); }
  }
}