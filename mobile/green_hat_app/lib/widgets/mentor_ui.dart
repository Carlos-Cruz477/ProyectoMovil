import 'package:flutter/material.dart';
import '../models/mentor.dart';
import 'mentor_assets.dart';

const mentorBackground = Color(0xFF0B1326);
const mentorPanel = Color(0xFF171F33);
const mentorInset = Color(0xFF131B2E);
const mentorCyan = Color(0xFF4CD7F6);
const mentorGreen = Color(0xFF4EDEA3);
const mentorMuted = Color(0xFFBCC9CD);

ThemeData mentorTheme(BuildContext context) => Theme.of(context).copyWith(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: mentorBackground,
  colorScheme: const ColorScheme.dark(primary: mentorCyan, secondary: mentorGreen,
    surface: mentorPanel, onSurface: Color(0xFFF2F5FF)),
  textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Inter', bodyColor: const Color(0xFFF2F5FF),
    displayColor: const Color(0xFFF2F5FF)),
  inputDecorationTheme: InputDecorationTheme(
    filled: true, fillColor: const Color(0xFF222A3D),
    hintStyle: const TextStyle(color: mentorMuted, fontSize: 13),
    contentPadding: const EdgeInsets.all(16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: mentorCyan)),
    prefixIconColor: mentorMuted,
  ),
);

class MentorHeader extends StatelessWidget implements PreferredSizeWidget {
  const MentorHeader({this.showBack = false, super.key});
  final bool showBack;
  @override
  Size get preferredSize => const Size.fromHeight(64);
  @override
  Widget build(BuildContext context) => AppBar(
    automaticallyImplyLeading: showBack,
    backgroundColor: const Color(0xFF101A30), surfaceTintColor: Colors.transparent,
    foregroundColor: Colors.white,
    title: Row(children: [
      SizedBox(width: 32, height: 32, child: Image.network(mentorLogoUrl,
        errorBuilder: _logoFallback)), SizedBox(width: 8),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('GREEN HAT', style: TextStyle(fontSize: 10, color: mentorGreen, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
        Text('Red Mentores', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 18, fontWeight: FontWeight.w600)),
      ]),
    ]),
    actions: [Padding(padding: const EdgeInsets.only(right: 20), child: CircleAvatar(
      radius: 17, backgroundColor: mentorCyan,
      child: IconButton(padding: EdgeInsets.zero, tooltip: 'Volver a mi cuenta',
        icon: const Icon(Icons.person_outline, size: 19, color: mentorBackground),
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst)),
    ))],
  );
}

Widget _logoFallback(BuildContext context, Object error, StackTrace? stack) =>
    const Icon(Icons.eco_outlined, color: mentorGreen, size: 29);

class MentorSurface extends StatelessWidget {
  const MentorSurface({required this.child, this.padding = const EdgeInsets.all(20), super.key});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: padding,
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF171F33), mentorPanel]),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withValues(alpha: .035)),
    ), child: child,
  );
}

class MentorAvatar extends StatelessWidget {
  const MentorAvatar({required this.mentor, this.radius = 25, super.key});
  final Mentor mentor;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(shape: BoxShape.circle,
      border: Border.all(color: mentor.isInvestor ? mentorCyan : mentorGreen),
      boxShadow: [BoxShadow(color: mentorCyan.withValues(alpha: .1), blurRadius: 18)]),
    child: ClipOval(child: Image.network(mentorPortraitUrls[mentor.id] ?? '',
      width: radius * 2, height: radius * 2, fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => CircleAvatar(radius: radius,
        backgroundColor: const Color(0xFF253F46), child: Text(mentor.initials,
          style: TextStyle(fontSize: radius * .64, color: mentorGreen, fontWeight: FontWeight.w700))),
    )),
  );
}

class MentorBadge extends StatelessWidget {
  const MentorBadge(this.label, {this.color = mentorGreen, super.key});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
  );
}

class MentorAction extends StatelessWidget {
  const MentorAction({required this.label, required this.icon, required this.onPressed,
    this.gradient = false, this.secondary = false, this.loading = false, super.key});
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool gradient, secondary, loading;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(32),
      color: secondary ? const Color(0xFF2D3449) : mentorCyan,
      gradient: gradient ? const LinearGradient(colors: [mentorGreen, Color(0xFF06B6D4)]) : null,
      boxShadow: gradient ? [BoxShadow(color: mentorGreen.withValues(alpha: .12), blurRadius: 22)] : null),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: secondary ? mentorCyan : mentorBackground,
        disabledForegroundColor: mentorBackground.withValues(alpha: .5),
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (loading) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
        else Icon(icon, size: 18),
        const SizedBox(width: 8),
        Flexible(child: Text(label, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
      ]),
    ),
  );
}

class MentorPrivacyNote extends StatelessWidget {
  const MentorPrivacyNote({super.key});
  @override
  Widget build(BuildContext context) => const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(Icons.shield_outlined, color: mentorGreen, size: 18), SizedBox(width: 10),
    Expanded(child: Text.rich(TextSpan(children: [
      TextSpan(text: 'Protección Green Hat: ', style: TextStyle(fontWeight: FontWeight.w700)),
      TextSpan(text: 'Ningún mentor o fondo puede ver tus cálculos de TAM ni métricas de tracción sin tu invitación explícita.'),
    ]), style: TextStyle(fontSize: 11, color: Color(0xFFD5DEED), height: 1.5))),
  ]);
}
