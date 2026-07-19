import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final now = DateTime.now();
  if (date.isAfter(now.subtract(const Duration(days: 1)))) {
    return DateFormat('HH:mm').format(date);
  } else if (date.isAfter(now.subtract(const Duration(days: 7)))) {
    return DateFormat('EEE').format(date);
  } else {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}