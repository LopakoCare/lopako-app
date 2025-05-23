import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/services/auth_service.dart';
import 'package:lopako_app_lis/core/services/service_manager.dart';
import 'package:lopako_app_lis/core/services/user_service.dart';
import 'package:lopako_app_lis/features/auth/screens/new_family_circle_screen.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';
import '../../auth/screens/auth_screen.dart';
import 'main_tab_screen.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isNewFamilyCircleSkipped = false;
  bool _isNewFamilyCircleCompleted = false;

  void _handleSkip() => setState(() => _isNewFamilyCircleSkipped = true);
  void _handleComplete(_) => setState(() => _isNewFamilyCircleCompleted = true);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final authService = ServiceManager.instance.getService<AuthService>('auth');

        if (!authService.isLogged()) {
          _isNewFamilyCircleSkipped = false;
          _isNewFamilyCircleCompleted = false;
          return const AuthScreen();
        }

        final userService = ServiceManager.instance.getService<UserService>('user');
        return FutureBuilder<List<String>>(
          future: userService.getFamilyCircles(authService.currentUser!.uid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (!snap.hasError && snap.data!.isEmpty && !_isNewFamilyCircleSkipped && !_isNewFamilyCircleCompleted) {
              return NewFamilyCircleScreen(onSkip: _handleSkip, onComplete: _handleComplete);
            }

            return MainTabScreen();
          },
        );
      },
    );
  }
}
