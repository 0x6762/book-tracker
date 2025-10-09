/// Domain service for book-related business validation
class BookValidationService {
  /// Validate current page number
  static void validateCurrentPage(int currentPage, int? totalPages) {
    if (currentPage < 0) {
      throw ArgumentError('Current page cannot be negative');
    }

    if (totalPages != null && currentPage > totalPages) {
      throw ArgumentError('Current page cannot exceed total page count');
    }
  }

  /// Validate reading time
  static void validateReadingTime(int minutes) {
    if (minutes < 0) {
      throw ArgumentError('Reading time cannot be negative');
    }

    // Prevent overflow (reasonable limit: 10 years of reading)
    if (minutes > 5256000) {
      // 10 years in minutes
      throw ArgumentError('Reading time exceeds reasonable limit');
    }
  }

  /// Validate book exists
  static void validateBookExists(dynamic book) {
    if (book == null) {
      throw ArgumentError('Book not found');
    }
  }

  /// Validate total reading time calculation
  static int validateTotalReadingTime(int currentTotal, int additionalMinutes) {
    final newTotal = currentTotal + additionalMinutes;
    validateReadingTime(newTotal);
    return newTotal;
  }
}
