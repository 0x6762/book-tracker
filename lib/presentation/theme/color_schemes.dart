import 'package:flutter/material.dart';

class AppColorSchemes {
  // Light theme colors
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF575A5E), // Medium gray from your palette
    onPrimary: Color(0xFFF4F7F5), // Very light from your palette
    secondary: Color(0xFFA7A2A9), // Light gray from your palette
    onSecondary: Color(0xFF08090A), // Very dark from your palette
    tertiary: Color(0xFF575A5E), // Medium gray
    onTertiary: Color(0xFFF4F7F5), // Very light
    error: Color(0xFFD32F2F), // Red (keeping for errors)
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF4F7F5), // Very light from your palette
    onSurface: Color(0xFF08090A), // Very dark from your palette
    surfaceContainerHighest: Color(0xFFA7A2A9), // Light gray from your palette
    onSurfaceVariant: Color(0xFF575A5E), // Medium gray from your palette
    outline: Color(0xFF575A5E), // Medium gray from your palette
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF222823), // Dark gray from your palette
    onInverseSurface: Color(0xFFF4F7F5), // Very light from your palette
    inversePrimary: Color(0xFFA7A2A9), // Light gray from your palette
  );

  // Dark theme colors
  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFA7A2A9), // Light gray from your palette
    onPrimary: Color(0xFF19141B), // Dark background
    secondary: Color(0xFF575A5E), // Medium gray from your palette
    onSecondary: Color(0xFFF2F2F2), // Light text
    tertiary: Color(0xFFA7A2A9), // Light gray
    onTertiary: Color(0xFF19141B), // Dark background
    error: Color(0xFFEF5350), // Light red (keeping for errors)
    onError: Color(0xFF690005),
    surface: Color(0xFF232427), // Cards surface
    onSurface: Color(0xFFF2F2F2), // Light text
    surfaceContainerHighest: Color(0xFF34363C), // Surface 2
    onSurfaceVariant: Color(0xFFA7A2A9), // Light gray from your palette
    outline: Color(0xFF575A5E), // Medium gray from your palette
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFF2F2F2), // Light text
    onInverseSurface: Color(0xFF19141B), // Dark background
    inversePrimary: Color(0xFF575A5E), // Medium gray from your palette
  );

  // Custom colors for book tracker specific elements
  static const Color bookCardBackground = Color(
    0xFFF4F7F5,
  ); // Very light from your palette
  static const Color bookCardBackgroundDark = Color(
    0xFF232427,
  ); // Cards surface
  static const Color searchBarBackground = Color(
    0xFFA7A2A9,
  ); // Light gray from your palette
  static const Color searchBarBackgroundDark = Color(0xFF232427); // Surface 2
  static const Color emptyStateIcon = Color(
    0xFF575A5E,
  ); // Medium gray from your palette
  static const Color emptyStateIconDark = Color(
    0xFFA7A2A9,
  ); // Light gray from your palette
}
