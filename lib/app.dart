import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/intl_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/services/auth_service.dart';
import 'features/navigation/screens/app_wrapper.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/home/screens/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (ctx) => AuthController(ctx.read<AuthService>()),
        ),
      ],
      child: MaterialApp(
        title: 'Lopako',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
        ],
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
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
