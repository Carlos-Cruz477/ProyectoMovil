import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/mentor_ui.dart';
import 'mentors_screen.dart';
import 'tam_calculator_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _mentorAlertsEnabled = true;

  @override
  Widget build(BuildContext context) => Theme(
        data: AppTheme.dark,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            surfaceTintColor: Colors.transparent,
            title: const Text('Perfil',
                style: TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              TextButton(
                onPressed: _showSettings,
                child: const Text('Configuración'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          bottomNavigationBar: _navigation(),
          body: SafeArea(
            child: Consumer<AccountProvider>(
              builder: (context, provider, _) {
                final account = provider.account;
                if (account == null) return const SizedBox.shrink();
                final initials = account.name.trim().isEmpty
                    ? '?'
                    : account.name.trim()[0].toUpperCase();

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                      children: [
                        MentorSurface(
                          padding: const EdgeInsets.all(16),
                          child: Row(children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: const Color(0xFF253F46),
                              child: Text(initials,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(account.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 3),
                                  Text(account.email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontSize: 11)),
                                  const SizedBox(height: 8),
                                  const MentorBadge('EMPRENDEDOR ACTIVO'),
                                ],
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 26),
                        _sectionTitle(
                            'Privacidad y bóveda', Icons.shield_outlined),
                        const SizedBox(height: 10),
                        MentorSurface(
                          padding: EdgeInsets.all(15),
                          child: Row(children: [
                            Icon(Icons.lock_outline,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 19),
                            SizedBox(width: 11),
                            Expanded(
                              child: Text('Ideas 100% privadas',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ),
                            MentorBadge('PRIVACIDAD TOTAL'),
                          ]),
                        ),
                        const SizedBox(height: 26),
                        _sectionTitle(
                            'Cuentas y conexiones', Icons.people_alt_outlined),
                        const SizedBox(height: 10),
                        MentorSurface(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(children: [
                            _InfoRow(
                              icon: Icons.tune_rounded,
                              title: 'Rol de operación',
                              value:
                                  'Fundador / CEO · ${account.businessSector}',
                            ),
                            Divider(
                                height: 1,
                                color: Colors.white.withValues(alpha: .06)),
                            _AlertRow(
                              enabled: _mentorAlertsEnabled,
                              onChanged: (value) =>
                                  setState(() => _mentorAlertsEnabled = value),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: provider.isBusy ? null : _logOut,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFF8290),
                              backgroundColor: const Color(0xFF321827),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28)),
                            ),
                            icon: provider.isBusy
                                ? const SizedBox(
                                    width: 17,
                                    height: 17,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.logout_rounded, size: 17),
                            label: const Text('Cerrar sesión segura'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

  Widget _sectionTitle(String title, IconData icon) => Row(children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 16),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ]);

  Widget _navigation() => SafeArea(
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Row(children: [
                _navItem(Icons.rocket_launch_outlined, 'Validar', () {
                  Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => const TamCalculatorScreen()));
                }),
                _navItem(Icons.bar_chart, 'Métricas', _showMetrics),
                _navItem(Icons.shield_outlined, 'Bóveda', () {
                  Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => const MentorsScreen()));
                }),
                _navItem(Icons.account_circle_outlined, 'Perfil', null,
                    active: true),
              ]),
            ),
          ),
        ),
      );

  Widget _navItem(IconData icon, String label, VoidCallback? onTap,
          {bool active = false}) =>
      Expanded(
        child: Semantics(
          selected: active,
          button: true,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(25),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon,
                    size: 21,
                    color: active
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 5),
                Text(label,
                    style: TextStyle(
                        fontSize: 10,
                        color: active
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.w400)),
              ]),
            ),
          ),
        ),
      );

  void _showMetrics() => showModalBottomSheet<void>(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surface,
        showDragHandle: true,
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Genera tu reporte de mercado para consultar tus métricas.',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface, height: 1.5),
            ),
          ),
        ),
      );

  void _showSettings() => showModalBottomSheet<void>(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surface,
        showDragHandle: true,
        builder: (context) => StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Configuración',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _mentorAlertsEnabled,
                    activeTrackColor: Theme.of(context).colorScheme.secondary,
                    title: const Text('Alertas de mentoría'),
                    subtitle: const Text('Nuevas conexiones afines'),
                    onChanged: (value) {
                      setState(() => _mentorAlertsEnabled = value);
                      setSheetState(() {});
                    },
                  ),
                  Divider(color: Theme.of(context).colorScheme.outlineVariant),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.lock_outline,
                        color: Theme.of(context).colorScheme.secondary),
                    title: Text('Ideas 100% privadas'),
                    subtitle: Text('Solo se comparten con tu autorización.'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Future<void> _logOut() async {
    try {
      await context.read<AccountProvider>().logOut();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo cerrar la sesión.')),
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon,
            color: Theme.of(context).colorScheme.onSurfaceVariant, size: 19),
        title: Text(title, style: const TextStyle(fontSize: 12)),
        subtitle: Text(value,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10)),
        trailing: Icon(Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant, size: 18),
        dense: true,
      );
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(Icons.notifications_active_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant, size: 19),
        title:
            const Text('Alertas de mentoría', style: TextStyle(fontSize: 12)),
        subtitle: Text('Nuevas conexiones afines',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10)),
        trailing: Switch.adaptive(
          value: enabled,
          activeTrackColor: Theme.of(context).colorScheme.secondary,
          onChanged: onChanged,
        ),
        dense: true,
      );
}
