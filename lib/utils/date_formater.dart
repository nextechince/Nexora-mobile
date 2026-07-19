import 'package:intl/intl.dart';

class DateFormatter {
  static String formatMessageTime(DateTime date) => DateFormat('hh:mm a').format(date);
  static String formatChatDate(DateTime date) {
    final now = DateTime.now();
    if (date.isAfter(now.subtract(const Duration(days: 1)))) return 'Today';
    if (date.isAfter(now.subtract(const Duration(days: 2)))) return 'Yesterday';
    return DateFormat('dd MMM').format(date);
  }
}