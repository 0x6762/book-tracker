import '../../data/book_database.dart';

/// Application service for reading progress operations
class ReadingProgressService {
  final BookDatabase _database;

  ReadingProgressService(this._database);

  /// Add reading time to a book
  Future<void> addReadingTime(int bookId, int minutes) async {
    await _database.addReadingTime(bookId, minutes);
  }

  /// Update progress and reading time atomically
  Future<void> updateProgressWithTime(
    int bookId,
    int currentPage,
    int minutesRead,
  ) async {
    await _database.updateProgressWithTime(bookId, currentPage, minutesRead);
  }

  /// Update reading progress
  Future<void> updateProgress(int bookId, int currentPage) async {
    await _database.updateProgress(bookId, currentPage);
  }

  /// Mark a book as completed
  Future<void> completeReading(int bookId) async {
    await _database.completeReading(bookId);
  }

  /// Start reading a book
  Future<void> startReading(int bookId, int currentPage) async {
    await _database.startReading(bookId, currentPage);
  }
}
