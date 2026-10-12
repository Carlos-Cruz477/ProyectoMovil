import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/account_provider.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({required this.onLoginTap, super.key});
  final VoidCallback onLoginTap;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _sector;
  bool _hidePassword = true;
  bool _hideConfirm = true;

  static const _sectors = <String>[
    'Technology',
    'Retail & e-commerce',
    'Entertainment & media',
    'Food & beverage',
    'Health & wellness',
    'Professional services',
    'Education',
    'Construction & property',
    'Travel & hospitality',
    'Beauty & personal care',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await context.read<AccountProvider>().signUp(
            email: _emailController.text.trim(),
            name: _nameController.text.trim(),
            password: _passwordController.text,
            businessSector: _sector!,
          );
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    } catch (_) {
      if (mounted) {
        _message('Pasó algo inesperado, por favor vuelva a intentar.');
      }
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF8F3636)),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Ingrese su correo';
    if (!RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
      return 'Ingrese un correo válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingrese su contraseña';
    if (value.length < 8) return 'Use al menos 8 caracteres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AccountProvider>().isBusy;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE8EEE9)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D163E31), blurRadius: 35, offset: Offset(0, 15)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Crear cuenta',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Wrap(children: [
              const Text('¿Ya tienes cuenta? '),
              GestureDetector(
                onTap: widget.onLoginTap,
                child: const Text('Iniciar sesión',
                    style: TextStyle(
                        color: forest,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline)),
              ),
            ]),
          ),
          const SizedBox(height: 23),
          Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Tu nombre',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';
                  if (name.isEmpty) return 'Por favor ingresa tu nombre';
                  if (name.length < 2) {
                    return 'El nombre debe tener al menos 2 caracteres';
                  }
                  if (name.length > 60) {
                    return 'El nombre debe tener menos de 60 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Tu correo',
                  prefixIcon: Icon(Icons.mail),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: _hidePassword,
                textInputAction: TextInputAction.next,
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
                validator: _validatePassword,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _confirmController,
                obscureText: _hideConfirm,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: const Icon(Icons.verified_user_outlined),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _hideConfirm = !_hideConfirm),
                    icon: Icon(_hideConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirme su contraseña';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: _sector,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Área de empresa',
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
                hint: const Text('Elija el área de su empresa'),
                items: _sectors
                    .map((sector) => DropdownMenuItem(
                          value: sector,
                          child: Text(sector, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged:
                    busy ? null : (value) => setState(() => _sector = value),
                validator: (value) =>
                    value == null ? 'Elija el área de su empresa' : null,
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: busy ? null : _submit,
                child: busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Crear cuenta'),
                          SizedBox(width: 9),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
