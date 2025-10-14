import 'package:flutter/foundation.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/book.dart';
import '../../core/utils/isbn_utils.dart';

/// Provider responsible for book search functionality
class SearchProvider with ChangeNotifier {
  final ServiceLocator _serviceLocator = ServiceLocator();

  SearchProvider();

  List<BookEntity> _searchResults = [];
  bool _isSearching = false;
  String? _error;

  // Getters
  List<BookEntity> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get error => _error;

  /// Search for books using Google Books API
  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      _setSearching(false);
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setSearching(true);
    try {
      print('🔍 Searching for: $query');
      final stopwatch = Stopwatch()..start();
      List<BookEntity> results = [];

      final cleaned = cleanIsbn(query);
      final looks13 = isIsbn13(cleaned);
      final looks10 = isIsbn10(cleaned);

      if (looks13 || looks10) {
        // Try direct ISBN lookup(s)
        try {
          results = await _serviceLocator.googleBooksApiService
              .searchBooksByIsbn(cleaned);
        } catch (_) {}

        if (results.isEmpty && looks13) {
          final as10 = toIsbn10(cleaned);
          if (as10 != null) {
            try {
              results = await _serviceLocator.googleBooksApiService
                  .searchBooksByIsbn(as10);
            } catch (_) {}
          }
        }

        if (results.isEmpty && looks10) {
          final as13 = toIsbn13(cleaned);
          if (as13 != null) {
            try {
              results = await _serviceLocator.googleBooksApiService
                  .searchBooksByIsbn(as13);
            } catch (_) {}
          }
        }
      }

      // Fallback to generic search if ISBN lookups failed or it wasn't an ISBN
      if (results.isEmpty) {
        results = await _serviceLocator.googleBooksApiService.searchBooks(
          query,
        );
      }
      _searchResults = results;

      stopwatch.stop();
      print(
        '🔍 Found ${results.length} results in ${stopwatch.elapsedMilliseconds}ms',
      );
      _error = null;
    } catch (e) {
      print('❌ Error searching books: $e');
      _error = 'Failed to search books: $e';
      _searchResults = [];
    } finally {
      _setSearching(false);
    }
  }

  /// Clear search results
  void clearSearch() {
    _searchResults = [];
    _error = null;
    notifyListeners();
  }

  /// Clear any error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }
}
