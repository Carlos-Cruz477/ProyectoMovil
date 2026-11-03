import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_hat_business/models/mentor.dart';
import 'package:green_hat_business/screens/mentor_detail_screen.dart';
import 'package:green_hat_business/screens/mentors_screen.dart';
import 'package:green_hat_business/services/api_service.dart';

const sampleMentor = Mentor(id: 'elena', name: 'Elena Rostova', role: 'Mentora',
  headline: 'Angel Investor & Ex-Fundadora Fintech', specialty: 'Impacto & Clima',
  sector: 'Impact Tech & Sustentabilidad', location: 'LatAm / Remoto',
  description: 'Apoyo a fundadores en etapa temprana.', achievement: 'Estrategia de mercado',
  responseTime: '24 h', kind: 'mentor', demo: true);

class FakeMentorApi extends ApiService {
  bool fail = false;
  String? category;
  Map<String, dynamic>? submitted;
  @override
  Future<List<Mentor>> getMentors({String query = '', String category = 'Todos'}) async {
    this.category = category;
    if (fail) throw const ApiException('offline');
    return category == 'B2B SaaS' || (query.isNotEmpty && !sampleMentor.name.contains(query))
      ? [] : [sampleMentor];
  }
  @override
  Future<Mentor> getMentor(String id) async => sampleMentor;
  @override
  Future<void> requestMentor({required String mentorId, required String type,
    required String message, required bool shareReport, Map<String, dynamic>? report}) async {
    if (fail) throw const ApiException('offline');
    submitted = {'mentorId': mentorId, 'type': type, 'message': message,
      'shareReport': shareReport, 'report': report};
  }
}

void main() {
  testWidgets('filters profiles and displays an empty state at mobile width', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = FakeMentorApi();
    addTearDown(api.dispose);
    await tester.pumpWidget(MaterialApp(home: MentorsScreen(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('Elena Rostova'), findsOneWidget);
    await tester.tap(find.text('B2B SaaS'));
    await tester.pumpAndSettle();
    expect(api.category, 'B2B SaaS');
    expect(find.text('No encontramos perfiles'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('report consent starts unchecked and only attaches after authorization', (tester) async {
    final api = FakeMentorApi();
    addTearDown(api.dispose);
    await tester.pumpWidget(MaterialApp(home: MentorDetailScreen(
      mentor: sampleMentor, api: api, report: const {'tam': 1000})));
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value, isFalse);
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enviar Solicitud Confidencial'));
    await tester.tap(find.text('Enviar Solicitud Confidencial'));
    await tester.pumpAndSettle();
    expect(api.submitted!['shareReport'], isTrue);
    expect(api.submitted!['report'], {'tam': 1000});
    expect(find.text('Solicitud registrada'), findsOneWidget);
  });

  testWidgets('failed request stays editable and does not show success', (tester) async {
    final api = FakeMentorApi()..fail = true;
    addTearDown(api.dispose);
    await tester.pumpWidget(MaterialApp(home: MentorDetailScreen(mentor: sampleMentor, api: api)));
    await tester.pumpAndSettle();
    final input = find.byType(TextFormField);
    await tester.ensureVisible(input);
    await tester.enterText(input, '');
    await tester.ensureVisible(find.text('Enviar Solicitud Confidencial'));
    await tester.tap(find.text('Enviar Solicitud Confidencial'));
    await tester.pumpAndSettle();
    expect(find.text('Escribe un mensaje para continuar.'), findsOneWidget);
    await tester.ensureVisible(input);
    await tester.enterText(input, 'Me gustaría recibir consejo.');
    await tester.ensureVisible(find.text('Enviar Solicitud Confidencial'));
    await tester.tap(find.text('Enviar Solicitud Confidencial'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No se pudo registrar'), findsOneWidget);
    expect(find.text('Solicitud registrada'), findsNothing);
  });
}
