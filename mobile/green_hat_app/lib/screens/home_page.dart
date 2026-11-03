import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/account.dart';
import '../providers/account_provider.dart';
import '../widgets/account_detail.dart';
import 'mentors_screen.dart';
import 'tam_calculator_screen.dart';

TextStyle _sectionTitle(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
    fontFamily: 'PlusJakartaSans',
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -.4);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openCalculator(BuildContext context) => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TamCalculatorScreen()));

  void _openAccount(BuildContext context, Account account) {
    final provider = context.read<AccountProvider>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) => SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tu cuenta', style: _sectionTitle(context)),
              const SizedBox(height: 24),
              AccountDetail(
                  icon: Icons.person_outline,
                  label: 'Nombre',
                  value: account.name),
              const Divider(height: 28),
              AccountDetail(
                  icon: Icons.mail_outline,
                  label: 'Correo',
                  value: account.email),
              const Divider(height: 28),
              AccountDetail(
                  icon: Icons.storefront_outlined,
                  label: 'Área de empresa',
                  value: account.businessSector),
              const Divider(height: 28),
              AccountDetail(
                  icon: Icons.calendar_today_outlined,
                  label: 'Cuenta creada',
                  value: _formatDate(account.createdAt)),
              const SizedBox(height: 28),
              SizedBox(
                  width: double.infinity,
                  child: ListenableBuilder(
                      listenable: provider,
                      builder: (_, __) => OutlinedButton.icon(
                            onPressed: provider.isBusy
                                ? null
                                : () async {
                                    try {
                                      await provider.logOut();
                                      if (sheetContext.mounted) {
                                        Navigator.of(sheetContext).pop();
                                      }
                                    } catch (_) {
                                      if (sheetContext.mounted) {
                                        ScaffoldMessenger.of(sheetContext)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'No se pudo cerrar la sesión. Inténtalo de nuevo.')));
                                      }
                                    }
                                  },
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: Text(provider.isBusy
                                ? 'Cerrando sesión...'
                                : 'Cerrar sesión'),
                          ))),
            ]),
      )),
    );
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic'
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>().account;
    if (account == null) return const SizedBox.shrink();
    final name = account.name.trim();
    final firstName =
        name.isEmpty ? 'emprendedor' : name.split(RegExp(r'\s+')).first;
    final stage = switch (account.projectStage) {
      'idea' => 'Idea en desarrollo',
      'prototype' => 'Primer prototipo',
      'traction' => 'Primeros clientes',
      _ => 'Por definir',
    };
    final nextStep = switch (account.projectStage) {
      'prototype' => (
          'Pon a prueba tu propuesta',
          'Explora el mercado al que quieres llevar tu prototipo y contrasta tus hipótesis.'
        ),
      'traction' => (
          'Encuentra tu oportunidad de crecer',
          'Revisa tu mercado objetivo y busca una perspectiva experta para tus próximos pasos.'
        ),
      _ => (
          'Dale forma a tu oportunidad',
          'Empieza por explorar el sector, el modelo de ingresos y el mercado de tu idea.'
        ),
    };
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 76,
        titleSpacing: 24,
        title: Row(children: [
          Icon(Icons.spa_rounded,
              color: Theme.of(context).colorScheme.primary, size: 30),
          SizedBox(width: 10),
          Flexible(
              child: Text('Green Hat',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 21,
                      fontWeight: FontWeight.w800))),
        ]),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 24),
              child: IconButton.filledTonal(
                tooltip: 'Ver mi cuenta',
                style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.primary),
                onPressed: () => _openAccount(context, account),
                icon: const Icon(Icons.person_outline_rounded),
              ))
        ],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TU ESPACIO PARA CRECER',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.8)),
                    const SizedBox(height: 10),
                    Text('Hola, $firstName 👋',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1)),
                    const SizedBox(height: 8),
                    Text('Una gran idea empieza con el siguiente paso.',
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 14,
                            height: 1.5)),
                    const SizedBox(height: 28),
                    _MarketHero(onPressed: () => _openCalculator(context)),
                    const SizedBox(height: 28),
                    Text('Tu proyecto, en contexto',
                        style: _sectionTitle(context)),
                    const SizedBox(height: 14),
                    LayoutBuilder(builder: (context, constraints) {
                      final width = constraints.maxWidth < 360
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 12) / 2;
                      return Wrap(spacing: 12, runSpacing: 12, children: [
                        SizedBox(
                            width: width,
                            child: _ContextCard(
                                icon: Icons.storefront_outlined,
                                label: 'TU SECTOR',
                                value: account.businessSector)),
                        SizedBox(
                            width: width,
                            child: _ContextCard(
                                icon: Icons.eco_outlined,
                                label: 'ETAPA ACTUAL',
                                value: stage)),
                      ]);
                    }),
                    const SizedBox(height: 30),
                    Text('Herramientas para avanzar',
                        style: _sectionTitle(context)),
                    const SizedBox(height: 6),
                    Text('Explora, aprende y conecta a tu ritmo.',
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 13)),
                    const SizedBox(height: 16),
                    LayoutBuilder(builder: (context, constraints) {
                      final width = constraints.maxWidth < 680
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 16) / 2;
                      return Wrap(spacing: 16, runSpacing: 12, children: [
                        SizedBox(
                            width: width,
                            child: _ToolCard(
                                icon: Icons.donut_large_rounded,
                                title: 'Explora tu mercado',
                                description:
                                    'Conoce TAM, SAM y SOM con un reporte de ejemplo para tu idea.',
                                action: 'Abrir calculadora',
                                onTap: () => _openCalculator(context))),
                        SizedBox(
                            width: width,
                            child: _ToolCard(
                                icon: Icons.groups_outlined,
                                title: 'Conecta con experiencia',
                                description:
                                    'Explora la red de mentores e inversores y solicita una nueva perspectiva.',
                                action: 'Explorar mentores',
                                tinted: true,
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const MentorsScreen())))),
                      ]);
                    }),
                    const SizedBox(height: 28),
                    _Surface(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.route_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 26),
                              const SizedBox(width: 14),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text('TU SIGUIENTE PASO',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2)),
                                    const SizedBox(height: 8),
                                    Text(nextStep.$1,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 6),
                                    Text(nextStep.$2,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            fontSize: 13,
                                            height: 1.6)),
                                  ])),
                            ])),
                    const SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.lock_outline_rounded,
                          size: 14,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      SizedBox(width: 7),
                      Flexible(
                          child: Text('Tú decides cuándo compartir tus datos.',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: 11))),
                    ]),
                  ],
                ))),
      )),
    );
  }
}

