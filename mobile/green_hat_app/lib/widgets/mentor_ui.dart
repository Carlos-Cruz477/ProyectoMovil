import 'package:flutter/material.dart';
import '../models/mentor.dart';
import 'mentor_assets.dart';

ThemeData mentorTheme(BuildContext context) => Theme.of(context);

class MentorHeader extends StatelessWidget implements PreferredSizeWidget {
  const MentorHeader({this.showBack = false, this.onProfileTap, super.key});
  final bool showBack;
  final VoidCallback? onProfileTap;
  @override
  Size get preferredSize => const Size.fromHeight(64);
  @override
  Widget build(BuildContext context) => AppBar(
        automaticallyImplyLeading: showBack,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Row(children: [
          SizedBox(
              width: 32,
              height: 32,
              child: Image.network(mentorLogoUrl, errorBuilder: _logoFallback)),
          SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('GREEN HAT',
                style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4)),
            Text('Red Mentores',
                style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ]),
        ]),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: 'Volver a mi cuenta',
                    icon: Icon(Icons.person_outline,
                        size: 19,
                        color: Theme.of(context).colorScheme.onPrimary),
                    onPressed: onProfileTap ??
                        () => Navigator.of(context)
                            .popUntil((route) => route.isFirst)),
              ))
        ],
      );
}

Widget _logoFallback(BuildContext context, Object error, StackTrace? stack) =>
    Icon(Icons.eco_outlined,
        color: Theme.of(context).colorScheme.secondary, size: 29);

class MentorSurface extends StatelessWidget {
  const MentorSurface(
      {required this.child,
      this.padding = const EdgeInsets.all(20),
      super.key});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: child,
      );
}

class MentorAvatar extends StatelessWidget {
  const MentorAvatar({required this.mentor, this.radius = 25, super.key});
  final Mentor mentor;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: mentor.isInvestor
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: .1),
                  blurRadius: 18)
            ]),
        child: ClipOval(
            child: Image.network(
          mentorPortraitUrls[mentor.id] ?? '',
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => CircleAvatar(
              radius: radius,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Text(mentor.initials,
                  style: TextStyle(
                      fontSize: radius * .64,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w700))),
        )),
      );
}

class MentorBadge extends StatelessWidget {
  const MentorBadge(this.label, {this.color, super.key});
  final String label;
  final Color? color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: (color ?? Theme.of(context).colorScheme.secondary)
                .withValues(alpha: .1),
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                color: color ?? Theme.of(context).colorScheme.secondary,
                fontSize: 10,
                fontWeight: FontWeight.w700)),
      );
}

class MentorAction extends StatelessWidget {
  const MentorAction(
      {required this.label,
      required this.icon,
      required this.onPressed,
      this.gradient = false,
      this.secondary = false,
      this.loading = false,
      super.key});
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool gradient, secondary, loading;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: secondary
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.primary,
            gradient: gradient
                ? LinearGradient(colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.primary
                  ])
                : null,
            boxShadow: gradient
                ? [
                    BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: .12),
                        blurRadius: 22)
                  ]
                : null),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
              foregroundColor: secondary
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onPrimary,
              disabledForegroundColor:
                  Theme.of(context).colorScheme.onPrimary.withValues(alpha: .5),
              minimumSize: const Size(double.infinity, 50),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (loading)
              SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary))
            else
              Icon(icon, size: 18),
            const SizedBox(width: 8),
            Flexible(
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700))),
          ]),
        ),
      );
}

class MentorPrivacyNote extends StatelessWidget {
  const MentorPrivacyNote({super.key});
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.shield_outlined,
            color: Theme.of(context).colorScheme.secondary, size: 18),
        SizedBox(width: 10),
        Expanded(
            child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: 'Protección Green Hat: ',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(
                      text:
                          'Ningún mentor o fondo puede ver tus cálculos de TAM ni métricas de tracción sin tu invitación explícita.'),
                ]),
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5))),
      ]);
}
