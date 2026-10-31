import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:green_hat_business/providers/account_provider.dart';
//import 'package:green_hat_business/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:green_hat_business/screens/welcome_screen.dart'; //
import 'fakes/fake_cuenta.dart';

Widget _pantalla({String nombre = "Andrés"}) {
  return ChangeNotifierProvider<AccountProvider>.value(
    value: FakeCuenta(),
    child: MaterialApp(
      home: WelcomeScreen(userName: nombre, onContinue: (_) async {}),
    ),
  );
}

void main() {
  testWidgets('Mostrar el nombre de usuario en la pantalla de bienvenida',
      (tester) async {
    await tester.pumpWidget(_pantalla(nombre: "Andrés"));

    expect(find.text("¡Bienvenido a Green Hat, Andrés!"), findsOneWidget);
  });

  testWidgets('Solo se selecciona una etapa', (tester) async {

    tester.view.physicalSize = const Size(960, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);


    await tester.pumpWidget(_pantalla());

    await tester.tap(find.text('Tengo una idea en mente'));
    await tester.pump();

    await tester.tap(find.text('Creando el primer prototipo'));
    await tester.pump();

    await tester.tap(find.text('Buscando primeros clientes'));
    await tester.pump();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));


  });
}
