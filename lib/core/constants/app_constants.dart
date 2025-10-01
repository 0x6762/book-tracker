import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Readr';
  static const String appTitle = 'Book Tracker';

  // UI Dimensions
  static const double searchBarPadding = 16.0;
  static const double cardMargin = 16.0;
  static const double cardVerticalMargin = 8.0;
  static const double bookCoverHeight = 100.0;
  static const double bookCoverWidth = 75.0; // 3:4 aspect ratio
  static const double searchBookHeight = 80.0;
  static const double searchBookWidth = 60.0; // 3:4 aspect ratio (80 * 3/4)

  // Border Radius
  static const double borderRadius = 8.0;
  static const double emptyStatePadding = 32.0;

  // Icon Sizes
  static const double bookIconSize = 30.0;
  static const double largeBookIconSize = 64.0;
  static const double deleteIconSize = 28.0;

  // Text Sizes
  static const double titleFontSize = 18.0;
  static const double subtitleFontSize = 16.0;
  static const double bodyFontSize = 14.0;
  static const double emptyStateTitleSize = 28.0;
  static const double emptyStateBodySize = 16.0;

  // Spacing
  static const double smallSpacing = 4.0;
  static const double mediumSpacing = 8.0;
  static const double largeSpacing = 16.0;
  static const double extraLargeSpacing = 24.0;

  // Search Configuration
  static const int minQueryLength = 3;
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const int maxSearchResults = 20;

  // Colors
  static const Color primaryBlue = Colors.blue;
  static const Color emptyStateBlue = Color(0xFF1976D2);

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
}
