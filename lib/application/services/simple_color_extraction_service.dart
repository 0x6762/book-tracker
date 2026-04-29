import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift/drift.dart';
import '../../core/di/service_locator.dart';
import '../../data/book_database.dart';

/// Simple color extraction service that extracts the most prominent color from book covers
class SimpleColorExtractionService {
  // Simple memory cache to avoid re-extracting colors
  static final Map<String, Color?> _colorCache = {};

  // Track ongoing extractions to avoid duplicate work
  static final Map<String, Future<Color?>> _ongoingExtractions = {};

  /// Extract the most visually appealing color from an image URL
  /// Returns null if extraction fails
  /// Uses caching and deduplication for performance
  static Future<Color?> extractColor(String imageUrl, int bookId) async {
    // Check memory cache first
    if (_colorCache.containsKey(imageUrl)) {
      debugPrint('SimpleColorExtractionService using memory cache');
      return _colorCache[imageUrl];
    }

    // Check database cache by bookId
    try {
      final database = ServiceLocator().database;
      final bookColor = await database.getBookColor(bookId);
      if (bookColor?.accentColor != null) {
        final color = Color(bookColor!.accentColor!);
        _colorCache[imageUrl] = color; // Store in memory cache too
        debugPrint('SimpleColorExtractionService using database cache');
        return color;
      }
    } catch (e) {
      debugPrint('SimpleColorExtractionService DB load failed: $e');
    }

    debugPrint('SimpleColorExtractionService cache miss');

    // Check if extraction is already in progress
    if (_ongoingExtractions.containsKey(imageUrl)) {
      return await _ongoingExtractions[imageUrl]!;
    }

    // Start new extraction
    final extractionFuture = _performExtraction(imageUrl);
    _ongoingExtractions[imageUrl] = extractionFuture;

    try {
      final result = await extractionFuture;
      _colorCache[imageUrl] = result;

      // Save to database for persistence using bookId
      if (result != null) {
        try {
          final database = ServiceLocator().database;
          await database.insertOrUpdateBookColor(
            BookColorsCompanion(
              bookId: Value(bookId),
              accentColor: Value(result.value),
              extractedAt: Value(DateTime.now()),
            ),
          );
          debugPrint('SimpleColorExtractionService saved extracted color');
        } catch (e) {
          debugPrint('SimpleColorExtractionService DB save failed: $e');
        }
      }

      return result;
    } finally {
      _ongoingExtractions.remove(imageUrl);
    }
  }

  static Future<Color?> _performExtraction(String imageUrl) async {
    try {
      // Create image provider with full resolution for accurate color extraction
      final imageProvider = CachedNetworkImageProvider(imageUrl);

      // Generate color palette
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
      );

      // Pick the best color in order of preference
      Color? pickedColor =
          paletteGenerator.vibrantColor?.color ??
          paletteGenerator.lightVibrantColor?.color ??
          paletteGenerator.dominantColor?.color ??
          paletteGenerator.mutedColor?.color;

      return pickedColor;
    } catch (e) {
      debugPrint('SimpleColorExtractionService extraction failed: $e');
      return null;
    }
  }

  /// Clear the color cache (useful for testing or memory management)
  static void clearCache() {
    _colorCache.clear();
    _ongoingExtractions.clear();
  }
}
