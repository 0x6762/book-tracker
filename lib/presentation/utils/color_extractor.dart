import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:collection';
import '../../data/simple_database.dart';
import 'package:drift/drift.dart';

// Simple semaphore implementation for concurrency control
class Semaphore {
  final int maxCount;
  int _currentCount;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  Semaphore(this.maxCount) : _currentCount = maxCount;

  Future<void> acquire() async {
    if (_currentCount > 0) {
      _currentCount--;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _currentCount++;
    }
  }
}

class ColorExtractor {
  // Cache per-image URL to avoid recomputation and repeated network decode
  static final Map<String, Color> _cacheByUrl = <String, Color>{};

  // Concurrency control - limit to 2 parallel extractions
  static final Semaphore _extractionSemaphore = Semaphore(2);

  // Database reference for persistent caching
  static dynamic _database;

  /// Initialize the database reference for persistent caching
  static void initializeDatabase(dynamic database) {
    _database = database;
  }

  /// Extracts the dominant color from a book cover image
  /// Returns a vibrant color suitable for progress bars
  static Future<Color?> extractColorFromImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    // Return cached color if available
    final cached = _cacheByUrl[imageUrl];
    if (cached != null) return cached;

    try {
      // Use CachedNetworkImageProvider to leverage existing image cache
      final ImageProvider imageProvider = CachedNetworkImageProvider(imageUrl);

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

        // Cache the result per URL
        _cacheByUrl[imageUrl] = adjustedColor;
        return _cacheByUrl[imageUrl];
      }

      return null;
    } catch (e) {
      print('Error extracting color from image: $e');
      return null;
    }
  }

  /// Extracts a vivid, prominent color from an image while ensuring readability.
  /// Strategy:
  /// 1) Prefer vibrant swatches; fallback to lightVibrant, dominant, muted
  /// 2) Enforce minimum saturation and a mid-range lightness for vibrancy
  /// 3) Optionally blend slightly with a theme anchor color to stabilize hue
  /// 4) Optionally adjust lightness to contrast against a surface color
  static Future<Color?> extractVividProminentColor(
    String? imageUrl, {
    Size size = const Size(200, 200),
    int maximumColorCount = 10,
    Color? blendAnchor,
    double blendAmount = 0.2, // 0..1 small blend toward anchor
    Color? contrastAgainstSurface,
    double minSaturation = 0.62,
    double minLightness = 0.38,
    double maxLightness = 0.60,
  }) async {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    // Include blend anchor in cache key to avoid returning differently tuned colors
    final cacheKey = blendAnchor == null
        ? imageUrl
        : '${imageUrl}#${blendAnchor.value.toRadixString(16)}';
    final cached = _cacheByUrl[cacheKey];
    if (cached != null) return cached;

    try {
      final ImageProvider imageProvider = CachedNetworkImageProvider(imageUrl);
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: size,
        maximumColorCount: maximumColorCount,
      );

      // Prefer vibrant swatches
      Color? picked =
          paletteGenerator.vibrantColor?.color ??
          paletteGenerator.lightVibrantColor?.color ??
          paletteGenerator.dominantColor?.color ??
          paletteGenerator.mutedColor?.color;

      if (picked == null) return null;

      // Enforce vividness via HSL clamps
      final hsl = HSLColor.fromColor(picked);
      final saturated = hsl.withSaturation(
        hsl.saturation < minSaturation ? minSaturation : hsl.saturation,
      );
      final double targetLightness = hsl.lightness
          .clamp(minLightness, maxLightness)
          .toDouble();
      var adjusted = saturated.withLightness(targetLightness).toColor();

      // Optional gentle blend toward theme primary for stability
      if (blendAnchor != null && blendAmount > 0) {
        adjusted = Color.alphaBlend(
          blendAnchor.withOpacity(blendAmount.clamp(0.0, 1.0)),
          adjusted,
        );
      }

      // Optional contrast adjustment against surface
      if (contrastAgainstSurface != null) {
        final surfaceHsl = HSLColor.fromColor(contrastAgainstSurface);
        var adjHsl = HSLColor.fromColor(adjusted);
        // If too close in lightness, nudge
        if ((adjHsl.lightness - surfaceHsl.lightness).abs() < 0.18) {
          final bool surfaceIsLight = surfaceHsl.lightness >= 0.5;
          final double newL =
              (surfaceIsLight
                      ? (adjHsl.lightness - 0.18)
                      : (adjHsl.lightness + 0.18))
                  .clamp(minLightness, maxLightness);
          adjHsl = adjHsl.withLightness(newL);
        }
        adjusted = adjHsl.toColor();
      }

      _cacheByUrl[cacheKey] = adjusted;
      return adjusted;
    } catch (e) {
      print('Error extracting vivid color from image: $e');
      return null;
    }
  }

  /// Optimized color extraction with database caching and concurrency control
  static Future<Color?> extractColorForBook(
    int bookId,
    String? imageUrl, {
    Color? blendAnchor,
    Color? contrastAgainstSurface,
  }) async {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    // Check memory cache first
    final cached = _cacheByUrl[imageUrl];
    if (cached != null) return cached;

    // Check database cache
    if (_database != null) {
      try {
        final bookColor = await _database.getBookColor(bookId);
        if (bookColor?.accentColor != null) {
          final color = Color(bookColor!.accentColor!);
          _cacheByUrl[imageUrl] = color;
          return color;
        }
      } catch (e) {
        print('Error loading color from database: $e');
      }
    }

    // If not cached, extract with concurrency control
    await _extractionSemaphore.acquire();
    try {
      // Double-check memory cache in case another extraction completed
      final cached = _cacheByUrl[imageUrl];
      if (cached != null) return cached;

      final color = await extractVividProminentColor(
        imageUrl,
        blendAnchor: blendAnchor,
        contrastAgainstSurface: contrastAgainstSurface,
      );

      if (color != null) {
        // Cache in memory
        _cacheByUrl[imageUrl] = color;

        // Cache in database
        if (_database != null) {
          try {
            await _database.insertOrUpdateBookColor(
              BookColorsCompanion(
                bookId: Value(bookId),
                accentColor: Value(color.value),
                extractedAt: Value(DateTime.now()),
              ),
            );
          } catch (e) {
            print('Error saving color to database: $e');
          }
        }
      }

      return color;
    } finally {
      _extractionSemaphore.release();
    }
  }

  /// Clears the cached colors
  static void clearCache() {
    _cacheByUrl.clear();
  }

  /// Gets a fallback color based on book title (for consistency)
  static Color getFallbackColor(String title) {
    // Generate a consistent color based on the title
    final hash = title.hashCode;
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
  }
}
