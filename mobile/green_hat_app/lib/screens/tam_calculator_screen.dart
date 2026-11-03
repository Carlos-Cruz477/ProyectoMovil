import 'package:flutter/material.dart';

import 'tam_report_screen.dart';

class TamCalculatorScreen extends StatefulWidget {
  const TamCalculatorScreen({super.key});

  @override
  State<TamCalculatorScreen> createState() => _TamCalculatorScreenState();
}

class _TamCalculatorScreenState extends State<TamCalculatorScreen> {
  // Opciones de mockup, todavía no vienen del servidor
  static const _sectors = [
    'Fintech',
    'Clima & Agro',
    'E-commerce',
    'Salud & Biotech',
    'EduTech',
  ];
  static const _revenueModels = [
    'SaaS / Suscripción',
    'Marketplace',
    'B2B Transaccional',
    'B2C Directo',
  ];
  static const _markets = [
    'México',
    'Colombia',
    'Chile',
    'Latam Regional',
    'Global',
  ];
  static const _tickets = [
    '< \$15',
    '\$15 - \$50',
    '\$50 - \$200',
    'Enterprise',
  ];

  String? _sector;
  String? _revenueModel;
  String? _market;
  String? _ticket;

  bool get _isComplete =>
      _sector != null &&
      _revenueModel != null &&
      _market != null &&
      _ticket != null;

  void _calculate() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TamReportScreen(
          sector: _sector!,
          market: _market!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text('Calculadora TAM',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Elige una opción por sección para estimar el tamaño de tu mercado.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 15,
                    height: 1.5),
              ),
              const SizedBox(height: 20),
              _Section(
                title: '1. Sector o nicho',
                options: _sectors,
                selected: _sector,
                onSelected: (value) => setState(() => _sector = value),
              ),
              _Section(
                title: '2. Modelo de ingresos',
                options: _revenueModels,
                selected: _revenueModel,
                onSelected: (value) => setState(() => _revenueModel = value),
              ),
              _Section(
                title: '3. Mercado geográfico inicial',
                options: _markets,
                selected: _market,
                onSelected: (value) => setState(() => _market = value),
              ),
              _Section(
                title: '4. Ticket promedio (USD)',
                options: _tickets,
                selected: _ticket,
                onSelected: (value) => setState(() => _ticket = value),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _isComplete ? _calculate : null,
                child: const Text('Calcular TAM, SAM y SOM'),
              ),
              const SizedBox(height: 10),
              if (!_isComplete)
                Center(
                  child: Text('Completa las 4 secciones para calcular.',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 15)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                ChoiceChip(
                  label: Text(option),
                  selected: selected == option,
                  selectedColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  onSelected: (_) => onSelected(option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
