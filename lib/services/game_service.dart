import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class GameService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const List<Map<String, dynamic>> availableGames = [
    {'id': 'trivia', 'name': 'Trivia Challenge', 'description': 'Test your knowledge', 'icon': '🧠', 'max_players': 10, 'duration': 120},
    {'id': 'wordle', 'name': 'Word Puzzle', 'description': 'Guess the 5-letter word', 'icon': '📝', 'max_players': 20, 'duration': 60},
    {'id': 'tic_tac_toe', 'name': 'Tic Tac Toe', 'description': 'Classic strategy game', 'icon': '❌', 'max_players': 2, 'duration': 30},
    {'id': 'chess', 'name': 'Chess', 'description': 'Classic chess game', 'icon': '♟️', 'max_players': 2, 'duration': 300},
  ];

  Future<Map<String, dynamic>> createGame({
    required String gameId,
    required String chatId,
    required String hostId,
    Map<String, dynamic>? settings,
  }) async {
    final data = {
      'game_id': gameId,
      'chat_id': chatId,
      'host_id': hostId,
      'status': 'waiting',
      'settings': settings ?? {},
      'players': [hostId],
      'created_at': DateTime.now().toIso8601String(),
    };
    final response = await _supabase.from('game_sessions').insert(data).select().single();
    return response;
  }

  Future<void> joinGame(String sessionId, String userId) async {
    final session = await _supabase.from('game_sessions').select().eq('id', sessionId).single();
    final players = session['players'] as List;
    if (players.contains(userId)) return;
    players.add(userId);
    await _supabase.from('game_sessions').update({'players': players}).eq('id', sessionId);
  }

  Future<void> startGame(String sessionId) async {
    await _supabase.from('game_sessions').update({'status': 'active', 'started_at': DateTime.now().toIso8601String()}).eq('id', sessionId);
  }

  Future<void> endGame(String sessionId, Map<String, dynamic> results) async {
    await _supabase.from('game_sessions').update({
      'status': 'ended',
      'results': results,
      'ended_at': DateTime.now().toIso8601String(),
    }).eq('id', sessionId);
  }

  Stream<List<Map<String, dynamic>>> watchActiveGames(String chatId) {
    return _supabase
        .from('game_sessions')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .neq('status', 'ended')
        .order('created_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> getGameHistory(String chatId) async {
    final data = await _supabase
        .from('game_sessions')
        .select('*, users!host_id(*)')
        .eq('chat_id', chatId)
        .eq('status', 'ended')
        .order('created_at', ascending: false)
        .limit(20);
    return data;
  }

  Future<void> submitMove({
    required String sessionId,
    required String userId,
    required Map<String, dynamic> move,
  }) async {
    final session = await _supabase.from('game_sessions').select('moves').eq('id', sessionId).single();
    final moves = session['moves'] as List? ?? [];
    moves.add({
      'user_id': userId,
      'move': move,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _supabase.from('game_sessions').update({'moves': moves}).eq('id', sessionId);
  }
}