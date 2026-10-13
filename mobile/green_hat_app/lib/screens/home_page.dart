import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/account_provider.dart';
import '../widgets/account_detail.dart';
import 'tam_calculator_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>().account!;
    final firstName = account.name.trim().split(RegExp(r'\s+')).first;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        title: const Row(children: [
          Icon(Icons.spa_rounded, color: forest, size: 25),
          SizedBox(width: 8),
          Text('Green Hat',
              style: TextStyle(color: ink, fontWeight: FontWeight.w900)),
        ]),
        actions: [
          TextButton.icon(
            onPressed: () async {
              try {
                await context.read<AccountProvider>().logOut();
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('No se pudo cerrar la sesión.')),
                  );
                }
              }
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Cerrar sesión'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                        color: mint, borderRadius: BorderRadius.circular(19)),
                    child: const Icon(Icons.waving_hand_rounded,
                        color: forest, size: 29),
                  ),
                  const SizedBox(height: 24),
                  Text('¡Ya estás dentro, $firstName!',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 10),
                  const Text(
                    'Has iniciado sesión. Aquí puedes consultar los datos de tu cuenta.',
                    style: TextStyle(color: muted, fontSize: 15, height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE4EBE5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TU CUENTA',
                            style: TextStyle(
                                color: muted,
                                letterSpacing: 1.4,
                                fontSize: 11,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 22),
                        AccountDetail(
                            icon: Icons.person_outline,
                            label: 'Nombre',
                            value: account.name),
                        const Divider(height: 30),
                        AccountDetail(
                            icon: Icons.storefront_outlined,
                            label: 'Área de empresa',
                            value: account.businessSector),
                        const Divider(height: 30),
                        AccountDetail(
                            icon: Icons.calendar_today_outlined,
                            label: 'Cuenta creada',
                            value: _formatDate(account.createdAt)),
                        const Divider(height: 30),
                        const AccountDetail(
                            icon: Icons.verified_user_outlined,
                            label: 'Sesión',
                            value: 'Sesión iniciada',
                            valueColor: forest),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const TamCalculatorScreen()),
                    ),
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Text('Calcular tamaño de mercado'),
                  ),
                  const SizedBox(height: 20)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
