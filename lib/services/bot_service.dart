import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bot_model.dart';
import '../models/bot_command_model.dart';

class BotService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Bot> createBot({
    required String name,
    required String username,
    String? description,
    String? avatarUrl,
  }) async {
    final user = _supabase.auth.currentUser!;
    final apiKeyResult = await _supabase.rpc('generate_api_key');
    final botIdResult = await _supabase.rpc('generate_bot_id');
    final botData = {
      'bot_id': botIdResult,
      'name': name,
      'username': username.startsWith('@') ? username : '@$username',
      'api_key': apiKeyResult,
      'owner_id': user.id,
      'description': description,
      'avatar_url': avatarUrl,
      'status': 'active',
      'permissions': {
        'can_send_messages': true,
        'can_join_groups': true,
        'can_read_messages': true,
      },
    };
    final response = await _supabase.from('bots').insert(botData).select().single();
    return Bot.fromJson(response);
  }

  Future<List<Bot>> getUserBots() async {
    final user = _supabase.auth.currentUser!;
    final data = await _supabase
        .from('bots')
        .select()
        .eq('owner_id', user.id)
        .order('created_at', ascending: false);
    return data.map((json) => Bot.fromJson(json)).toList();
  }

  Future<Bot> getBot(String botId) async {
    final data = await _supabase
        .from('bots')
        .select()
        .eq('id', botId)
        .single();
    return Bot.fromJson(data);
  }

  Future<Bot> updateBot(String botId, Map<String, dynamic> updates) async {
    final response = await _supabase
        .from('bots')
        .update(updates)
        .eq('id', botId)
        .select()
        .single();
    return Bot.fromJson(response);
  }

  Future<String> regenerateApiKey(String botId) async {
    final apiKey = await _supabase.rpc('generate_api_key');
    await _supabase.from('bots').update({'api_key': apiKey}).eq('id', botId);
    return apiKey;
  }

  Future<void> deleteBot(String botId) async {
    await _supabase.from('bots').delete().eq('id', botId);
  }

  Future<List<BotCommand>> getBotCommands(String botId) async {
    final data = await _supabase
        .from('bot_commands')
        .select()
        .eq('bot_id', botId)
        .order('command', ascending: true);
    return data.map((json) => BotCommand.fromJson(json)).toList();
  }

  Future<BotCommand> addCommand({
    required String botId,
    required String command,
    String? description,
    String? permission,
    String? handlerUrl,
  }) async {
    final data = {
      'bot_id': botId,
      'command': command.startsWith('/') ? command : '/$command',
      'description': description,
      'permission': permission ?? 'everyone',
      'handler_url': handlerUrl,
    };
    final response = await _supabase
        .from('bot_commands')
        .insert(data)
        .select()
        .single();
    return BotCommand.fromJson(response);
  }

  Future<void> removeCommand(String commandId) async {
    await _supabase.from('bot_commands').delete().eq('id', commandId);
  }

  Future<Map<String, dynamic>> getAnalytics(String botId) async {
    final logs = await _supabase
        .from('bot_logs')
        .select()
        .eq('bot_id', botId);
    final subscribers = await _supabase
        .from('bot_subscribers')
        .select()
        .eq('bot_id', botId);
    return {
      'total_requests': logs.length,
      'unique_users': subscribers.length,
      'last_7_days': _getLast7DaysStats(logs),
      'hourly_breakdown': _getHourlyBreakdown(logs),
      'commands_usage': _getCommandUsage(logs),
    };
  }

  Future<void> logInteraction({
    required String botId,
    required String eventType,
    String? method,
    String? path,
    int? statusCode,
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
  }) async {
    await _supabase.from('bot_logs').insert({
      'bot_id': botId,
      'event_type': eventType,
      'method': method,
      'path': path,
      'status_code': statusCode,
      'request_data': requestData,
      'response_data': responseData,
    });
    await _supabase
        .from('bots')
        .update({
          'total_requests': _supabase.sql('total_requests + 1'),
          'last_used_at': DateTime.now().toIso8601String(),
        })
        .eq('id', botId);
  }

  Future<List<Map<String, dynamic>>> getLogs(String botId, {int limit = 100}) async {
    final data = await _supabase
        .from('bot_logs')
        .select()
        .eq('bot_id', botId)
        .order('created_at', ascending: false)
        .limit(limit);
    return data;
  }

  // Helper methods (simplified)
  List<Map<String, dynamic>> _getLast7DaysStats(List logs) => [];
  List<Map<String, dynamic>> _getHourlyBreakdown(List logs) => [];
  List<Map<String, dynamic>> _getCommandUsage(List logs) => [];
}