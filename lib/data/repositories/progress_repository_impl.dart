import '../../domain/entities/book.dart';
import '../../domain/repositories/progress_repository.dart';
import '../book_database.dart';

/// Implementation of ProgressRepository using local database
class ProgressRepositoryImpl implements ProgressRepository {
  final BookDatabase _database;

  ProgressRepositoryImpl(this._database);

  @override
  Future<void> updateProgress(int bookId, int currentPage) async {
    await _database.updateProgress(bookId, currentPage);
  }

  @override
  Future<void> updateProgressWithTime(
    int bookId,
    int currentPage,
    int minutesRead,
  ) async {
    await _database.updateProgressWithTime(bookId, currentPage, minutesRead);
  }

  @override
  Future<void> addReadingTime(int bookId, int minutes) async {
    await _database.addReadingTime(bookId, minutes);
  }

  @override
  Future<void> completeReading(int bookId) async {
    await _database.completeReading(bookId);
  }

  @override
  Future<void> startReading(int bookId, int currentPage) async {
    await _database.startReading(bookId, currentPage);
  }

  @override
  Future<ReadingStatistics?> getReadingStatistics(int bookId) async {
    final books = await _database.getAllBooks();
    final book = books.where((b) => b.id == bookId).firstOrNull;

    if (book == null) return null;

    return ReadingStatistics(
      bookId: bookId,
      totalReadingTimeMinutes: book.totalReadingTimeMinutes,
      totalPagesRead: book.currentPage,
      readingSessions: 1, // Simplified - in real app, track actual sessions
      firstReadDate: book.startDate ?? DateTime.now(),
      lastReadDate: book.endDate,
      averageSessionLength: book.totalReadingTimeMinutes.toDouble(),
      averagePagesPerSession: book.currentPage.toDouble(),
    );
  }

  @override
  Future<List<ReadingSession>> getReadingHistory(int bookId) async {
    // Simplified implementation - in a real app, you'd have a separate sessions table
    final stats = await getReadingStatistics(bookId);
    if (stats == null) return [];

    return [
      ReadingSession(
        id: 1,
        bookId: bookId,
        startTime: stats.firstReadDate,
        endTime: stats.lastReadDate ?? DateTime.now(),
        minutesRead: stats.totalReadingTimeMinutes,
        pagesRead: stats.totalPagesRead,
      ),
    ];
  }

  @override
  Future<int> getTotalReadingTime() async {
    final books = await _database.getAllBooks();
    return books.fold<int>(
      0,
      (total, book) => total + book.totalReadingTimeMinutes,
    );
  }

  @override
  Future<ReadingStreak> getReadingStreak() async {
    final books = await _database.getAllBooks();
    final booksWithProgress = books.where((b) => b.startDate != null).toList();

    if (booksWithProgress.isEmpty) {
      return ReadingStreak(
        currentStreak: 0,
        longestStreak: 0,
        streakStartDate: DateTime(2024, 1, 1),
      );
    }

    // Simplified streak calculation
    final now = DateTime.now();
    final lastReadingDate = booksWithProgress
        .map((b) => b.endDate ?? b.startDate!)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    final daysSinceLastReading = now.difference(lastReadingDate).inDays;
    final currentStreak = daysSinceLastReading <= 1 ? 1 : 0;

    return ReadingStreak(
      currentStreak: currentStreak,
      longestStreak: currentStreak, // Simplified
      streakStartDate: lastReadingDate,
      lastReadingDate: lastReadingDate,
    );
  }

  @override
  Future<List<BookEntity>> getRecentlyActiveBooks({int days = 7}) async {
    final books = await _database.getAllBooks();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return books
        .where(
          (book) =>
              book.startDate != null && book.startDate!.isAfter(cutoffDate),
        )
        .map((book) => book.toEntity())
        .toList();
  }
}
