import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _localNotifications.initialize(initializationSettings);

    // Firebase Messaging
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token = await fcm.getToken();
    // Save token to Supabase for user

    // Supabase Realtime subscription for notifications
    _supabase
        .channel('public:notifications')
        .on(
          RealtimePostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              'user_id',
              PostgresChangeFilterOperator.eq,
              _supabase.auth.currentUser?.id ?? '',
            ),
          ),
          (payload) {
            final data = payload.newRecord;
            _showLocalNotification(
              title: data['title'] ?? 'NEXORA',
              body: data['body'] ?? '',
            );
          },
        )
        .subscribe();
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'nexora_channel',
      'NEXORA Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );
    await _localNotifications.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'notification_payload',
    );
  }

  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<List<Notification>> getNotifications() async {
    final user = _supabase.auth.currentUser!;
    final data = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return data.map((json) => Notification.fromJson(json)).toList();
  }
}