import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _showSignUp = false;

  void _openLogin() => setState(() => _showSignUp = false);
  void _openSignUp() => setState(() => _showSignUp = true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Green Hat',
            style: Theme.of(context).textTheme.headlineLarge),
        backgroundColor: const Color(0xFF1D6254),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: _showSignUp
                  ? SignupScreen(onLoginTap: _openLogin)
                  : LoginScreen(onSignUpTap: _openSignUp),
            ),
          ),
        ),
      ),
    );
  }
}
