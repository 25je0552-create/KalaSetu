import 'package:flutter/material.dart';

/// KalaSetu Design System — Terracotta & Clay Handcraft
/// Based strictly on DESIGN.md: mineral pigments, sun-baked mud bricks, riverbeds, and unglazed pottery.
class AppColors {
  // Base Clay Foundations
  static const Color surface = Color(0xFFFFF8F2);          // Wet Clay Beige
  static const Color surfaceDim = Color(0xFFE4D9C6);       // Jute Fiber Tan
  static const Color surfaceBright = Color(0xFFFFF8F2);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFEF2DF);
  static const Color surfaceContainer = Color(0xFFF9ECD9);   // Unglazed Pot Card
  static const Color surfaceContainerHigh = Color(0xFFF3E7D4);
  static const Color surfaceContainerHighest = Color(0xFFEDE1CE);
  static const Color surfaceVariant = Color(0xFFEDE1CE);
  static const Color onSecondaryFixed = Color(0xFF291800);
  
  // Deep Contrast & Typography
  static const Color onSurface = Color(0xFF201B0F);        // Kiln Brown / Mineral Charcoal
  static const Color onSurfaceVariant = Color(0xFF56423B); // Damp Soil
  static const Color outline = Color(0xFF8A7269);
  static const Color outlineVariant = Color(0xFFDDC0B7);

  // Kiln Terracotta Accents
  static const Color primary = Color(0xFF9D3E14);          // Terracotta
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFBD562A);
  static const Color onPrimaryContainer = Color(0xFFFFFBFF);
  static const Color primaryFixed = Color(0xFFFFDBCE);
  static const Color primaryFixedDim = Color(0xFFFFB599);

  // Turmeric Ochre Highlights & Recording
  static const Color secondary = Color(0xFF805600);        // Turmeric Ochre
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFEBA4A);
  static const Color onSecondaryContainer = Color(0xFF704B00);
  static const Color secondaryFixed = Color(0xFFFFDDB0);
  static const Color secondaryFixedDim = Color(0xFFFEBA4A);

  // Muted Wood / Jute
  static const Color tertiary = Color(0xFF785440);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF936C57);
  static const Color tertiaryFixed = Color(0xFFFFDBCA);

  // Semantics
  static const Color success = Color(0xFF6B7A4F);          // Moss Green (Verified Artisan Seal)
  static const Color error = Color(0xFFBA1A1A);            // Brick Red
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surface,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      fontFamily: 'Be Vietnam Pro',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Literata',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Literata',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Literata',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
  color: AppColors.surfaceContainer,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(
      color: AppColors.outlineVariant,
      width: 1.2,
    ),
  ),
),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(56), // Touch target min 56px
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          elevation: 1,
        ),
      ),
    );
  }
}
