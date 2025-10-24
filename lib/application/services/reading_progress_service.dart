import '../../data/book_database.dart';

/// Application service for reading progress operations
class ReadingProgressService {
  final BookDatabase _database;

  ReadingProgressService(this._database);

  /// Add reading time to a book
  Future<void> addReadingTime(int bookId, int minutes) async {
    await _database.addReadingTime(bookId, minutes);
    // Record daily activity for streak tracking
    await _recordDailyActivity(bookId, minutes, 0);
  }

  /// Update progress and reading time atomically
  Future<void> updateProgressWithTime(
    int bookId,
    int currentPage,
    int minutesRead,
  ) async {
    await _database.updateProgressWithTime(bookId, currentPage, minutesRead);
    // Record daily activity for streak tracking
    await _recordDailyActivity(bookId, minutesRead, 0);
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

  /// Record daily reading activity for streak tracking
  Future<void> _recordDailyActivity(
    int bookId,
    int minutesRead,
    int pagesRead,
  ) async {
    if (minutesRead <= 0) return; // Only record if there's actual reading time

    await _database.recordDailyActivity(
      bookId: bookId,
      date: DateTime.now(),
      minutesRead: minutesRead,
      pagesRead: pagesRead,
    );
  }

  /// Get book reading streak
  Future<int> getBookStreak(int bookId) async {
    return await _database.calculateBookStreak(bookId);
  }

  /// Get global reading streak
  Future<int> getGlobalStreak() async {
    return await _database.calculateGlobalStreak();
  }
}
