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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SharedPreferences.getInstance();

  final sm = ServiceManager.instance;
  sm.add('auth', AuthService());
  sm.add('user', UserService());
  sm.add('familyCircles', FamilyCirclesService());
  sm.add('routines', RoutinesService());

  runApp(const MyApp());
}