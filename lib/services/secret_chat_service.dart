import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'encryption_service.dart';

class SecretChatService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final EncryptionService _encryption = EncryptionService();

  Future<Map<String, dynamic>> startSecretChat(String userId) async {
    final user = _supabase.auth.currentUser!;
    final keys = _encryption.generateKeyPair();
    final data = await _supabase.from('secret_chats').insert({
      'user1_id': user.id,
      'user2_id': userId,
      'public_key': keys['publicKey'],
      'encrypted_private_key': keys['privateKey'],
      'status': 'pending',
    }).select().single();
    return data;
  }

  Future<void> acceptSecretChat(String chatId) async {
    await _supabase
        .from('secret_chats')
        .update({'status': 'active'})
        .eq('id', chatId);
  }

  Future<Stream<Map<String, dynamic>>> watchSecretMessages(String chatId) {
    return _supabase
        .from('encrypted_messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('sent_at', ascending: true);
  }

  Future<void> sendSecretMessage({
    required String chatId,
    required String content,
    int? selfDestructSeconds,
  }) async {
    final user = _supabase.auth.currentUser!;
    final chat = await _supabase
        .from('secret_chats')
        .select()
        .eq('id', chatId)
        .single();
    final sessionKey = chat['session_key'] ?? 'session_${DateTime.now().millisecondsSinceEpoch}';
    final encrypted = _encryption.encryptMessage(content, sessionKey);
    await _supabase.from('encrypted_messages').insert({
      'chat_id': chatId,
      'sender_id': user.id,
      'encrypted_content': encrypted,
      'iv': 'demo_iv',
      'self_destruct_at': selfDestructSeconds != null
          ? DateTime.now().add(Duration(seconds: selfDestructSeconds)).toIso8601String()
          : null,
    });
  }

  Future<void> markMessageRead(String messageId) async {
    final user = _supabase.auth.currentUser!;
    await _supabase
        .from('encrypted_messages')
        .update({'read_by': _supabase.sql('array_append(read_by, ${user.id})')})
        .eq('id', messageId);
  }

  Future<void> terminateSecretChat(String chatId) async {
    await _supabase
        .from('secret_chats')
        .update({'status': 'terminated'})
        .eq('id', chatId);
  }

  Future<List<Map<String, dynamic>>> getSecretChats() async {
    final user = _supabase.auth.currentUser!;
    final data = await _supabase
        .from('secret_chats')
        .select('*, users!user1_id(*), users!user2_id(*)')
        .or('user1_id.eq.${user.id},user2_id.eq.${user.id}')
        .eq('status', 'active');
    return data;
  }

  Future<bool> verifyKey(String chatId, String verificationCode) async {
    // Implement QR code verification
    return true;
  }
}