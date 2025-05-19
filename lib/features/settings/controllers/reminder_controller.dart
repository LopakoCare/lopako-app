import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lopako_app_lis/core/services/notification_service.dart';

class ReminderController extends ChangeNotifier {
  static const String _reminderEnabledKey = 'reminder_enabled';
  static const String _reminderHourKey = 'reminder_hour';
  static const String _reminderMinuteKey = 'reminder_minute';

  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  bool _reminderEnabled = false;
  bool _isLoading = true;

  TimeOfDay get selectedTime => _selectedTime;
  bool get reminderEnabled => _reminderEnabled;
  bool get isLoading => _isLoading;

  Future<void> loadReminderSettings() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _reminderEnabled = prefs.getBool(_reminderEnabledKey) ?? false;
    int hour = prefs.getInt(_reminderHourKey) ?? 20;
    int minute = prefs.getInt(_reminderMinuteKey) ?? 0;
    _selectedTime = TimeOfDay(hour: hour, minute: minute);

    if (_reminderEnabled) {
      await scheduleReminder();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, _reminderEnabled);
    await prefs.setInt(_reminderHourKey, _selectedTime.hour);
    await prefs.setInt(_reminderMinuteKey, _selectedTime.minute);
    notifyListeners();
  }

  Future<void> updateTime(TimeOfDay newTime) async {
    _selectedTime = newTime;
    await saveReminderSettings();
    if (_reminderEnabled) {
      await scheduleReminder();
    }
  }

  Future<void> toggleReminder(bool value) async {
    _reminderEnabled = value;
    await saveReminderSettings();
    if (value) {
      await scheduleReminder();
    } else {
      await cancelReminder();
    }
  }

  Future<void> scheduleReminder() async {
    await NotificationService().scheduleDailyReminder(
      id: 1,
      title: '¡No olvides practicar!',
      body: 'Mantén tu racha y aprende algo nuevo hoy.',
      time: _selectedTime,
    );
  }

  Future<void> cancelReminder() async {
    await NotificationService().cancel(1);
  }

  Future<void> showTestNotification() async {
    await NotificationService().showTestNotification();
  }

  Future<void> showScheduledTestNotification() async {
    await NotificationService().showScheduledTestNotification();
  }
}
