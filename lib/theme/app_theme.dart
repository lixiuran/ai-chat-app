import 'package:flutter/material.dart';

// 浅色主题配色方案
const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF2AAF62),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFB8F4C9),
  onPrimaryContainer: Color(0xFF002111),
  secondary: Color(0xFF4F6354),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD1E8D5),
  onSecondaryContainer: Color(0xFF0C1F13),
  tertiary: Color(0xFF3A6A47),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFBDF0C8),
  onTertiaryContainer: Color(0xFF002110),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFBFDF7),
  onBackground: Color(0xFF191C19),
  surface: Color(0xFFFBFDF7),
  onSurface: Color(0xFF191C19),
  surfaceVariant: Color(0xFFDDE5DB),
  onSurfaceVariant: Color(0xFF414942),
  outline: Color(0xFF717971),
  onInverseSurface: Color(0xFFF0F1EC),
  inverseSurface: Color(0xFF2E312E),
  inversePrimary: Color(0xFF9CD7AF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF2AAF62),
  outlineVariant: Color(0xFFC1C9BF),
  scrim: Color(0xFF000000),
);

// 深色主题配色方案
const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF9CD7AF),
  onPrimary: Color(0xFF003920),
  primaryContainer: Color(0xFF005230),
  onPrimaryContainer: Color(0xFFB8F4C9),
  secondary: Color(0xFFB5CCBA),
  onSecondary: Color(0xFF213528),
  secondaryContainer: Color(0xFF374B3D),
  onSecondaryContainer: Color(0xFFD1E8D5),
  tertiary: Color(0xFFA1D4AC),
  onTertiary: Color(0xFF0A3924),
  tertiaryContainer: Color(0xFF245135),
  onTertiaryContainer: Color(0xFFBDF0C8),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF191C19),
  onBackground: Color(0xFFE1E3DE),
  surface: Color(0xFF191C19),
  onSurface: Color(0xFFE1E3DE),
  surfaceVariant: Color(0xFF414942),
  onSurfaceVariant: Color(0xFFC1C9BF),
  outline: Color(0xFF8B938A),
  onInverseSurface: Color(0xFF191C19),
  inverseSurface: Color(0xFFE1E3DE),
  inversePrimary: Color(0xFF2AAF62),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF9CD7AF),
  outlineVariant: Color(0xFF414942),
  scrim: Color(0xFF000000),
);

// 自定义文本主题
TextTheme createTextTheme(TextTheme base) {
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(
      fontSize: 57,
      fontWeight: FontWeight.w400,
    ),
    displayMedium: base.displayMedium?.copyWith(
      fontSize: 45,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: base.displaySmall?.copyWith(
      fontSize: 36,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: base.headlineLarge?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w400,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: base.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: base.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: base.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: base.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: base.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: base.labelMedium?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: base.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ),
  );
} 