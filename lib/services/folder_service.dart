import 'package:hive_flutter/hive_flutter.dart';

class FolderService {
  late Box _foldersBox;

  Future<void> init() async {
    _foldersBox = await Hive.openBox('chat_folders');
  }

  Future<void> createFolder({
    required String name,
    String? icon,
    List<String>? chatIds,
    Map<String, dynamic>? rules,
  }) async {
    final user = _supabase.auth.currentUser!;
    final folders = _foldersBox.get(user.id) ?? [];
    folders.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'icon': icon ?? 'folder',
      'chat_ids': chatIds ?? [],
      'rules': rules ?? {},
      'created_at': DateTime.now().toIso8601String(),
    });
    await _foldersBox.put(user.id, folders);
  }

  List<Map<String, dynamic>> getFolders() {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];
    return _foldersBox.get(user.id)?.cast<Map<String, dynamic>>() ?? [];
  }

  List<String> getFolderChats(String folderId) {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];
    final folders = _foldersBox.get(user.id) ?? [];
    final folder = folders.firstWhere((f) => f['id'] == folderId, orElse: () => null);
    return folder?['chat_ids']?.cast<String>() ?? [];
  }

  Future<void> addChatToFolder(String folderId, String chatId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    final folders = _foldersBox.get(user.id) ?? [];
    final index = folders.indexWhere((f) => f['id'] == folderId);
    if (index != -1) {
      final chatIds = folders[index]['chat_ids'] ?? [];
      if (!chatIds.contains(chatId)) {
        chatIds.add(chatId);
        folders[index]['chat_ids'] = chatIds;
        await _foldersBox.put(user.id, folders);
      }
    }
  }

  Future<void> removeChatFromFolder(String folderId, String chatId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    final folders = _foldersBox.get(user.id) ?? [];
    final index = folders.indexWhere((f) => f['id'] == folderId);
    if (index != -1) {
      final chatIds = folders[index]['chat_ids'] ?? [];
      chatIds.remove(chatId);
      folders[index]['chat_ids'] = chatIds;
      await _foldersBox.put(user.id, folders);
    }
  }

  Future<void> deleteFolder(String folderId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    final folders = _foldersBox.get(user.id) ?? [];
    folders.removeWhere((f) => f['id'] == folderId);
    await _foldersBox.put(user.id, folders);
  }
}