import '../entities/book.dart';

/// Repository interface for reading progress operations
abstract class ProgressRepository {
  /// Update reading progress for a book
  Future<void> updateProgress(int bookId, int currentPage);

  /// Update progress and reading time atomically
  Future<void> updateProgressWithTime(
    int bookId,
    int currentPage,
    int minutesRead,
  );

  /// Add reading time to a book
  Future<void> addReadingTime(int bookId, int minutes);

  /// Mark a book as completed
  Future<void> completeReading(int bookId);

  /// Start reading a book
  Future<void> startReading(int bookId, int currentPage);

  /// Get reading statistics for a book
  Future<ReadingStatistics?> getReadingStatistics(int bookId);

  /// Get reading history for a book
  Future<List<ReadingSession>> getReadingHistory(int bookId);

  /// Get total reading time across all books
  Future<int> getTotalReadingTime();

  /// Get reading streak information
  Future<ReadingStreak> getReadingStreak();

  /// Get books with recent activity
  Future<List<BookEntity>> getRecentlyActiveBooks({int days = 7});
}

/// Reading statistics for a book
class ReadingStatistics {
  final int bookId;
  final int totalReadingTimeMinutes;
  final int totalPagesRead;
  final int readingSessions;
  final DateTime firstReadDate;
  final DateTime? lastReadDate;
  final double averageSessionLength; // in minutes
  final double averagePagesPerSession;

  const ReadingStatistics({
    required this.bookId,
    required this.totalReadingTimeMinutes,
    required this.totalPagesRead,
    required this.readingSessions,
    required this.firstReadDate,
    this.lastReadDate,
    required this.averageSessionLength,
    required this.averagePagesPerSession,
  });
}

/// Individual reading session
class ReadingSession {
  final int id;
  final int bookId;
  final DateTime startTime;
  final DateTime endTime;
  final int minutesRead;
  final int pagesRead;
  final String? notes;

  const ReadingSession({
    required this.id,
    required this.bookId,
    required this.startTime,
    required this.endTime,
    required this.minutesRead,
    required this.pagesRead,
    this.notes,
  });
}

/// Reading streak information
class ReadingStreak {
  final int currentStreak; // days
  final int longestStreak; // days
  final DateTime streakStartDate;
  final DateTime? lastReadingDate;

  const ReadingStreak({
    required this.currentStreak,
    required this.longestStreak,
    required this.streakStartDate,
    this.lastReadingDate,
  });

  bool get isActive =>
      lastReadingDate != null &&
      DateTime.now().difference(lastReadingDate!).inDays <= 1;
}
