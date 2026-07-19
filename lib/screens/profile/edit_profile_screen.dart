import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../services/storage_service.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _avatarUrl;
  String? _coverUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _usernameController.text = user.username ?? '';
      _bioController.text = user.bio ?? '';
      _avatarUrl = user.avatarUrl;
      _coverUrl = user.coverUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), actions: [if (_isLoading) const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))) else TextButton(onPressed: _save, child: const Text('Save'))]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(onTap: () => _pickImage('avatar'), child: CircleAvatar(radius: 50, backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null, child: _avatarUrl == null ? const Icon(Icons.add_photo_alternate, size: 40) : null)),
            const SizedBox(height: 16),
            GestureDetector(onTap: () => _pickImage('cover'), child: Container(height: 100, width: double.infinity, color: Colors.grey.shade800, child: _coverUrl != null ? Image.network(_coverUrl!, fit: BoxFit.cover) : const Icon(Icons.add_photo_alternate, size: 40))),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Display Name')),
            const SizedBox(height: 16),
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 16),
            TextField(controller: _bioController, decoration: const InputDecoration(labelText: 'Bio'), maxLines: 3),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(String type) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final file = File(image.path);
    final url = await ref.read(storageServiceProvider).uploadFile(file: file, bucket: 'avatars');
    setState(() {
      if (type == 'avatar') _avatarUrl = url;
      else _coverUrl = url;
    });
  }

  void _save() async {
    setState(() => _isLoading = true);
    // In real app, update user in Supabase.
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) context.pop();
    setState(() => _isLoading = false);
  }
}