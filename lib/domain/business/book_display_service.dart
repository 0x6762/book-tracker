import '../entities/book.dart';

/// Service for handling book display-related business logic
class BookDisplayService {
  /// Format a date for display in a short format (e.g., "Jan 14, 2025")
  static String formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[date.month - 1];
    return '$m ${date.day}, ${date.year}';
  }

  /// Get the appropriate display text for reading progress button
  static String getProgressButtonText(BookEntity book) {
    if (!book.hasReadingProgress) {
      return 'Start Reading';
    }
    return book.isCompleted ? 'Update Progress' : 'Update';
  }

  /// Check if a book should show advanced statistics
  static bool shouldShowAdvancedStats(BookEntity book) {
    if (book.readingProgress == null) return false;

    final progress = book.readingProgress!;
    return progress.totalReadingTimeMinutes > 0 &&
        book.daysReading > 0 &&
        book.pageCount != null &&
        progress.currentPage > 0;
  }

  /// Get the appropriate icon for a book cover when no image is available
  static String getBookCoverPlaceholder() {
    return 'book'; // This will be used with Icons.book
  }

  /// Get the appropriate tooltip text for book actions
  static String getBookActionTooltip(String action) {
    switch (action) {
      case 'delete':
        return 'Remove book from library';
      case 'edit':
        return 'Edit book details';
      default:
        return 'Book action';
    }
  }
}
