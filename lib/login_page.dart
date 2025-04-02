import 'package:flutter/material.dart';
import 'package:lopako_app_lis/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();

  void toggleMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void handleAuth() async {
    final email = emailController.text;
    final password = passwordController.text;

    final user = isLogin
        ? await auth.login(email, password)
        : await auth.register(email, password);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al ${isLogin ? 'iniciar sesión' : 'registrarse'}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(isLogin ? 'Login' : 'Registro', style: TextStyle(fontSize: 24)),
          TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
          TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Contraseña'), obscureText: true),
          SizedBox(height: 20),
          ElevatedButton(onPressed: handleAuth, child: Text(isLogin ? 'Login' : 'Registrarse')),
          ElevatedButton.icon(
            onPressed: () async {
              final user = await auth.signInWithGoogle();
              if (user != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al iniciar sesión con Google')),
                );
              }
            },
            icon: Icon(Icons.login),
            label: Text('Iniciar sesión con Google'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          ),
          TextButton(onPressed: toggleMode, child: Text(isLogin ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Inicia sesión')),
        ]),
      ),
    );
  }
}
