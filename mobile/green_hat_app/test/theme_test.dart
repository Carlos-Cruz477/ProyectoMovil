import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_hat_business/screens/home_page.dart';
import 'package:green_hat_business/screens/mentor_detail_screen.dart';
import 'package:green_hat_business/screens/mentors_screen.dart';
import 'package:green_hat_business/screens/tam_calculator_screen.dart';
import 'package:green_hat_business/screens/tam_report_screen.dart';
import 'package:green_hat_business/theme/app_theme.dart';
import 'package:green_hat_business/widgets/mentor_ui.dart';

import 'mentors_screen_test.dart' show FakeMentorApi, sampleMentor;
import 'widget_test.dart' show DashboardAccount, openApp;

Widget themed(Widget home) => MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: home,
    );

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('Dashboard y perfil respetan el modo $brightness',
        (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final account = DashboardAccount();
      addTearDown(account.dispose);
      await openApp(tester, account);
      final colors = brightness == Brightness.dark
          ? AppTheme.dark.colorScheme
          : AppTheme.light.colorScheme;
      expect(Theme.of(tester.element(find.byType(HomePage))).brightness,
          brightness);
      expect(tester.widget<Text>(find.text('Hola, Ana 👋')).style!.color,
          colors.onSurface);
      await tester.tap(find.byTooltip('Ver mi cuenta'));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.text('Tu cuenta')).style!.color,
          colors.onSurface);
      expect(tester.widget<Text>(find.text('ana@example.com')).style!.color,
          colors.onSurface);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Red y detalle de mentores respetan el modo $brightness',
        (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final api = FakeMentorApi();
      addTearDown(api.dispose);
      await tester.pumpWidget(themed(MentorsScreen(api: api)));
      await tester.pumpAndSettle();
      expect(Theme.of(tester.element(find.byType(MentorHeader))).brightness,
          brightness);
      expect(find.text(sampleMentor.name), findsOneWidget);
      await tester.tap(find.text(sampleMentor.name));
      await tester.pumpAndSettle();
      expect(find.byType(MentorDetailScreen), findsOneWidget);
      expect(Theme.of(tester.element(find.byType(MentorHeader))).brightness,
          brightness);
      await tester.ensureVisible(find.byType(CheckboxListTile));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'El reporte conserva el tema al cambiar el permiso en $brightness',
        (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await tester.pumpWidget(
          themed(const TamReportScreen(sector: 'Fintech', market: 'Chile')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(SwitchListTile));
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
          isTrue);
      expect(Theme.of(tester.element(find.byType(SwitchListTile))).brightness,
          brightness);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Cambiar el tema del sistema conserva la navegación y la sesión',
      (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final account = DashboardAccount();
    addTearDown(account.dispose);
    await openApp(tester, account);
    await tester.tap(find.text('Explorar mi mercado'));
    await tester.pumpAndSettle();
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(
        Theme.of(tester.element(find.byType(TamCalculatorScreen))).brightness,
        Brightness.dark);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.byType(HomePage))).brightness,
        Brightness.dark);
    expect(find.text('Hola, Ana 👋'), findsOneWidget);
    expect(account.account, isNotNull);
  });
}
