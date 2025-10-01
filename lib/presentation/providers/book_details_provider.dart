import 'package:flutter/foundation.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/book.dart';
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
      print('📖 Added $minutesRead minutes to book $bookId');
      _error = null;
      // Refresh book list to update UI
      _bookListProvider?.loadBooks();
    } catch (e) {
      print('❌ Error adding reading time: $e');
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
      print(
        '📖 Updated progress for book $bookId to page $currentPage and added $minutesRead minutes',
      );
      _error = null;
      // Refresh book list to update UI
      _bookListProvider?.loadBooks();
    } catch (e) {
      print('❌ Error updating progress with time: $e');
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
      print('📖 Updated progress for book $bookId to page $currentPage');
      _error = null;
      // Refresh book list to update UI
      _bookListProvider?.loadBooks();
    } catch (e) {
      print('❌ Error updating progress: $e');
      _error = 'Failed to update progress: $e';
      notifyListeners();
    }
  }

  /// Mark a book as completed
  Future<void> completeReading(int bookId) async {
    try {
      await _serviceLocator.readingProgressService.completeReading(bookId);
      print('📖 Marked book $bookId as completed');
      _error = null;
      // Refresh book list to update UI
      _bookListProvider?.loadBooks();
    } catch (e) {
      print('❌ Error completing book: $e');
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
