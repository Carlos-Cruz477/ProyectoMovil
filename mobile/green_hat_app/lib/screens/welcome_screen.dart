import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../services/api_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    required this.userName,
    required this.onContinue,
    super.key,
  });

  final String userName;
  final Future<void> Function(String) onContinue;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const _stages = [
    _ProjectStage(
      id: 'idea',
      title: 'Tengo una idea en mente',
      description: 'Aún estoy definiendo el problema que quiero resolver.',
      icon: Icons.lightbulb_outline,
    ),
    _ProjectStage(
      id: 'prototype',
      title: 'Creando el primer prototipo',
      description: 'Estoy construyendo y probando una primera versión.',
      icon: Icons.code,
    ),
    _ProjectStage(
      id: 'traction',
      title: 'Buscando primeros clientes',
      description: 'Ya tengo una solución y quiero validar su mercado.',
      icon: Icons.trending_up,
    ),
  ];

  String? _selectedStage;

  Future<void> _continue() async {
    final stage = _selectedStage;
    if (stage == null || context.read<AccountProvider>().isBusy) return;

    try {
      await widget.onContinue(stage);
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
        content: Text(message,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AccountProvider>().isBusy;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Icon(Icons.spa_rounded, color: colors.primary, size: 25),
            const SizedBox(width: 8),
            Text(
              'Green Hat',
              style: textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCelebration(colors, textTheme, widget.userName),
                  const SizedBox(height: 28),
                  Text(
                    '¿En qué etapa está tu proyecto?',
                    style: textTheme.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Elige la opción que mejor describa tu situación actual.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  for (final stage in _stages) ...[
                    _StageTile(
                      stage: stage,
                      selected: _selectedStage == stage.id,
                      onTap: () => setState(() => _selectedStage = stage.id),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 18),
                  _buildQuickRoute(colors, textTheme),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed:
                        _selectedStage == null || busy ? null : _continue,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (busy) ...[
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                            busy ? 'Guardando etapa...' : 'Comenzar a validar'),
                        if (!busy) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ],
                    ),
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

Widget _buildCelebration(
  ColorScheme colors,
  TextTheme textTheme,
  String userName,
) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      color: colors.primary,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Cuenta creada con éxito!',
                    style: textTheme.titleSmall?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '¡Bienvenido a Green Hat, $userName!',
                    style: textTheme.headlineMedium?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Valida tu proyecto con datos reales antes de arriesgar tu capital.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(19),
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: colors.primary,
                size: 29,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Icon(Icons.lock_outline, size: 16, color: colors.onPrimary),
            const SizedBox(width: 6),
            Text(
              'Tus datos están seguros con nosotros',
              style: textTheme.labelMedium?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildQuickRoute(ColorScheme colors, TextTheme textTheme) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: colors.secondaryContainer,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bolt, color: colors.onSecondaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ruta en menos de 10 pasos',
                style: textTheme.titleMedium?.copyWith(
                  color: colors.onSecondaryContainer,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const _QuickRouteItem(
          number: '1',
          title: 'Valida la idea en segundos',
          detail: 'Estima TAM, SAM y SOM con referencia de mercado',
        ),
        const SizedBox(height: 12),
        const _QuickRouteItem(
          number: '2',
          title: 'Consulta tus reportes cuando quieras',
          detail: 'Ten tus métricas recientes disponibles',
        ),
        const SizedBox(height: 12),
        _QuickRouteItem(
          icon: Icons.verified_user_outlined,
          title: 'Mantén control de tus datos',
          detail: 'Tus hipótesis no se comparten sin tu consentimiento',
          iconColor: colors.onSecondaryContainer,
        ),
      ],
    ),
  );
}

class _ProjectStage {
  const _ProjectStage({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
}

class _StageTile extends StatelessWidget {
  const _StageTile({
    required this.stage,
    required this.selected,
    required this.onTap,
  });

  final _ProjectStage stage;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: selected ? colors.primaryContainer : colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? colors.primary : colors.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(stage.icon, color: colors.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.title,
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(stage.description, style: textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: colors.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickRouteItem extends StatelessWidget {
  const _QuickRouteItem({
    required this.title,
    required this.detail,
    this.number,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String detail;
  final String? number;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (number != null)
          CircleAvatar(
            radius: 14,
            backgroundColor: colors.surface,
            child: Text(
              number!,
              style: textTheme.labelMedium?.copyWith(color: colors.primary),
            ),
          )
        else
          SizedBox(
            width: 28,
            height: 28,
            child: Icon(icon, color: iconColor ?? colors.primary, size: 20),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  color: colors.onSecondaryContainer,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                style: textTheme.bodySmall
                    ?.copyWith(color: colors.onSecondaryContainer),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
