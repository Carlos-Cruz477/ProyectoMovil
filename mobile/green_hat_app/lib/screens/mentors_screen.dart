import 'dart:async';
import 'package:flutter/material.dart';
import '../models/mentor.dart';
import '../services/api_service.dart';
import '../widgets/mentor_ui.dart';
import 'mentor_detail_screen.dart';
import 'tam_calculator_screen.dart';

class MentorsScreen extends StatefulWidget {
  const MentorsScreen({this.api, this.report, super.key});
  final ApiService? api;
  final Map<String, dynamic>? report;
  @override
  State<MentorsScreen> createState() => _MentorsScreenState();
}

class _MentorsScreenState extends State<MentorsScreen> {
  late final ApiService _api = widget.api ?? ApiService();
  final _search = TextEditingController();
  Timer? _debounce;
  List<Mentor> _mentors = [];
  String _category = 'Todos';
  bool _loading = true;
  String? _error;
  int _request = 0;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final request = ++_request;
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _api.getMentors(query: _search.text.trim(), category: _category);
      if (mounted && request == _request) setState(() { _mentors = result; _loading = false; });
    } catch (_) {
      if (mounted && request == _request) setState(() {
        _loading = false; _error = 'No pudimos cargar los perfiles. Comprueba tu conexión e inténtalo de nuevo.';
      });
    }
  }
  @override
  void dispose() { _debounce?.cancel(); _search.dispose(); if (widget.api == null) _api.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Theme(data: mentorTheme(context), child: Scaffold(
    appBar: const MentorHeader(),
    bottomNavigationBar: _navigation(),
    body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560),
      child: RefreshIndicator(onRefresh: _load, child: ListView(
        physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const MentorSurface(padding: EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(radius: 20, backgroundColor: Color(0xFF183E43), child: Icon(Icons.verified_user, color: mentorGreen, size: 22)),
            SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                MentorBadge('♧ BÓVEDA GREEN HAT'),
                Text('PRIVACIDAD TOTAL', style: TextStyle(color: mentorMuted, fontSize: 9)),
              ]), SizedBox(height: 6),
              Text('Conecta con expertos que ya construyeron empresas en tu industria. Tus datos solo se compartirán si tú lo autorizas explícitamente.',
                style: TextStyle(fontSize: 12, height: 1.45)),
            ])),
          ])),
          const SizedBox(height: 22),
          TextField(controller: _search, style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(hintText: 'Buscar mentores, fondos o sectores...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _search.text.isEmpty ? null : IconButton(tooltip: 'Borrar búsqueda', icon: const Icon(Icons.close, size: 18),
                onPressed: () { _search.clear(); _debounce?.cancel(); _load(); })),
            onChanged: (_) {
              // Invalidate in-flight results immediately, even before the debounce fires.
              _request++; setState(() {});
              _debounce?.cancel(); _debounce = Timer(const Duration(milliseconds: 300), _load);
            }),
          const SizedBox(height: 12),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            for (final item in [('Todos', Icons.public), ('Impacto & Clima', Icons.eco_outlined), ('B2B SaaS', Icons.domain), ('Seed Stage', Icons.rocket_launch_outlined), ('Ángel Inversionistas', Icons.monetization_on_outlined)])
              Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
                label: Text(item.$1, style: TextStyle(fontSize: 11, color: _category == item.$1 ? mentorBackground : Colors.white)),
                avatar: Icon(item.$2, size: 15, color: _category == item.$1 ? mentorBackground : mentorMuted),
                showCheckmark: false, selected: _category == item.$1, selectedColor: mentorCyan,
                backgroundColor: mentorPanel, side: BorderSide.none,
                shape: const StadiumBorder(), onSelected: (_) { _debounce?.cancel(); setState(() => _category = item.$1); _load(); },
              )),
          ])),
          const SizedBox(height: 18),
          if (_loading) const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()))
          else if (_error != null) MentorSurface(child: Column(children: [
            const Icon(Icons.cloud_off_outlined, color: mentorMuted), const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center), TextButton(onPressed: _load, child: const Text('Reintentar')),
          ]))
          else if (_mentors.isEmpty) const MentorSurface(child: Column(children: [
            Icon(Icons.search_off, color: mentorCyan, size: 32), SizedBox(height: 12),
            Text('No encontramos perfiles'), SizedBox(height: 6),
            Text('Prueba otro nombre, sector o filtro.', style: TextStyle(color: mentorMuted)),
          ]))
          else ...[
            if (_mentors.any((m) => m.demo)) const Padding(padding: EdgeInsets.only(bottom: 12),
              child: Text('PERFILES DE EJEMPLO', style: TextStyle(color: mentorMuted, fontSize: 10, letterSpacing: 1.4))),
            for (final mentor in _mentors) Padding(padding: const EdgeInsets.only(bottom: 16),
              child: _card(mentor)),
          ],
          const SizedBox(height: 8),
          const MentorSurface(padding: EdgeInsets.all(16), child: MentorPrivacyNote()),
        ],
      )),
    ))),
  ));

  Widget _card(Mentor mentor) => MentorSurface(padding: const EdgeInsets.all(16), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(borderRadius: BorderRadius.circular(12), onTap: () => _open(mentor), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MentorAvatar(mentor: mentor, radius: 24), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(mentor.name, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4), Text(mentor.headline, style: const TextStyle(color: mentorCyan, fontSize: 12, height: 1.4)),
          const SizedBox(height: 3),
          Text(mentor.isInvestor ? mentor.achievement : mentor.description, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: mentorMuted, fontSize: 12)),
        ])), const SizedBox(width: 5),
        MentorBadge(mentor.role, color: mentor.isInvestor ? mentorCyan : mentorGreen),
      ])),
      const SizedBox(height: 14),
      if (mentor.isInvestor) Row(children: [
        Expanded(child: _stat(Icons.payments_outlined, 'TICKET MÍN.', mentor.ticket ?? 'Por consultar')),
        const SizedBox(width: 8), Expanded(child: _stat(Icons.verified_outlined, 'ENFOQUE', mentor.sector)),
      ]) else Wrap(spacing: 12, runSpacing: 8, children: [
        Text('♧ ${mentor.achievement}', style: const TextStyle(color: mentorGreen, fontSize: 10)),
        Text('◷ ${mentor.responseTime}', style: const TextStyle(color: mentorMuted, fontSize: 10)),
      ]),
      const SizedBox(height: 18),
      MentorAction(label: mentor.isInvestor ? 'Presentar pitch con permiso' : 'Solicitar feedback confidencial',
        icon: mentor.isInvestor ? Icons.present_to_all_outlined : Icons.lock_outline,
        secondary: mentor.isInvestor, onPressed: () => _open(mentor)),
    ],
  ));

  Widget _stat(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: mentorInset, borderRadius: BorderRadius.circular(8)),
    child: Row(children: [Icon(icon, color: mentorGreen, size: 18), const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 8, color: mentorMuted)), const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ])),
    ]),
  );
  void _open(Mentor mentor) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) =>
    MentorDetailScreen(mentor: mentor, api: _api, report: widget.report)));

  Widget _navigation() => SafeArea(child: Center(heightFactor: 1, child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 420), child: Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 12), padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: mentorPanel, borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: .05))),
      child: Row(children: [
        _navItem(Icons.rocket_launch_outlined, 'Validar', () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const TamCalculatorScreen()))),
        _navItem(Icons.bar_chart, 'Métricas', _showMetrics),
        _navItem(Icons.groups_outlined, 'Mentores', null, active: true),
        _navItem(Icons.account_circle_outlined, 'Perfil', () => Navigator.of(context).popUntil((r) => r.isFirst)),
      ]),
    ),
  )));
  void _showMetrics() => showModalBottomSheet<void>(context: context,
    backgroundColor: mentorPanel, showDragHandle: true,
    builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(
      mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tus métricas', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Text(widget.report == null ? 'Genera tu reporte en la calculadora de mercado para consultar tus métricas.'
          : 'Reporte de ejemplo · ${widget.report!['sector']} · ${widget.report!['market']}',
          style: const TextStyle(color: mentorMuted, height: 1.5)),
        if (widget.report != null) ...[
          const SizedBox(height: 16),
          for (final key in ['tam', 'sam', 'som']) Padding(padding: const EdgeInsets.only(bottom: 8),
            child: Text('${key.toUpperCase()}: ${widget.report![key]} USD', style: const TextStyle(color: mentorCyan))),
        ],
      ],
    ))));

  Widget _navItem(IconData icon, String label, VoidCallback? onTap, {bool active = false}) => Expanded(child: Semantics(
    selected: active, button: true, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(25),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 21, color: active ? mentorCyan : mentorMuted), const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 10, color: active ? mentorCyan : Colors.white,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
      ])),
    ),
  ));
}
