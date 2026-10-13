import 'package:flutter/material.dart';

import '../main.dart';

class TamReportScreen extends StatefulWidget {
  const TamReportScreen({
    required this.sector,
    required this.market,
    super.key,
  });

  final String sector;
  final String market;

  @override
  State<TamReportScreen> createState() => _TamReportScreenState();
}

class _TamReportScreenState extends State<TamReportScreen> {
  bool _shareWithMentors = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        title: const Text('Reporte TAM SAM SOM',
            style: TextStyle(color: ink, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.sector} · ${widget.market}',
                  style: const TextStyle(color: muted, fontSize: 15)),
              const SizedBox(height: 4),
              const Text('Estimación para el año 1-2',
                  style: TextStyle(color: muted, fontSize: 13)),
              const SizedBox(height: 20),
              // Valores de mockup, el cálculo real todavía no está hecho
              const _MarketCard(
                number: '1',
                title: 'TAM · Mercado total',
                value: '\$1.4B',
                description: 'Mercado total disponible para tu sector.',
              ),
              const _MarketCard(
                number: '2',
                title: 'SAM · Mercado alcanzable',
                value: '\$180M',
                description:
                    'La parte del mercado que tu modelo puede atender.',
              ),
              const _MarketCard(
                number: '3',
                title: 'SOM · Mercado obtenible',
                value: '\$16.5M',
                description: 'Lo que podrías capturar en los primeros 2 años.',
                highlighted: true,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE4EBE5)),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _shareWithMentors,
                  activeTrackColor: forest,
                  onChanged: (value) =>
                      setState(() => _shareWithMentors = value),
                  title: const Text('Compartir con mentores o inversionistas',
                      style: TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  subtitle: const Text('Únicamente con tu consentimiento',
                      style: TextStyle(color: muted, fontSize: 12)),
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Esta función estará disponible pronto.')),
                  );
                },
                child: const Text('Conectar con mentores o inversionistas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  const _MarketCard({
    required this.number,
    required this.title,
    required this.value,
    required this.description,
    this.highlighted = false,
  });

  final String number;
  final String title;
  final String value;
  final String description;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: highlighted ? mint : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: highlighted ? forest : const Color(0xFFE4EBE5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: highlighted ? forest : const Color(0xFFF0F6F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(number,
                style: TextStyle(
                    color: highlighted ? Colors.white : forest,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: ink, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Text(description,
                    style: const TextStyle(color: muted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(value,
              style: const TextStyle(
                  color: ink, fontWeight: FontWeight.w900, fontSize: 18)),
        ],
      ),
    );
  }
}