class _MarketHero extends StatelessWidget {
  const _MarketHero({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => _Surface(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: LayoutBuilder(builder: (context, constraints) {
        final content =
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('DE LA IDEA A LA OPORTUNIDAD',
                  style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.secondaryContainer),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1))),
          const SizedBox(height: 20),
          Text('Conoce el potencial\nde tu mercado.',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 29,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.8)),
          const SizedBox(height: 12),
          Text(
              'Explora tu oportunidad y empieza a hacer las preguntas que impulsarán tu negocio.',
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withValues(alpha: .8),
                  fontSize: 13,
                  height: 1.7)),
          const SizedBox(height: 22),
          FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSecondary
                          : Theme.of(context).colorScheme.onSecondaryContainer,
                  minimumSize: const Size(0, 50),
                  padding: const EdgeInsets.symmetric(horizontal: 18)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Flexible(child: Text('Explorar mi mercado')),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward_rounded, size: 18)
              ])),
        ]);
        if (constraints.maxWidth < 680) return content;
        return Row(children: [
          Expanded(flex: 3, child: content),
          const SizedBox(width: 36),
          Expanded(
              flex: 2,
              child: ExcludeSemantics(
                  child: Container(
                height: 220,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.insights_rounded,
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer),
                          size: 30),
                      const Spacer(),
                      Expanded(
                          flex: 3,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                for (final height in [
                                  0.3,
                                  0.5,
                                  0.42,
                                  0.72,
                                  1.0
                                ])
                                  Expanded(
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: FractionallySizedBox(
                                              heightFactor: height,
                                              child: DecoratedBox(
                                                  decoration: BoxDecoration(
                                                      color: (Theme.of(context)
                                                                      .brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary
                                                              : Theme.of(context)
                                                                  .colorScheme
                                                                  .secondaryContainer)
                                                          .withValues(
                                                              alpha: height),
                                                      borderRadius:
                                                          BorderRadius.circular(5)))))),
                              ])),
                    ]),
              ))),
        ]);
      }));
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child, this.color});
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
      child: child);
}

class _ContextCard extends StatelessWidget {
  const _ContextCard(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) => _Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 23),
        const SizedBox(height: 16),
        Text(label,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
        const SizedBox(height: 7),
        Text(value,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.4)),
      ]));
}

class _ToolCard extends StatelessWidget {
  const _ToolCard(
      {required this.icon,
      required this.title,
      required this.description,
      required this.action,
      required this.onTap,
      this.tinted = false});
  final IconData icon;
  final String title, description, action;
  final VoidCallback onTap;
  final bool tinted;

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
              color: tinted
                  ? Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withValues(alpha: .4)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
                backgroundColor: tinted
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(context).colorScheme.primary,
                radius: 23,
                child: Icon(icon, size: 23)),
            const SizedBox(height: 18),
            Text(title,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(description,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.6)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: Text(action,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700))),
              Icon(Icons.arrow_forward_rounded,
                  color: Theme.of(context).colorScheme.primary, size: 19)
            ]),
          ]),
        ),
      ));
}
