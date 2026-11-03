import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_hat_business/main.dart';
import 'package:green_hat_business/models/account.dart';
import 'package:green_hat_business/providers/account_provider.dart';
import 'package:green_hat_business/screens/home_page.dart';
import 'package:green_hat_business/screens/tam_calculator_screen.dart';
import 'package:provider/provider.dart';

class DashboardAccount extends AccountProvider {
  DashboardAccount({String stage = 'prototype', bool authenticated = true}) {
    current = authenticated
        ? Account(
            id: 'test',
            email: 'ana@example.com',
            name: 'Ana López',
            businessSector: 'Technology',
            projectStage: stage,
            createdAt: DateTime.utc(2026, 10, 12, 12),
          )
        : null;
  }

  Account? current;
  bool failLogout = false;

  @override
  Account? get account => current;
  @override
  bool get isCheckingSession => false;
  @override
  bool get needsWelcome => false;

  @override
  Future<void> logOut() async {
    if (failLogout) throw Exception('offline');
    current = null;
    notifyListeners();
  }
}

Future<void> openApp(WidgetTester tester, DashboardAccount account) async {
  await tester.pumpWidget(ChangeNotifierProvider<AccountProvider>.value(
    value: account,
    child: const GreenHatApp(),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Una sesión sin cuenta muestra el inicio de sesión',
      (tester) async {
    final account = DashboardAccount(authenticated: false);
    addTearDown(account.dispose);
    await openApp(tester, account);
    expect(find.byType(HomePage), findsNothing);
    expect(find.text('Tu correo'), findsOneWidget);
  });

  for (final width in [320.0, 390.0, 1200.0]) {
    testWidgets('Dashboard personalizado sin desbordamientos a $width px',
        (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final account = DashboardAccount();
      addTearDown(account.dispose);
      await openApp(tester, account);
      expect(find.text('Hola, Ana 👋'), findsOneWidget);
      expect(find.text('Technology'), findsOneWidget);
      expect(find.text('Primer prototipo'), findsOneWidget);
      await tester.ensureVisible(find.text('Pon a prueba tu propuesta'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  for (final stage in ['idea', 'prototype', 'traction']) {
    testWidgets('La etapa $stage tiene una sugerencia propia', (tester) async {
      final account = DashboardAccount(stage: stage);
      addTearDown(account.dispose);
      await openApp(tester, account);
      final title = switch (stage) {
        'idea' => 'Dale forma a tu oportunidad',
        'prototype' => 'Pon a prueba tu propuesta',
        _ => 'Encuentra tu oportunidad de crecer',
      };
      await tester.ensureVisible(find.text(title));
      expect(find.text(title), findsOneWidget);
    });
  }

  for (final label in ['Explorar mi mercado', 'Abrir calculadora']) {
    testWidgets('$label abre la calculadora y permite volver', (tester) async {
      final account = DashboardAccount();
      addTearDown(account.dispose);
      await openApp(tester, account);
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.byType(TamCalculatorScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });
  }

  testWidgets('El perfil muestra la cuenta y permite cerrar la sesión',
      (tester) async {
    final account = DashboardAccount();
    addTearDown(account.dispose);
    await openApp(tester, account);
    await tester.tap(find.byTooltip('Ver mi cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Ana López'), findsOneWidget);
    expect(find.text('ana@example.com'), findsOneWidget);
    await tester.ensureVisible(find.text('Cerrar sesión'));
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsNothing);
    expect(find.text('Tu correo'), findsOneWidget);
    expect(find.text('Tu cuenta'), findsNothing);
  });

  testWidgets('Si falla el cierre de sesión la cuenta sigue accesible',
      (tester) async {
    final account = DashboardAccount()..failLogout = true;
    addTearDown(account.dispose);
    await openApp(tester, account);
    await tester.tap(find.byTooltip('Ver mi cuenta'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cerrar sesión'));
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('No se pudo cerrar la sesión. Inténtalo de nuevo.'),
        findsOneWidget);
    expect(account.account, isNotNull);
    expect(find.text('Tu cuenta'), findsOneWidget);
  });
}
