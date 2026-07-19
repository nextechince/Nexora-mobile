import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

part 'notification_provider.g.dart';

@riverpod
Future<List<Notification>> notifications(Ref ref) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getNotifications();
}