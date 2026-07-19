import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadFile({
    required File file,
    required String bucket,
    String? path,
  }) async {
    final fileName = path ?? DateTime.now().millisecondsSinceEpoch.toString();
    final filePath = '$fileName.jpg';
    await _supabase.storage.from(bucket).upload(filePath, file);
    final url = _supabase.storage.from(bucket).getPublicUrl(filePath);
    return url;
  }

  Future<String?> pickAndUploadImage({
    required String bucket,
    ImageSource source = ImageSource.gallery,
  }) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      return await uploadFile(file: file, bucket: bucket);
    }
    return null;
  }

  Future<void> deleteFile(String bucket, String path) async {
    await _supabase.storage.from(bucket).remove([path]);
  }
}