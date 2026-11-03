import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mentor.dart';
import '../services/api_service.dart';
import '../widgets/mentor_ui.dart';

class MentorDetailScreen extends StatefulWidget {
  const MentorDetailScreen(
      {required this.mentor, required this.api, this.report, super.key});
  final Mentor mentor;
  final ApiService api;
  final Map<String, dynamic>? report;
  @override
  State<MentorDetailScreen> createState() => _MentorDetailScreenState();
}

class _MentorDetailScreenState extends State<MentorDetailScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _message;
  late Mentor _mentor;
  late String _type;
  bool _shareReport = false;
  bool _sending = false;
  bool _sent = false;
  bool _edited = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mentor = widget.mentor;
    _type = _mentor.isInvestor ? 'pitch' : 'feedback';
    _message = TextEditingController(text: _suggestion(_type));
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    try {
      final mentor = await widget.api.getMentor(widget.mentor.id);
      if (mounted) setState(() => _mentor = mentor);
    } catch (_) {
      // The list already supplied a complete profile; keep it if refresh fails.
    }
  }

  String _suggestion(String type) {
    final name = _mentor.name.split(' ').first;
    return switch (type) {
      'mentoring' =>
        'Hola $name, admiro tu trayectoria. Me gustaría solicitar mentoría de arranque para desarrollar mi idea y definir mis próximos pasos.',
      'pitch' =>
        'Hola $name, estoy preparando mi proyecto para una ronda de inversión. Me gustaría presentarte nuestra propuesta y conocer tu perspectiva.',
      _ =>
        'Hola $name, estoy validando mi idea en Green Hat y me gustaría recibir tu consejo sobre mi mercado y modelo de negocio.',
    };
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending || _sent || !_form.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.api.requestMentor(
          mentorId: _mentor.id,
          type: _type,
          message: _message.text.trim(),
          shareReport: _shareReport,
          report: _shareReport ? widget.report : null);
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        content: Text(
            'Solicitud registrada. Puedes volver al listado de mentores.',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer)),
      ));
    } catch (_) {
      if (mounted) {
        setState(() {
          _sending = false;
          _error =
              'No se pudo registrar la solicitud. Revisa tu conexión o inicia sesión de nuevo y vuelve a intentarlo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
      data: mentorTheme(context),
      child: Scaffold(
        appBar: const MentorHeader(showBack: true),
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.chevron_left, size: 19),
                            label: Text('Mentores e Inversores',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant))),
                        IconButton(
                            tooltip: 'Copiar nombre del perfil',
                            icon: const Icon(Icons.copy_outlined, size: 19),
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(
                                  text:
                                      '${_mentor.name} · ${_mentor.headline}'));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Nombre y especialidad copiados')));
                              }
                            }),
                      ]),
                  const SizedBox(height: 12),
                  MentorSurface(
                      padding: const EdgeInsets.all(24),
                      child: Column(children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MentorAvatar(mentor: _mentor, radius: 36),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(_mentor.name,
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily:
                                                      'PlusJakartaSans')),
                                          if (_mentor.verified)
                                            const MentorBadge('VERIFICADO')
                                          else if (_mentor.demo)
                                            const MentorBadge('EJEMPLO'),
                                        ]),
                                    const SizedBox(height: 6),
                                    Text(_mentor.headline,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontSize: 13,
                                            height: 1.5)),
                                    const SizedBox(height: 10),
                                    _info(
                                        Icons.eco_outlined,
                                        _mentor.sector,
                                        Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                    _info(
                                        Icons.location_on_outlined,
                                        _mentor.location,
                                        Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant),
                                  ])),
                            ]),
                        const SizedBox(height: 20),
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLow
                                    .withValues(alpha: .6),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(_mentor.description,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontSize: 12,
                                    height: 1.7))),
                      ])),
                  const SizedBox(height: 24),
                  MentorSurface(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                          key: _form,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Icon(Icons.lock_outline,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            size: 18),
                                        SizedBox(width: 6),
                                        Expanded(
                                            child: Text(
                                                'CONFIDENCIALIDAD\nABSOLUTA',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: .5))),
                                        MentorBadge('Privacidad R5'),
                                      ]),
                                      const SizedBox(height: 10),
                                      Text(
                                          'Tus métricas de mercado y modelo de negocio son estrictamente privados. Ningún dato se comparte sin tu consentimiento previo.',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              height: 1.6)),
                                      const SizedBox(height: 12),
                                      Material(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: CheckboxListTile(
                                            value: _shareReport,
                                            activeColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            checkColor: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 4, vertical: 4),
                                            dense: true,
                                            visualDensity:
                                                VisualDensity.compact,
                                            onChanged: widget.report == null ||
                                                    _sending ||
                                                    _sent
                                                ? null
                                                : (value) => setState(() =>
                                                    _shareReport =
                                                        value ?? false),
                                            title: const Text(
                                                'Autorizar vista de Reporte TAM SAM SOM',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            subtitle: Text(
                                                widget.report == null
                                                    ? 'Primero genera un reporte desde la calculadora. Puedes solicitar consejo sin compartir datos.'
                                                    : 'Adjunta a esta solicitud una copia de tu reporte para ${_mentor.name.split(' ').first}.',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                    height: 1.4)),
                                          )),
                                    ]),
                              ),
                              const SizedBox(height: 20),
                              const Text('Tipo de Solicitud',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(children: [
                                    for (final option in [
                                      (
                                        'feedback',
                                        'Feedback de Mercado',
                                        Icons.insights
                                      ),
                                      (
                                        'mentoring',
                                        'Mentoría de Arranque',
                                        Icons.support_agent
                                      ),
                                      (
                                        'pitch',
                                        'Exploración Pre-Seed',
                                        Icons.monetization_on_outlined
                                      )
                                    ])
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: ChoiceChip(
                                            label: Text(option.$2,
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: _type == option.$1
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant)),
                                            avatar: Icon(option.$3,
                                                size: 15,
                                                color: _type == option.$1
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant),
                                            showCheckmark: false,
                                            selected: _type == option.$1,
                                            selectedColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            side: BorderSide.none,
                                            shape: const StadiumBorder(),
                                            onSelected: _sending || _sent
                                                ? null
                                                : (_) => setState(() {
                                                      _type = option.$1;
                                                      if (!_edited) {
                                                        _message.text =
                                                            _suggestion(_type);
                                                      }
                                                    }),
                                          )),
                                  ])),
                              const SizedBox(height: 20),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Mensaje introductorio',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                    if (!_edited)
                                      Text('ϟ Autogenerado',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary)),
                                  ]),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _message,
                                enabled: !_sending && !_sent,
                                minLines: 3,
                                maxLines: 6,
                                maxLength: 240,
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    height: 1.7),
                                decoration: InputDecoration(
                                    hintText: 'Escribe un mensaje breve...',
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLow,
                                    counterStyle: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
                                onChanged: (_) =>
                                    setState(() => _edited = true),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Escribe un mensaje para continuar.'
                                        : null,
                              ),
                              if (_error != null)
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Text(_error!,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            fontSize: 12))),
                              const SizedBox(height: 16),
                              MentorAction(
                                  label: _sent
                                      ? 'Solicitud registrada'
                                      : _sending
                                          ? 'Registrando solicitud...'
                                          : 'Enviar Solicitud Confidencial',
                                  icon: _sent
                                      ? Icons.check_circle_outline
                                      : Icons.lock,
                                  gradient: true,
                                  loading: _sending,
                                  onPressed:
                                      _sent || _sending ? null : _submit),
                              const SizedBox(height: 16),
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.security,
                                        size: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                    SizedBox(width: 6),
                                    Expanded(
                                        child: Text(
                                            'Tus datos se adjuntan únicamente con tu autorización explícita.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                height: 1.5))),
                                  ]),
                              if (_mentor.demo)
                                Padding(
                                    padding: EdgeInsets.only(top: 12),
                                    child: Text(
                                        'Perfil de ejemplo. La solicitud se registra en Green Hat; no se envía a una persona real.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            fontSize: 10,
                                            height: 1.5))),
                            ],
                          ))),
                ],
              )),
        ))),
      ));
  Widget _info(IconData icon, String label, Color color) => Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11))),
        ],
      ));
}
