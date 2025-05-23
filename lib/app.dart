import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/services/service_manager.dart';
import 'generated/l10n.dart';

import 'core/services/auth_service.dart';
import 'features/navigation/screens/app_wrapper.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/routines/screens/home_screen.dart';
import 'features/calendar/controllers/calendar_controller.dart';
import 'features/calendar/screens/calendar_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(),
        ),
        ChangeNotifierProvider<CalendarController>(
          create: (_) => CalendarController(),
        ),
      ],
      child: MaterialApp(
        title: 'Lopako',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        locale: const Locale('es'),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              return AppWrapper();
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
        routes: {
          '/auth': (context) => const AuthScreen(),
          '/calendar': (context) => const CalendarScreen(),
        },
      ),
    );
  }
}
