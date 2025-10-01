import 'package:flutter/material.dart';

// Custom theme extension for book tracker specific styling
@immutable
class BookTrackerThemeExtension
    extends ThemeExtension<BookTrackerThemeExtension> {
  const BookTrackerThemeExtension({
    required this.bookCardShadow,
    required this.searchBarElevation,
    required this.emptyStateIconSize,
    required this.borderRadius,
    required this.spacing,
  });

  final Color bookCardShadow;
  final double searchBarElevation;
  final double emptyStateIconSize;
  final double borderRadius;
  final double spacing;

  @override
  BookTrackerThemeExtension copyWith({
    Color? bookCardShadow,
    double? searchBarElevation,
    double? emptyStateIconSize,
    double? borderRadius,
    double? spacing,
  }) {
    return BookTrackerThemeExtension(
      bookCardShadow: bookCardShadow ?? this.bookCardShadow,
      searchBarElevation: searchBarElevation ?? this.searchBarElevation,
      emptyStateIconSize: emptyStateIconSize ?? this.emptyStateIconSize,
      borderRadius: borderRadius ?? this.borderRadius,
      spacing: spacing ?? this.spacing,
    );
  }

  @override
  BookTrackerThemeExtension lerp(
    ThemeExtension<BookTrackerThemeExtension>? other,
    double t,
  ) {
    if (other is! BookTrackerThemeExtension) {
      return this;
    }
    return BookTrackerThemeExtension(
      bookCardShadow: Color.lerp(bookCardShadow, other.bookCardShadow, t)!,
      searchBarElevation: _lerpDouble(
        searchBarElevation,
        other.searchBarElevation,
        t,
      ),
      emptyStateIconSize: _lerpDouble(
        emptyStateIconSize,
        other.emptyStateIconSize,
        t,
      ),
      borderRadius: _lerpDouble(borderRadius, other.borderRadius, t),
      spacing: _lerpDouble(spacing, other.spacing, t),
    );
  }

  double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  // Light theme values
  static const BookTrackerThemeExtension light = BookTrackerThemeExtension(
    bookCardShadow: Color(0x0A000000),
    searchBarElevation: 1.0,
    emptyStateIconSize: 64.0,
    borderRadius: 12.0,
    spacing: 16.0,
  );

  // Dark theme values
  static const BookTrackerThemeExtension dark = BookTrackerThemeExtension(
    bookCardShadow: Color(0x1A000000),
    searchBarElevation: 2.0,
    emptyStateIconSize: 64.0,
    borderRadius: 12.0,
    spacing: 16.0,
  );
}
