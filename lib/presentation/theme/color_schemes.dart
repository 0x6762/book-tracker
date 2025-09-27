import 'package:flutter/material.dart';

class AppColorSchemes {
  // Light theme colors
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2E7D32), // Forest green
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF1976D2), // Blue
    onSecondary: Color(0xFFFFFFFF),
    tertiary: Color(0xFF7B1FA2), // Purple
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFD32F2F), // Red
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1C1B1F),
    surfaceContainerHighest: Color(0xFFF5F5F5),
    onSurfaceVariant: Color(0xFF49454F),
    outline: Color(0xFF79747E),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF313033),
    onInverseSurface: Color(0xFFF4EFF4),
    inversePrimary: Color(0xFF81C784),
  );

  // Dark theme colors
  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF81C784), // Light green
    onPrimary: Color(0xFF1B5E20),
    secondary: Color(0xFF90CAF9), // Light blue
    onSecondary: Color(0xFF0D47A1),
    tertiary: Color(0xFFCE93D8), // Light purple
    onTertiary: Color(0xFF4A148C),
    error: Color(0xFFEF5350), // Light red
    onError: Color(0xFF690005),
    surface: Color(0xFF1C1B1F),
    onSurface: Color(0xFFE6E1E5),
    surfaceContainerHighest: Color(0xFF2A2A2A),
    onSurfaceVariant: Color(0xFFCAC4D0),
    outline: Color(0xFF938F99),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE6E1E5),
    onInverseSurface: Color(0xFF313033),
    inversePrimary: Color(0xFF2E7D32),
  );

  // Custom colors for book tracker specific elements
  static const Color bookCardBackground = Color(0xFFF8F9FA);
  static const Color bookCardBackgroundDark = Color(0xFF2A2A2A);
  static const Color searchBarBackground = Color(0xFFF5F5F5);
  static const Color searchBarBackgroundDark = Color(0xFF3A3A3A);
  static const Color emptyStateIcon = Color(0xFF9E9E9E);
  static const Color emptyStateIconDark = Color(0xFF757575);
}
