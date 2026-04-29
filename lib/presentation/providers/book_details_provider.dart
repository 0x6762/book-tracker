import 'package:flutter/foundation.dart';
import '../../core/di/service_locator.dart';
import 'book_list_provider.dart';

/// Provider responsible for individual book operations (progress, reading time, etc.)
class BookDetailsProvider with ChangeNotifier {
  final ServiceLocator _serviceLocator = ServiceLocator();
  BookListProvider? _bookListProvider;

  BookDetailsProvider();

  /// Set reference to BookListProvider for refreshing book list
  void setBookListProvider(BookListProvider bookListProvider) {
    _bookListProvider = bookListProvider;
  }

  String? _error;

  // Getters
  String? get error => _error;

  /// Add reading time to a book
  Future<void> addReadingTimeToBook(int bookId, int minutesRead) async {
    try {
      await _serviceLocator.readingProgressService.addReadingTime(
        bookId,
        minutesRead,
      );
      debugPrint('BookDetailsProvider.addReadingTimeToBook succeeded');
      _error = null;
      // Refresh book list to update UI and wait for completion
      if (_bookListProvider != null) {
        await _bookListProvider!.loadBooks();
      }
    } catch (e) {
      debugPrint('BookDetailsProvider.addReadingTimeToBook error: $e');
      _error = 'Failed to add reading time: $e';
      notifyListeners();
    }
  }

  /// Update progress and reading time atomically
  Future<void> updateProgressWithTime(
    int bookId,
    int currentPage,
    int minutesRead,
  ) async {
    try {
      await _serviceLocator.readingProgressService.updateProgressWithTime(
        bookId,
        currentPage,
        minutesRead,
      );
      debugPrint('BookDetailsProvider.updateProgressWithTime succeeded');
      _error = null;
      // Refresh book list to update UI and wait for completion
      if (_bookListProvider != null) {
        await _bookListProvider!.loadBooks();
      }
    } catch (e) {
      debugPrint('BookDetailsProvider.updateProgressWithTime error: $e');
      _error = 'Failed to update progress: $e';
      notifyListeners();
    }
  }

  /// Update reading progress
  Future<void> updateProgress(int bookId, int currentPage) async {
    try {
      await _serviceLocator.readingProgressService.updateProgress(
        bookId,
        currentPage,
      );
      debugPrint('BookDetailsProvider.updateProgress succeeded');
      _error = null;
      // Refresh book list to update UI and wait for completion
      if (_bookListProvider != null) {
        await _bookListProvider!.loadBooks();
      }
    } catch (e) {
      debugPrint('BookDetailsProvider.updateProgress error: $e');
      _error = 'Failed to update progress: $e';
      notifyListeners();
    }
  }

  /// Mark a book as completed
  Future<void> completeReading(int bookId) async {
    try {
      await _serviceLocator.readingProgressService.completeReading(bookId);
      debugPrint('BookDetailsProvider.completeReading succeeded');
      _error = null;
      // Refresh book list to update UI and wait for completion
      if (_bookListProvider != null) {
        await _bookListProvider!.loadBooks();
      }
    } catch (e) {
      debugPrint('BookDetailsProvider.completeReading error: $e');
      _error = 'Failed to complete book: $e';
      notifyListeners();
    }
  }

  /// Clear any error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
