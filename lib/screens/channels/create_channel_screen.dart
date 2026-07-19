import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/channel_provider.dart';
import '../../services/storage_service.dart';

class CreateChannelScreen extends ConsumerStatefulWidget {
  const CreateChannelScreen({super.key});
  @override
  ConsumerState<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends ConsumerState<CreateChannelScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isPublic = true;
  String? _photoUrl;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Channel'),
        actions: [
          if (_isLoading) const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          else TextButton(onPressed: _createChannel, child: const Text('Create')),
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
              child: CircleAvatar(radius: 50, backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null, child: _photoUrl == null ? const Icon(Icons.add_photo_alternate, size: 40) : null),
            ),
            const SizedBox(height: 24),
            TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Channel Name', border: OutlineInputBorder()), validator: (v) => v?.isEmpty == true ? 'Required' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description (optional)', border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 16),
            SwitchListTile(title: const Text('Public Channel'), subtitle: Text(_isPublic ? 'Anyone can join' : 'Only invited users can join'), value: _isPublic, onChanged: (v) => setState(() => _isPublic = v), secondary: const Icon(Icons.public)),
          ],
        ),
      ),
    );
  }

  Future<void> _createChannel() async {
    if (_titleController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final channel = await ref.read(createChannelProvider).create(
        title: _titleController.text,
        isPublic: _isPublic,
        description: _descriptionController.text,
        photoUrl: _photoUrl,
      );
      if (mounted) context.go('/channel/${channel.id}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally { if (mounted) setState(() => _isLoading = false); }
  }
}