// Color extraction service - imports removed as they are unused
import '../../data/book_database.dart';
import '../../domain/entities/book.dart';
import '../../presentation/utils/color_extractor.dart';

/// Application service for color extraction operations
class ColorExtractionService {
  final BookDatabase _database;

  ColorExtractionService(this._database) {
    // Initialize ColorExtractor with database reference
    ColorExtractor.initializeDatabase(_database);
  }

  /// Extract and cache accent color for a book
  Future<int?> extractBookAccentColor(BookEntity book) async {
    if (book.thumbnailUrl == null || book.thumbnailUrl!.isEmpty) {
      return null;
    }

    try {
      final color = await ColorExtractor.extractColorForBook(
        book.id ?? 0,
        book.thumbnailUrl!,
      );
      return color?.value;
    } catch (e) {
      print('❌ Error extracting color for ${book.title}: $e');
      return null;
    }
  }

  /// Get cached accent color for a book
  Future<int?> getCachedAccentColor(int bookId) async {
    try {
      // This would need to be implemented in ColorExtractor
      // For now, return null as we don't have this method
      return null;
    } catch (e) {
      print('❌ Error getting cached color for book $bookId: $e');
      return null;
    }
  }
}
