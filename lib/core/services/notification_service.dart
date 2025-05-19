import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'service_manager.dart';

class NotificationService extends BaseService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const String _tokenKey = 'fcm_token';
  String? _fcmToken;

  // Canales de notificación
  static const _highImportanceChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notificaciones Importantes',
    description: 'Canal para notificaciones importantes',
    importance: Importance.high,
  );

  static const _dailyReminderChannel = AndroidNotificationChannel(
    'daily_reminder_channel',
    'Recordatorios diarios',
    description: 'Recordatorios diarios tipo Duolingo',
    importance: Importance.max,
  );

  /* ──────────── INITIALIZE ──────────── */
  @override
  Future<void> initialize() async {
    try {
      tz_data.initializeTimeZones();
      await _initializeLocalNotifications();
      await _setupNotificationChannels();
      _setupMessageHandlers();
      await _getAndSaveFCMToken();
    } catch (e) {
      print('Error al inicializar NotificationService: $e');
      rethrow;
    }
  }

  /* ──────────── FCM TOKEN ──────────── */
  Future<String?> getFCMToken() async {
    if (_fcmToken == null) {
      final prefs = await SharedPreferences.getInstance();
      _fcmToken = prefs.getString(_tokenKey);
    }
    return _fcmToken;
  }

  /* ──────────── TOPICS ──────────── */
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  /* ──────────── REMINDERS ──────────── */
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    try {
      final scheduledDate = _nextInstanceOfTime(time);
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _dailyReminderChannel.id,
            _dailyReminderChannel.name,
            channelDescription: _dailyReminderChannel.description,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Error al programar recordatorio: $e');
    }
  }

  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /* ──────────── TEST NOTIFICATIONS ──────────── */
  Future<void> showTestNotification() async {
    await _notifications.show(
      999,
      '¡Notificación instantánea!',
      'Esto es una prueba directa.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _highImportanceChannel.id,
          _highImportanceChannel.name,
          channelDescription: _highImportanceChannel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showScheduledTestNotification() async {
    final scheduled = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(minutes: 1));
    await _notifications.zonedSchedule(
      1000,
      '¡Notificación programada!',
      'Esto es una prueba programada para dentro de 1 minuto.',
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _highImportanceChannel.id,
          _highImportanceChannel.name,
          channelDescription: _highImportanceChannel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /* ──────────── PRIVATE METHODS ──────────── */
  Future<void> _initializeLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _setupNotificationChannels() async {
    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidPlugin?.createNotificationChannel(_highImportanceChannel);
    await androidPlugin?.createNotificationChannel(_dailyReminderChannel);
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_showNotification);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);
  }

  Future<void> _getAndSaveFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _fcmToken!);
      }
    } catch (e) {
      print('Error al obtener FCM token: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notificación tocada: ${response.payload}');
  }

  void _handleNotificationOpened(RemoteMessage message) {
    print('App abierta desde notificación: ${message.messageId}');
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _notifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _highImportanceChannel.id,
            _highImportanceChannel.name,
            channelDescription: _highImportanceChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensaje recibido en segundo plano: ${message.messageId}');
}
