import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark Mode: Deep Velvety Espresso / Charcoal Bronze (Smooth, luxury, high contrast without harshness)
  static const Color darkBackground = Color(0xFF130E0B);
  static const Color darkSurface = Color(0xFF221812);
  static const Color darkSurfaceDark = Color(0xFF19110D);
  static const Color darkSurfaceElevated = Color(0xFF2E2019);
  static const Color darkSurfaceLighter = Color(0xFF3D2C23);

  // Light Mode: Warm Alabaster Parchment (Soft, easy on eyes, clean luxury feel)
  static const Color lightBackground = Color(0xFFFBF8F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceDark = Color(0xFFF3ECE4);
  static const Color lightSurfaceElevated = Color(0xFFFAF6F0);
  static const Color lightSurfaceLighter = Color(0xFFE9DEC5);

  // Dynamic helpers
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : lightSurface;

  static Color surfaceDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurfaceDark : lightSurfaceDark;

  static Color surfaceElevated(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurfaceElevated : lightSurfaceElevated;

  static Color surfaceLighter(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurfaceLighter : lightSurfaceLighter;

  static Color textColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFFFDFBF7) : const Color(0xFF24150D);

  static Color textSecondaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFFD4C5B8) : const Color(0xFF6E5343);

  static Color textMutedColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF998170) : const Color(0xFF9E8474);

  static Color borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF3F2B20) 
          : const Color(0xFFE5D7C7);

  // Metallic Bronze & Gold accents sampled directly from the "Chess X Shogi: Dual Clash" logo
  static const Color primary = Color(0xFFD97706); // Warm Amber Gold
  static const Color primaryLight = Color(0xFFFBBF24); // Soft Metallic Gold
  static const Color primaryDark = Color(0xFF92400E); // Deep Burnished Bronze

  static const Color secondary = Color(0xFFC2410C); // Warm Terracotta Copper
  static const Color secondaryLight = Color(0xFFFB923C); // Warm Peach Copper
  static const Color secondaryDark = Color(0xFF7C2D12); // Deep Mahogany

  static const Color gold = Color(0xFFE5B56F);
  static const Color bronze = Color(0xFF9A632F);
  static const Color darkBronze = Color(0xFF422210);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
}
