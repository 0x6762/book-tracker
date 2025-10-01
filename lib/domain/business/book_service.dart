import '../entities/book.dart';
import '../entities/reading_progress.dart';

/// Domain service for complex book-related business operations
class BookService {
  /// Calculate reading statistics for a book
  static BookReadingStats calculateReadingStats(BookEntity book) {
    if (book.readingProgress == null) {
      return BookReadingStats.empty();
    }

    final progress = book.readingProgress!;
    final daysReading = progress.getDaysReading();
    final avgMinutesPerDay = daysReading > 0
        ? progress.totalReadingTimeMinutes / daysReading
        : 0.0;
    final pagesPerHour = _calculatePagesPerHour(book, progress);
    final estimatedTimeToComplete = _estimateTimeToComplete(book, progress);

    return BookReadingStats(
      daysReading: daysReading,
      averageMinutesPerDay: avgMinutesPerDay,
      pagesPerHour: pagesPerHour,
      estimatedTimeToComplete: estimatedTimeToComplete,
      readingStreak: _calculateReadingStreak(book, progress),
    );
  }

  /// Determine if a book should be recommended for reading
  static bool shouldRecommendBook(BookEntity book) {
    if (book.isCompleted) return false;
    if (book.readingProgress == null) return true;

    final progress = book.readingProgress!;
    final daysSinceLastRead = DateTime.now()
        .difference(progress.startDate)
        .inDays;

    // Recommend if not started or if it's been more than 7 days since last activity
    return progress.currentPage == 0 || daysSinceLastRead > 7;
  }

  /// Calculate reading pace based on recent activity
  static ReadingPace calculateReadingPace(BookEntity book) {
    if (book.readingProgress == null || book.pageCount == null) {
      return ReadingPace.unknown();
    }

    final progress = book.readingProgress!;
    final daysReading = progress.getDaysReading();

    if (daysReading == 0) return ReadingPace.unknown();

    final pagesPerDay = progress.currentPage / daysReading;
    final minutesPerDay = progress.totalReadingTimeMinutes / daysReading;

    if (pagesPerDay >= 20) return ReadingPace.fast();
    if (pagesPerDay >= 10) return ReadingPace.moderate();
    if (pagesPerDay >= 5) return ReadingPace.slow();
    return ReadingPace.verySlow();
  }

  /// Validate if a page update is reasonable
  static bool isValidPageUpdate(BookEntity book, int newPage) {
    if (newPage < 0) return false;
    if (book.pageCount != null && newPage > book.pageCount!) return false;
    if (book.readingProgress == null) return true;

    final currentPage = book.readingProgress!.currentPage;
    // Allow reasonable page jumps (up to 50 pages forward)
    return newPage >= currentPage && (newPage - currentPage) <= 50;
  }

  static double _calculatePagesPerHour(
    BookEntity book,
    ReadingProgress progress,
  ) {
    if (progress.totalReadingTimeMinutes == 0 || book.pageCount == null)
      return 0.0;
    final hours = progress.totalReadingTimeMinutes / 60.0;
    return progress.currentPage / hours;
  }

  static int _estimateTimeToComplete(
    BookEntity book,
    ReadingProgress progress,
  ) {
    if (book.pageCount == null || progress.currentPage >= book.pageCount!)
      return 0;

    final remainingPages = book.pageCount! - progress.currentPage;
    final pagesPerHour = _calculatePagesPerHour(book, progress);

    if (pagesPerHour == 0) return 0;
    return (remainingPages / pagesPerHour * 60).round(); // Return minutes
  }

  static int _calculateReadingStreak(
    BookEntity book,
    ReadingProgress progress,
  ) {
    // Simplified streak calculation - in a real app, this would be more complex
    return progress.getDaysReading();
  }
}

/// Reading statistics for a book
class BookReadingStats {
  final int daysReading;
  final double averageMinutesPerDay;
  final double pagesPerHour;
  final int estimatedTimeToComplete; // in minutes
  final int readingStreak;

  const BookReadingStats({
    required this.daysReading,
    required this.averageMinutesPerDay,
    required this.pagesPerHour,
    required this.estimatedTimeToComplete,
    required this.readingStreak,
  });

  factory BookReadingStats.empty() {
    return const BookReadingStats(
      daysReading: 0,
      averageMinutesPerDay: 0.0,
      pagesPerHour: 0.0,
      estimatedTimeToComplete: 0,
      readingStreak: 0,
    );
  }

  String get formattedAverageTimePerDay {
    if (averageMinutesPerDay == 0) return 'No reading time';
    final hours = (averageMinutesPerDay / 60).floor();
    final minutes = (averageMinutesPerDay % 60).round();
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  String get formattedEstimatedTimeToComplete {
    if (estimatedTimeToComplete == 0) return 'Unknown';
    final hours = estimatedTimeToComplete ~/ 60;
    final minutes = estimatedTimeToComplete % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }
}

/// Reading pace classification
class ReadingPace {
  final String name;
  final String description;
  final double minPagesPerDay;

  const ReadingPace({
    required this.name,
    required this.description,
    required this.minPagesPerDay,
  });

  factory ReadingPace.fast() => const ReadingPace(
    name: 'Fast',
    description: 'Reading 20+ pages per day',
    minPagesPerDay: 20.0,
  );

  factory ReadingPace.moderate() => const ReadingPace(
    name: 'Moderate',
    description: 'Reading 10-19 pages per day',
    minPagesPerDay: 10.0,
  );

  factory ReadingPace.slow() => const ReadingPace(
    name: 'Slow',
    description: 'Reading 5-9 pages per day',
    minPagesPerDay: 5.0,
  );

  factory ReadingPace.verySlow() => const ReadingPace(
    name: 'Very Slow',
    description: 'Reading less than 5 pages per day',
    minPagesPerDay: 0.0,
  );

  factory ReadingPace.unknown() => const ReadingPace(
    name: 'Unknown',
    description: 'Not enough data to determine pace',
    minPagesPerDay: 0.0,
  );
}
