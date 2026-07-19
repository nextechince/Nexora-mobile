import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../services/story_service.dart';
import '../../services/storage_service.dart';

class CreateStoryScreen extends ConsumerStatefulWidget {
  const CreateStoryScreen({super.key});
  @override
  ConsumerState<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends ConsumerState<CreateStoryScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Story'), actions: [
        if (_isLoading) const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
        else TextButton(onPressed: _pickImage, child: const Text('Post'))
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey.shade800,
                child: const Icon(Icons.add_photo_alternate, size: 60, color: Colors.white54),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _captionController, decoration: const InputDecoration(labelText: 'Caption', border: OutlineInputBorder())),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _isLoading = true);
    try {
      final file = File(image.path);
      final url = await ref.read(storageServiceProvider).uploadFile(file: file, bucket: 'stories');
      await ref.read(storyServiceProvider).createStory(
        mediaUrl: url,
        type: 'image',
        caption: _captionController.text,
      );
      if (mounted) context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally { if (mounted) setState(() => _isLoading = false); }
  }
}