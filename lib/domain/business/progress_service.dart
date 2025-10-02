import '../entities/book.dart';
import '../entities/reading_progress.dart';

/// Domain service for reading progress calculations and validations
class ProgressService {
  /// Calculate reading progress percentage with validation
  static double calculateProgressPercentage(BookEntity book) {
    if (book.readingProgress == null ||
        book.pageCount == null ||
        book.pageCount! <= 0) {
      return 0.0;
    }

    return book.readingProgress!.getProgressPercentage(book.pageCount!);
  }

  /// Validate if a progress update is valid
  static ProgressValidationResult validateProgressUpdate(
    BookEntity book,
    int newCurrentPage,
  ) {
    if (newCurrentPage < 0) {
      return ProgressValidationResult.invalid('Page number cannot be negative');
    }

    if (book.pageCount != null && newCurrentPage > book.pageCount!) {
      return ProgressValidationResult.invalid(
        'Page number cannot exceed total pages (${book.pageCount})',
      );
    }

    if (book.readingProgress != null) {
      final currentPage = book.readingProgress!.currentPage;
      if (newCurrentPage < currentPage) {
        return ProgressValidationResult.warning(
          'You are going backwards from page $currentPage to $newCurrentPage',
        );
      }

      // Check for unreasonably large jumps
      if (newCurrentPage - currentPage > 100) {
        return ProgressValidationResult.warning(
          'Large page jump detected (${newCurrentPage - currentPage} pages). Please confirm this is correct.',
        );
      }
    }

    return ProgressValidationResult.valid();
  }

  /// Calculate reading session statistics
  static ReadingSessionStats calculateSessionStats(
    BookEntity book,
    int minutesRead,
  ) {
    if (book.readingProgress == null || book.pageCount == null) {
      return ReadingSessionStats.empty();
    }

    final progress = book.readingProgress!;
    final pagesRead = _calculatePagesReadInSession(book, minutesRead);
    final pagesPerHour = minutesRead > 0
        ? (pagesRead / (minutesRead / 60.0))
        : 0.0;
    final estimatedTimeToComplete = _estimateTimeToComplete(
      book,
      progress,
      pagesPerHour,
    );

    return ReadingSessionStats(
      pagesRead: pagesRead,
      minutesRead: minutesRead,
      pagesPerHour: pagesPerHour,
      estimatedTimeToComplete: estimatedTimeToComplete,
      readingEfficiency: _calculateReadingEfficiency(pagesPerHour),
    );
  }

  /// Determine if a book is ready to be marked as completed
  static CompletionReadiness checkCompletionReadiness(BookEntity book) {
    if (book.readingProgress == null || book.pageCount == null) {
      return CompletionReadiness.notStarted();
    }

    // Get progress and calculate percentage
    final progressPercentage = calculateProgressPercentage(book);

    if (progressPercentage >= 100.0) {
      return CompletionReadiness.ready('Book is complete!');
    }

    if (progressPercentage >= 95.0) {
      return CompletionReadiness.almostReady(
        'Almost there! ${(100.0 - progressPercentage).toStringAsFixed(1)}% remaining',
      );
    }

    if (progressPercentage >= 80.0) {
      return CompletionReadiness.gettingClose(
        'Getting close! ${(100.0 - progressPercentage).toStringAsFixed(1)}% remaining',
      );
    }

    return CompletionReadiness.notReady(
      'Keep reading! ${(100.0 - progressPercentage).toStringAsFixed(1)}% remaining',
    );
  }

  static int _calculatePagesReadInSession(BookEntity book, int minutesRead) {
    if (book.readingProgress == null) return 0;

    // This is a simplified calculation - in a real app, you'd track actual pages read
    // For now, we'll estimate based on reading time and book characteristics
    final basePagesPerMinute = 0.5; // Base reading speed
    final bookComplexity = _getBookComplexity(book);
    final adjustedSpeed = basePagesPerMinute * bookComplexity;

    return (minutesRead * adjustedSpeed).round();
  }

  static double _getBookComplexity(BookEntity book) {
    // Simple complexity factor based on book characteristics
    if (book.pageCount == null) return 1.0;

    if (book.pageCount! > 500) return 0.8; // Longer books might be denser
    if (book.pageCount! < 200) return 1.2; // Shorter books might be easier
    return 1.0; // Average complexity
  }

  static int _estimateTimeToComplete(
    BookEntity book,
    ReadingProgress progress,
    double pagesPerHour,
  ) {
    if (book.pageCount == null || pagesPerHour == 0) return 0;

    final remainingPages = book.pageCount! - progress.currentPage;
    return (remainingPages / pagesPerHour * 60).round(); // Return minutes
  }

