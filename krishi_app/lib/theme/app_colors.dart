import 'package:flutter/material.dart';

class AppColors {
  // ── Dark theme ──────────────────────────────────────────
  static const Color bgDark        = Color(0xFF060E08);
  static const Color surfaceDark   = Color(0xFF0D1F14);
  static const Color cardDark      = Color(0xFF112218);
  static const Color neonGreen     = Color(0xFF39FF14);
  static const Color accentGreen   = Color(0xFF00C853);
  static const Color softGreenDark = Color(0xFF7CB98A);
  static const Color darkGreen     = Color(0xFF1A3A24);
  static const Color textDark      = Color(0xFFE8F5E9);

  // ── Light theme ─────────────────────────────────────────
  static const Color bgLight        = Color(0xFFF0F7F1);
  static const Color surfaceLight   = Color(0xFFFFFFFF);
  static const Color cardLight      = Color(0xFFFFFFFF);
  static const Color primaryLight   = Color(0xFF1B7A3E);
  static const Color accentLight    = Color(0xFF2ECC71);
  static const Color softGreenLight = Color(0xFF4A8C5C);
  static const Color textLight      = Color(0xFF0D2B18);

  // ── Helpers ──────────────────────────────────────────────
  static Color primary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? neonGreen : primaryLight;

  static Color accent(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? accentGreen : accentLight;

  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? bgDark : bgLight;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceDark : surfaceLight;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textDark : textLight;

  static Color textSub(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? softGreenDark : softGreenLight;

  static LinearGradient bgGradientDark = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF020A05), Color(0xFF071510), Color(0xFF030C07)],
  );

  static LinearGradient bgGradientLight = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8F5E9), Color(0xFFF0F7F1), Color(0xFFDCEFE2)],
  );

  static LinearGradient bgGradient(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? bgGradientDark : bgGradientLight;

  static LinearGradient get neonGlow => LinearGradient(
        colors: [neonGreen.withOpacity(0.9), accentGreen],
      );

  static LinearGradient get lightGlow => const LinearGradient(
        colors: [primaryLight, accentLight],
      );

  static LinearGradient buttonGradient(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? neonGlow : lightGlow;
}
