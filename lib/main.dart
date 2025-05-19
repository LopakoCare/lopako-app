import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lopako_app_lis/core/services/routines_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/auth_service.dart';
import 'core/services/family_circles_service.dart';
import 'core/services/service_manager.dart';
import 'core/models/firebase_options.dart';
import 'app.dart';
import 'core/services/user_service.dart';
import 'core/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar zonas horarias para notificaciones programadas
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Paris'));

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SharedPreferences.getInstance();

  final sm = ServiceManager.instance;
  sm.add('auth', AuthService());
  sm.add('user', UserService());
  sm.add('familyCircles', FamilyCirclesService());
  sm.add('routines', RoutinesService());

  final notificationService = NotificationService();
  sm.add('notification', notificationService);
  await notificationService.initialize();

  runApp(const MyApp());
}
