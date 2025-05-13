import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_theme.dart';
import 'package:lopako_app_lis/features/familiar_circles/screens/create_or_join_screen.dart';
import 'package:lopako_app_lis/features/familiar_circles/screens/family_circle_details.dart';
import 'package:lopako_app_lis/features/familiar_circles/screens/family_circle_pin.dart';
import 'package:lopako_app_lis/features/navigation/screens/main_tab_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'generated/l10n.dart';

import 'core/services/auth_service.dart';
import 'features/navigation/screens/app_wrapper.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/routines/screens/home_screen.dart';
import 'features/calendar/controllers/calendar_controller.dart';
import 'features/calendar/screens/calendar_screen.dart';
import 'features/chatbot/screens/chatbot_screen.dart';

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
        home: const AuthScreen(), // punto de entrada claro
        routes: {
          '/auth': (context) => const AuthScreen(),
          '/home': (context) => MainTabScreen(),
          '/routines': (context) => const HomeScreen(),
          '/calendar': (context) => const CalendarScreen(),
          '/family/choice': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map?;
            final userAge = args?['userAge'] as int;

            return FamilyCircleChoiceScreen(userAge: userAge);
          },
          '/family/join': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map?;
            final userAge = args?['userAge'] as int;

            return JoinFamilyCodeScreen(userAge: userAge);
          },

          '/family/details': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map;

            return FamilyCircleDetailsScreen(
              isCreating: args['isCreating'] ?? false,
              patientName: args['patientName'],
              familyId: args['familyId'],
              userAge: args['userAge']
            );
          },
          '/routines': (context) => const RoutinesScreen(),
          '/chatbot': (context) => const ChatbotScreen(),
        },
      ),
    );
  }
}
