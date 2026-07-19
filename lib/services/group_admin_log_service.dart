import 'package:supabase_flutter/supabase_flutter.dart';

class GroupAdminLogService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> logAction({
    required String groupId,
    required String adminId,
    required String action,
    required Map<String, dynamic> details,
  }) async {
    await _supabase.from('group_admin_logs').insert({
      'group_id': groupId,
      'admin_id': adminId,
      'action': action,
      'details': details,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getGroupLogs(String groupId) async {
    final data = await _supabase
        .from('group_admin_logs')
        .select('*, users!admin_id(*)')
        .eq('group_id', groupId)
        .order('created_at', ascending: false)
        .limit(100);
    return data;
  }

  List<Map<String, String>> getAdminActions() {
    return [
      {'action': 'added_member', 'label': 'Added a member'},
      {'action': 'removed_member', 'label': 'Removed a member'},
      {'action': 'promoted_admin', 'label': 'Promoted to admin'},
      {'action': 'demoted_admin', 'label': 'Demoted from admin'},
      {'action': 'promoted_moderator', 'label': 'Promoted to moderator'},
      {'action': 'demoted_moderator', 'label': 'Demoted from moderator'},
      {'action': 'pinned_message', 'label': 'Pinned a message'},
      {'action': 'unpinned_message', 'label': 'Unpinned a message'},
      {'action': 'deleted_message', 'label': 'Deleted a message'},
      {'action': 'muted_member', 'label': 'Muted a member'},
      {'action': 'unmuted_member', 'label': 'Unmuted a member'},
      {'action': 'changed_group_name', 'label': 'Changed group name'},
      {'action': 'changed_group_photo', 'label': 'Changed group photo'},
    ];
  }

  Stream<List<Map<String, dynamic>>> watchGroupLogs(String groupId) {
    return _supabase
        .from('group_admin_logs')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('created_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> searchLogs({
    required String groupId,
    String? action,
    String? adminId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    var query = _supabase.from('group_admin_logs').select('*, users!admin_id(*)').eq('group_id', groupId);
    if (action != null) query = query.eq('action', action);
    if (adminId != null) query = query.eq('admin_id', adminId);
    if (fromDate != null) query = query.gte('created_at', fromDate.toIso8601String());
    if (toDate != null) query = query.lte('created_at', toDate.toIso8601String());
    final data = await query.order('created_at', ascending: false).limit(100);
    return data;
  }

  Future<Map<String, dynamic>> getLogSummary(String groupId) async {
    final logs = await getGroupLogs(groupId);
    final summary = {
      'total_actions': logs.length,
      'unique_admins': logs.map((log) => log['admin_id']).toSet().length,
      'most_active_admin': _getMostActiveAdmin(logs),
      'most_common_action': _getMostCommonAction(logs),
      'last_24_hours': _getLast24HoursCount(logs),
    };
    return summary;
  }

  String _getMostActiveAdmin(List<Map<String, dynamic>> logs) {
    final adminCounts = <String, int>{};
    for (var log in logs) {
      final adminId = log['admin_id'] as String;
      adminCounts[adminId] = (adminCounts[adminId] ?? 0) + 1;
    }
    return adminCounts.isEmpty ? 'No admins' : adminCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _getMostCommonAction(List<Map<String, dynamic>> logs) {
    final actionCounts = <String, int>{};
    for (var log in logs) {
      final action = log['action'] as String;
      actionCounts[action] = (actionCounts[action] ?? 0) + 1;
    }
    return actionCounts.isEmpty ? 'No actions' : actionCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int _getLast24HoursCount(List<Map<String, dynamic>> logs) {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return logs.where((log) => DateTime.parse(log['created_at']).isAfter(cutoff)).length;
  }

  Future<String> exportLogs(String groupId) async {
    final logs = await getGroupLogs(groupId);
    return 'Export file content';
  }
}