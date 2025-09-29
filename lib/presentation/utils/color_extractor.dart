import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorExtractor {
  static Color? _cachedColor;
  static String? _cachedImageUrl;

  /// Extracts the dominant color from a book cover image
  /// Returns a vibrant color suitable for progress bars
  static Future<Color?> extractColorFromImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    // Return cached color if available
    if (_cachedColor != null && _cachedImageUrl == imageUrl) {
      return _cachedColor;
    }

    try {
      // Create an ImageProvider from the URL
      final imageProvider = NetworkImage(imageUrl);

      // Generate color palette from the image
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(200, 200), // Use smaller size for performance
        maximumColorCount: 5,
      );

      // Get the most vibrant color from the palette
      Color? dominantColor = paletteGenerator.dominantColor?.color;

      // If no dominant color, try vibrant color
      if (dominantColor == null) {
        final vibrantColor = paletteGenerator.vibrantColor;
        if (vibrantColor != null) {
          dominantColor = vibrantColor.color;
        }
      }

      // If still no color, try muted color
      if (dominantColor == null) {
        final mutedColor = paletteGenerator.mutedColor;
        if (mutedColor != null) {
          dominantColor = mutedColor.color;
        }
      }

      // Ensure the color is vibrant enough for a progress bar
      if (dominantColor != null) {
        // Increase saturation and brightness for better visibility
        final hsl = HSLColor.fromColor(dominantColor);
        final adjustedColor = hsl
            .withSaturation((hsl.saturation + 0.3).clamp(0.0, 1.0))
            .withLightness((hsl.lightness + 0.1).clamp(0.0, 1.0))
            .toColor();

        // Cache the result
        _cachedColor = adjustedColor;
        _cachedImageUrl = imageUrl;

        return adjustedColor;
      }

      return null;
    } catch (e) {
      print('Error extracting color from image: $e');
      return null;
    }
  }

  /// Clears the cached color
  static void clearCache() {
    _cachedColor = null;
    _cachedImageUrl = null;
  }

  /// Gets a fallback color based on book title (for consistency)
  static Color getFallbackColor(String title) {
    // Generate a consistent color based on the title
    final hash = title.hashCode;
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
  }
}
