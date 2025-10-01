import 'package:flutter/foundation.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/book.dart';

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

      final results = await _serviceLocator.googleBooksApiService.searchBooks(
        query,
      );
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
