import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/account_provider.dart';
import 'theme/app_theme.dart';

export 'theme/app_theme.dart' show ink, forest, mint, paper, muted;
import 'screens/auth_page.dart';
import 'screens/home_page.dart';
import 'screens/loading_screen.dart';
import 'screens/welcome_screen.dart';

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
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: Consumer<AccountProvider>(
        builder: (context, accountProvider, _) {
          if (accountProvider.isCheckingSession) {
            return const LoadingScreen();
          }
          if (accountProvider.account == null) {
            return const AuthPage();
          }
          if (accountProvider.needsWelcome) {
            return WelcomeScreen(
              userName: accountProvider.account!.name,
              onContinue: accountProvider.completeWelcome,
            );
          }
          return const HomePage();
        },
      ),
    );
  }
}
