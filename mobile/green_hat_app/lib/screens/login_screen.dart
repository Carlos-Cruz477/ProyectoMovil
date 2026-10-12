import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/account_provider.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.onSignUpTap, super.key});
  final VoidCallback onSignUpTap;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await context.read<AccountProvider>().logIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    } catch (_) {
      if (mounted) {
        _message('Pasó algo inesperado, por favor vuelva a intentar.');
      }
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Ingrese su correo';
    if (!RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
      return 'Ingrese un correo válido';
    }
    return null;
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF8F3636)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AccountProvider>().isBusy;
    return _AuthCard(
      title: 'Iniciar sesión',
      children: [
        _Prompt(
          prefix: '¿No tienes cuenta? ',
          action: 'Regístrate ahora',
          onTap: widget.onSignUpTap,
        ),
        const SizedBox(height: 23),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Tu correo',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: _validateEmail),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: _hidePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(_hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese su contraseña';
                  }
                  if (value.length < 8) return 'Use al menos 8 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: busy ? null : _submit,
                child: busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFE8EEE9)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D163E31),
                blurRadius: 35,
                offset: Offset(0, 15)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 25),
            ...children,
          ],
        ),
      );
}

class _Prompt extends StatelessWidget {
  const _Prompt({
    required this.prefix,
    required this.action,
    required this.onTap,
  });
  final String prefix;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Wrap(
          children: [
            Text(prefix),
            GestureDetector(
              onTap: onTap,
              child: Text(action,
                  style: const TextStyle(
                    color: forest,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                  )),
            ),
          ],
        ),
      );
}
