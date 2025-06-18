import 'package:flutter/material.dart';
import 'package:laendle_guessr/services/user_service.dart';
import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/data_objects/user.dart';
import 'package:laendle_guessr/services/logger.dart';
import 'ui_components.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppLogger().log('LoginPage geladen');
    AppLogger().log('LoginPage: TextController initialisiert');
  }

  @override
  void dispose() {
    AppLogger().log('LoginPage: dispose() aufgerufen');
    _usernameController.dispose();
    _passwordController.dispose();
    AppLogger().log('LoginPage: Controller disposed');
    super.dispose();
  }

  void _handleLogin(BuildContext context) async {
    AppLogger().log('LoginPage: Login-Button gedrückt');
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    AppLogger().log('LoginPage: Login-Versuch für Benutzer: $username');

    final success = await UserManager.instance.login(username, password);
    AppLogger().log('LoginPage: Login-Ergebnis: ${success ? "Erfolgreich" : "Fehlgeschlagen"}');

    if (success) {
      AppLogger().log('LoginPage: Navigation zu /home');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      AppLogger().log('LoginPage: Zeige Fehler-Dialog');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login fehlgeschlagen'),
          content: const Text('Benutzername oder Passwort ist falsch.'),
          actions: [
            TextButton(
              onPressed: () {
                AppLogger().log('LoginPage: Fehler-Dialog geschlossen');
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger().log('LoginPage: build() aufgerufen');
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Anmelden',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _usernameController,
                  decoration: customInputDecoration('Benutzername'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: customInputDecoration('Passwort'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _handleLogin(context),
                  style: customButtonStyle(),
                  child: const Text('Anmelden'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text("Noch kein Konto? Jetzt registrieren"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
