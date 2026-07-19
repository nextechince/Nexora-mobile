import 'package:hive_flutter/hive_flutter.dart';

class AutoReplyService {
  late Box _rulesBox;

  Future<void> init() async {
    _rulesBox = await Hive.openBox('auto_reply_rules');
  }

  Future<void> addRule({
    required String chatId,
    required String keyword,
    required String reply,
    bool exactMatch = false,
    bool caseSensitive = false,
  }) async {
    final rules = _rulesBox.get(chatId) ?? [];
    rules.add({
      'keyword': keyword,
      'reply': reply,
      'exactMatch': exactMatch,
      'caseSensitive': caseSensitive,
      'enabled': true,
      'created_at': DateTime.now().toIso8601String(),
    });
    await _rulesBox.put(chatId, rules);
  }

  List<Map<String, dynamic>> getRules(String chatId) {
    return _rulesBox.get(chatId)?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<void> removeRule(String chatId, int index) async {
    final rules = _rulesBox.get(chatId) ?? [];
    rules.removeAt(index);
    await _rulesBox.put(chatId, rules);
  }

  Future<void> toggleRule(String chatId, int index) async {
    final rules = _rulesBox.get(chatId) ?? [];
    rules[index]['enabled'] = !rules[index]['enabled'];
    await _rulesBox.put(chatId, rules);
  }

  String? matchRule(String chatId, String message) {
    final rules = _rulesBox.get(chatId) ?? [];
    for (final rule in rules) {
      if (!rule['enabled']) continue;
      String keyword = rule['keyword'];
      String msg = message;
      if (!rule['caseSensitive']) {
        keyword = keyword.toLowerCase();
        msg = msg.toLowerCase();
      }
      if (rule['exactMatch']) {
        if (msg == keyword) return rule['reply'];
      } else {
        if (msg.contains(keyword)) return rule['reply'];
      }
    }
    return null;
  }

  Future<void> setAwayMode({
    required bool enabled,
    String? customMessage,
    DateTime? until,
  }) async {
    await _rulesBox.put('away_mode', {
      'enabled': enabled,
      'customMessage': customMessage ?? 'I\'m currently away. Will reply later.',
      'until': until?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Map<String, dynamic> getAwayMode() {
    return _rulesBox.get('away_mode') ?? {
      'enabled': false,
      'customMessage': 'I\'m currently away. Will reply later.',
    };
  }

  bool isAwayActive() {
    final away = getAwayMode();
    if (!away['enabled']) return false;
    if (away['until'] != null) {
      final until = DateTime.parse(away['until']);
      if (DateTime.now().isAfter(until)) return false;
    }
    return true;
  }
}