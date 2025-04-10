import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart';  // Asegúrate de que esté importado correctamente
import 'firebase_options.dart';
import 'profile_page.dart';
import 'edit_profile_page.dart';
import 'sign_in_page.dart';  // Asegúrate de que esté importado correctamente

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lopako App',
      debugShowCheckedModeBanner: false,
      home: SignInPage(),  // Esta página debe ser el punto de inicio
      routes: {
        '/profile': (context) => ProfilePage(),
        '/edit-profile': (context) => EditProfilePage(),
      },
    );
  }
}