  static ReadingEfficiency _calculateReadingEfficiency(double pagesPerHour) {
    if (pagesPerHour >= 30) return ReadingEfficiency.veryFast();
    if (pagesPerHour >= 20) return ReadingEfficiency.fast();
    if (pagesPerHour >= 10) return ReadingEfficiency.moderate();
    if (pagesPerHour >= 5) return ReadingEfficiency.slow();
    return ReadingEfficiency.verySlow();
  }
}

/// Result of progress validation
class ProgressValidationResult {
  final bool isValid;
  final bool hasWarning;
  final String message;

  const ProgressValidationResult({
    required this.isValid,
    required this.hasWarning,
    required this.message,
  });

  factory ProgressValidationResult.valid() {
    return const ProgressValidationResult(
      isValid: true,
      hasWarning: false,
      message: '',
    );
  }

  factory ProgressValidationResult.warning(String message) {
    return ProgressValidationResult(
      isValid: true,
      hasWarning: true,
      message: message,
    );
  }

  factory ProgressValidationResult.invalid(String message) {
    return ProgressValidationResult(
      isValid: false,
      hasWarning: false,
      message: message,
    );
  }
}

/// Reading session statistics
class ReadingSessionStats {
  final int pagesRead;
  final int minutesRead;
  final double pagesPerHour;
  final int estimatedTimeToComplete; // in minutes
  final ReadingEfficiency readingEfficiency;

  const ReadingSessionStats({
    required this.pagesRead,
    required this.minutesRead,
    required this.pagesPerHour,
    required this.estimatedTimeToComplete,
    required this.readingEfficiency,
  });

  factory ReadingSessionStats.empty() {
    return ReadingSessionStats(
      pagesRead: 0,
      minutesRead: 0,
      pagesPerHour: 0.0,
      estimatedTimeToComplete: 0,
      readingEfficiency: ReadingEfficiency.unknown(),
    );
  }
}

/// Reading efficiency classification
class ReadingEfficiency {
  final String name;
  final String description;
  final double minPagesPerHour;

  const ReadingEfficiency({
    required this.name,
    required this.description,
    required this.minPagesPerHour,
  });

  factory ReadingEfficiency.veryFast() => const ReadingEfficiency(
    name: 'Very Fast',
    description: '30+ pages per hour',
    minPagesPerHour: 30.0,
  );

  factory ReadingEfficiency.fast() => const ReadingEfficiency(
    name: 'Fast',
    description: '20-29 pages per hour',
    minPagesPerHour: 20.0,
  );

  factory ReadingEfficiency.moderate() => const ReadingEfficiency(
    name: 'Moderate',
    description: '10-19 pages per hour',
    minPagesPerHour: 10.0,
  );

  factory ReadingEfficiency.slow() => const ReadingEfficiency(
    name: 'Slow',
    description: '5-9 pages per hour',
    minPagesPerHour: 5.0,
  );

  factory ReadingEfficiency.verySlow() => const ReadingEfficiency(
    name: 'Very Slow',
    description: 'Less than 5 pages per hour',
    minPagesPerHour: 0.0,
  );

  factory ReadingEfficiency.unknown() => const ReadingEfficiency(
    name: 'Unknown',
    description: 'Not enough data',
    minPagesPerHour: 0.0,
  );
}

/// Book completion readiness status
class CompletionReadiness {
  final bool isReady;
  final String message;
  final CompletionStatus status;

  const CompletionReadiness({
    required this.isReady,
    required this.message,
    required this.status,
  });

  factory CompletionReadiness.ready(String message) {
    return CompletionReadiness(
      isReady: true,
      message: message,
      status: CompletionStatus.ready,
    );
  }

  factory CompletionReadiness.almostReady(String message) {
    return CompletionReadiness(
      isReady: false,
      message: message,
      status: CompletionStatus.almostReady,
    );
  }

  factory CompletionReadiness.gettingClose(String message) {
    return CompletionReadiness(
      isReady: false,
      message: message,
      status: CompletionStatus.gettingClose,
    );
  }

  factory CompletionReadiness.notReady(String message) {
    return CompletionReadiness(
      isReady: false,
      message: message,
      status: CompletionStatus.notReady,
    );
  }

  factory CompletionReadiness.notStarted() {
    return const CompletionReadiness(
      isReady: false,
      message: 'Start reading to track progress',
      status: CompletionStatus.notStarted,
    );
  }
}

enum CompletionStatus { ready, almostReady, gettingClose, notReady, notStarted }
