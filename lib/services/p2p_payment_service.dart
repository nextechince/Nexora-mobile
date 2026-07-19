import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class P2PPaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> createPaymentRequest({
    required String fromUserId,
    required String toUserId,
    required double amount,
    String? currency,
    String? note,
    DateTime? expiresAt,
  }) async {
    final data = await _supabase.from('payment_requests').insert({
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'amount': amount,
      'currency': currency ?? 'coin',
      'note': note,
      'status': 'pending',
      'expires_at': expiresAt?.toIso8601String() ?? DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();
    return data;
  }

  Future<void> acceptPaymentRequest(String requestId) async {
    final request = await _supabase.from('payment_requests').select().eq('id', requestId).single();
    await _supabase.rpc('transfer_coins', params: {
      'sender_id': request['from_user_id'],
      'receiver_id': request['to_user_id'],
      'amount': request['amount'],
    });
    await _supabase.from('payment_requests').update({
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }

  Future<void> declinePaymentRequest(String requestId) async {
    await _supabase.from('payment_requests').update({
      'status': 'declined',
      'declined_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }

  Future<List<Map<String, dynamic>>> getPaymentRequests() async {
    final user = _supabase.auth.currentUser!;
    final data = await _supabase
        .from('payment_requests')
        .select('*, users!from_user_id(*), users!to_user_id(*)')
        .or('from_user_id.eq.${user.id},to_user_id.eq.${user.id}')
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return data;
  }

  String generatePaymentQR({
    required String userId,
    required double amount,
    String? note,
  }) {
    final data = {
      'user_id': userId,
      'amount': amount,
      'note': note,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return base64Encode(utf8.encode(jsonEncode(data)));
  }

  Future<Map<String, dynamic>> scanPaymentQR(String qrData) async {
    try {
      final decoded = utf8.decode(base64Decode(qrData));
      return jsonDecode(decoded);
    } catch (e) {
      throw Exception('Invalid QR code');
    }
  }

  Future<List<Map<String, dynamic>>> splitBill({
    required double totalAmount,
    required List<String> userIds,
    required String chatId,
  }) async {
    final perPerson = totalAmount / userIds.length;
    final results = <Map<String, dynamic>>[];
    for (var userId in userIds) {
      final request = await createPaymentRequest(
        fromUserId: userId,
        toUserId: userIds.first,
        amount: perPerson,
        note: 'Split bill in chat $chatId',
      );
      results.add(request);
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    final user = _supabase.auth.currentUser!;
    final data = await _supabase
        .from('transactions')
        .select('*, users!user_id(*)')
        .eq('type', 'p2p_payment')
        .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}')
        .order('created_at', ascending: false);
    return data;
  }

  Future<void> sendPayment({
    required String toUserId,
    required double amount,
    String? note,
  }) async {
    final user = _supabase.auth.currentUser!;
    final balance = await _supabase.from('users').select('coins_balance').eq('id', user.id).single();
    if ((balance['coins_balance'] ?? 0) < amount) {
      throw Exception('Insufficient balance');
    }
    await _supabase.rpc('transfer_coins', params: {
      'sender_id': user.id,
      'receiver_id': toUserId,
      'amount': amount.toInt(),
    });
    await _supabase.from('transactions').insert({
      'user_id': user.id,
      'type': 'p2p_payment',
      'amount': amount.toInt(),
      'currency': 'coin',
      'status': 'completed',
      'metadata': {'to_user_id': toUserId, 'note': note},
    });
  }

  String generatePaymentLink({
    required String userId,
    required double amount,
    String? note,
  }) {
    return 'nexora://pay?user=$userId&amount=$amount&note=${Uri.encodeComponent(note ?? '')}';
  }

  Future<Map<String, dynamic>> getUserByPaymentLink(String link) async {
    final uri = Uri.parse(link);
    final userId = uri.queryParameters['user'];
    final amount = double.tryParse(uri.queryParameters['amount'] ?? '0');
    if (userId == null) throw Exception('Invalid payment link');
    final user = await _supabase.from('users').select().eq('id', userId).single();
    return {'user': user, 'amount': amount};
  }
}