import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lopako_app_lis/features/familiar_circles/screens/create_or_join_screen.dart';
import 'package:provider/provider.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../auth/screens/auth_screen.dart';
import 'main_tab_screen.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  User? _user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    final authController = Provider.of<AuthController>(context);

    print('[DEBUG] AppWrapper: user = $_user, wasJustRegistered = ${authController.wasJustRegistered}');

    if (_user == null) {
      return const AuthScreen();
    }

    if (authController.wasJustRegistered) {
      ///return const FamilyCircleChoiceScreen();
    }

    return MainTabScreen();
  }
}
