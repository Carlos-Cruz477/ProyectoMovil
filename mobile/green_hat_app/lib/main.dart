import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/account_provider.dart';
import 'screens/auth_page.dart';
import 'screens/home_page.dart';
import 'screens/loading_screen.dart';

const ink = Color(0xFF172D2A);
const forest = Color(0xFF1D6254);
const mint = Color(0xFFDDF4E9);
const paper = Color(0xFFF5F8F5);
const muted = Color(0xFF6D7E78);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AccountProvider()..restoreSession(),
      child: const GreenHatApp(),
    ),
  );
}

class GreenHatApp extends StatelessWidget {
  const GreenHatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenHat Business',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: forest,
          primary: forest,
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: paper, fontSize: 38, height: 1.12,
            fontWeight: FontWeight.w800, letterSpacing: -1.2,
          ),
          headlineMedium: TextStyle(
            color: ink, fontSize: 28, height: 1.16,
            fontWeight: FontWeight.w800, letterSpacing: -0.7,
          ),
          bodyMedium: TextStyle(color: muted, height: 1.5, fontSize: 14),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAF8),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15, vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E8E2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E8E2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: forest, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFB84949)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFB84949), width: 1.4),
          ),
          labelStyle: const TextStyle(color: muted),
          prefixIconColor: muted,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: forest,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
      home: Consumer<AccountProvider>(
        builder: (context, accountProvider, _) {
          if (accountProvider.isCheckingSession) {
            return const LoadingScreen();
          }
          if (accountProvider.account == null) {
            return const AuthPage();
          }
          return const HomePage();
        },
      ),
    );
  }
}
