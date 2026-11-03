import 'package:flutter/material.dart';

const ink = Color(0xFF172D2A);
const forest = Color(0xFF1D6254);
const mint = Color(0xFFDDF4E9);
const paper = Color(0xFFF5F8F5);
const muted = Color(0xFF6D7E78);

class AppTheme {
  static final light = _build(Brightness.light);
  static final dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final colors = ColorScheme.fromSeed(
      seedColor: forest,
      brightness: brightness,
    ).copyWith(
      primary: dark ? const Color(0xFF4CD7F6) : forest,
      onPrimary: dark ? const Color(0xFF0B1326) : Colors.white,
      primaryContainer: dark ? const Color(0xFF101A30) : forest,
      onPrimaryContainer: Colors.white,
      secondary: dark ? const Color(0xFF4EDEA3) : forest,
      onSecondary: dark ? const Color(0xFF0B1326) : Colors.white,
      secondaryContainer: dark ? const Color(0xFF183E43) : mint,
      onSecondaryContainer: dark ? const Color(0xFF4EDEA3) : forest,
      surface: dark ? const Color(0xFF171F33) : Colors.white,
      onSurface: dark ? const Color(0xFFF2F5FF) : ink,
      onSurfaceVariant: dark ? const Color(0xFFBCC9CD) : muted,
      surfaceContainerLow:
          dark ? const Color(0xFF131B2E) : const Color(0xFFF0F6F1),
      surfaceContainerHighest:
          dark ? const Color(0xFF222A3D) : const Color(0xFFF0F4F1),
      outlineVariant: dark ? const Color(0xFF344057) : const Color(0xFFE0E8E2),
    );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.outlineVariant),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: dark ? const Color(0xFF0B1326) : paper,
      colorScheme: colors,
      fontFamily: 'Inter',
      textTheme: TextTheme(
        headlineLarge: TextStyle(
            color: colors.onSurface,
            fontSize: 38,
            height: 1.12,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2),
        headlineMedium: TextStyle(
            color: colors.onSurface,
            fontSize: 28,
            height: 1.16,
            fontWeight: FontWeight.w800,
            letterSpacing: -.7),
        bodyMedium: TextStyle(
            color: colors.onSurfaceVariant, height: 1.5, fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF101A30) : paper,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
            borderSide: BorderSide(color: colors.primary, width: 1.6)),
        errorBorder:
            border.copyWith(borderSide: BorderSide(color: colors.error)),
        focusedErrorBorder: border.copyWith(
            borderSide: BorderSide(color: colors.error, width: 1.4)),
        labelStyle: TextStyle(color: colors.onSurfaceVariant),
        prefixIconColor: colors.onSurfaceVariant,
      ),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      )),
    );
  }
}
