import 'package:flutter/material.dart';
import 'color_schemes.dart';
import 'text_styles.dart';
import 'component_themes.dart';
import 'theme_extensions.dart';

class AppTheme {
  // Light theme
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorSchemes.light,
      textTheme: _buildTextTheme(AppColorSchemes.light),
      appBarTheme: AppComponentThemes.appBarTheme(AppColorSchemes.light),
      cardTheme: AppComponentThemes.cardTheme(AppColorSchemes.light),
      elevatedButtonTheme: AppComponentThemes.elevatedButtonTheme(
        AppColorSchemes.light,
      ),
      inputDecorationTheme: AppComponentThemes.inputDecorationTheme(
        AppColorSchemes.light,
      ),
      progressIndicatorTheme: AppComponentThemes.progressIndicatorTheme(
        AppColorSchemes.light,
      ),
      listTileTheme: AppComponentThemes.listTileTheme(AppColorSchemes.light),
      extensions: const [BookTrackerThemeExtension.light],
    );
  }

  // Dark theme
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorSchemes.dark,
      scaffoldBackgroundColor: const Color(0xFF19141B), // Dark background
      textTheme: _buildTextTheme(AppColorSchemes.dark),
      appBarTheme: AppComponentThemes.appBarTheme(AppColorSchemes.dark),
      cardTheme: AppComponentThemes.cardTheme(AppColorSchemes.dark),
      elevatedButtonTheme: AppComponentThemes.elevatedButtonTheme(
        AppColorSchemes.dark,
      ),
      inputDecorationTheme: AppComponentThemes.inputDecorationTheme(
        AppColorSchemes.dark,
      ),
      progressIndicatorTheme: AppComponentThemes.progressIndicatorTheme(
        AppColorSchemes.dark,
      ),
      listTileTheme: AppComponentThemes.listTileTheme(AppColorSchemes.dark),
      extensions: const [BookTrackerThemeExtension.dark],
    );
  }

  // Build text theme with proper colors
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      displaySmall: AppTextStyles.displaySmall.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: colorScheme.onSurface,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      titleMedium: AppTextStyles.titleMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      titleSmall: AppTextStyles.titleSmall.copyWith(
        color: colorScheme.onSurface,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurface),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurface),
      labelLarge: AppTextStyles.labelLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: colorScheme.onSurface,
      ),
    );
  }

  // Helper method to get custom theme extension
  static BookTrackerThemeExtension bookTrackerTheme(BuildContext context) {
    return Theme.of(context).extension<BookTrackerThemeExtension>()!;
  }

  // Helper method to get custom colors
  static AppColorSchemes get colors => AppColorSchemes();

  // Helper method to get text styles
  static AppTextStyles get textStyles => AppTextStyles();
}
