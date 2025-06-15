import 'package:flutter/material.dart';
import 'package:laendle_guessr/services/api_service.dart';
import 'package:laendle_guessr/services/user_service.dart';
import 'ui_components.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedCity;
  bool _isLoading = false;

  final List<String> _cities = [
    'Bregenz',
    'Dornbirn',
    'Feldkirch',
    'Bludenz',
    'Hohenems',
  ];

  int _getCityId(String cityName) {
    return _cities.indexOf(cityName);
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final username = _usernameController.text;
      final password = _passwordController.text;
      final cityId = _getCityId(_selectedCity!);

      try {
        final userService = UserService();

        final response = await userService.registerUser(
          username: username,
          password: password,
          city: cityId,
          coins: 0,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrierung erfolgreich!')),
        );

        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Registrieren',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _usernameController,
                    decoration: customInputDecoration('Benutzername'),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Benutzername erforderlich' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: customInputDecoration('Passwort'),
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'Passwort muss mindestens 8 Zeichen haben';
                      }
                      if (value.contains(' ')) {
                        return 'Passwort darf keine Leerzeichen enthalten';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: customInputDecoration('Stadt'),
                    items: _cities
                        .map((city) =>
                        DropdownMenuItem(value: city, child: Text(city)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedCity = value),
                    validator: (value) =>
                    value == null ? 'Bitte eine Stadt auswählen' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: customButtonStyle(),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Registrieren'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text("Schon ein Konto? Jetzt anmelden"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
