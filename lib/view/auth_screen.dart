import 'package:eventgate_flutter/view/auth/login_form.dart';
import 'package:eventgate_flutter/view/auth/register_form.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthTabs { login, register }

class _AuthScreenState extends State<AuthScreen> {
  AuthTabs selectedTab = AuthTabs.login;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to EventGate'),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 27,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SegmentedButton<AuthTabs>(
              segments: const <ButtonSegment<AuthTabs>>[
                ButtonSegment<AuthTabs>(
                  value: AuthTabs.login,
                  label: Text('Login'),
                  icon: Icon(Icons.fingerprint_outlined),
                ),
                ButtonSegment<AuthTabs>(
                  value: AuthTabs.register,
                  label: Text('Register'),
                  icon: Icon(Icons.app_registration_outlined),
                ),
              ],
              selected: <AuthTabs>{selectedTab},
              onSelectionChanged: (Set<AuthTabs> newSelection) {
                setState(() {
                  selectedTab = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
                child: Center(
              child: selectedTab == AuthTabs.login
                  ? const LoginForm()
                  : const RegisterForm(),
            )),
          ],
        ),
      ),
    );
  }
}
