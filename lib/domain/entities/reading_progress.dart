class ReadingProgress {
  final int? id;
  final int bookId;
  final int currentPage;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCompleted;
  final int totalReadingTimeMinutes;

  const ReadingProgress({
    this.id,
    required this.bookId,
    required this.currentPage,
    required this.startDate,
    this.endDate,
    this.isCompleted = false,
    this.totalReadingTimeMinutes = 0,
  });

  // Calculate progress percentage
  double getProgressPercentage(int totalPages) {
    if (totalPages <= 0) return 0.0;
    if (currentPage < 0) return 0.0;
    if (currentPage > totalPages) return 100.0; // Cap at 100% if over
    return (currentPage / totalPages * 100).clamp(0.0, 100.0);
  }

  // Calculate days reading
  int getDaysReading() {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate).inDays + 1;
  }

  // Calculate reading streak (consecutive days with reading activity)
  int getReadingStreak() {
    // For now, we'll use a simple calculation based on total reading time
    // In a more advanced implementation, this would track daily reading sessions
    if (totalReadingTimeMinutes <= 0) return 0;

    // Estimate streak based on reading consistency
    // If user has been reading for multiple days with good time, assume streak
    final daysReading = getDaysReading();
    if (daysReading <= 1) return 1;

    // Simple heuristic: if reading time is substantial and spread over days
    final avgMinutesPerDay = totalReadingTimeMinutes / daysReading;
    if (avgMinutesPerDay >= 15) {
      // At least 15 minutes per day average
      return daysReading; // Assume they've been reading consistently
    }

    return 1; // At least 1 day if they have any reading time
  }

  // Format reading time as human-readable string
  String getFormattedReadingTime() {
    if (totalReadingTimeMinutes <= 0) return 'No reading time';

    final hours = totalReadingTimeMinutes ~/ 60;
    final minutes = totalReadingTimeMinutes % 60;

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  // Calculate sessions per week
  int getSessionsPerWeek() {
    if (getDaysReading() <= 0 || totalReadingTimeMinutes <= 0) {
      return 0;
    }

    // Calculate how many reading sessions per week
    // Assume each timer session is ~30 minutes on average
    const avgSessionMinutes = 30;
    final totalSessions = (totalReadingTimeMinutes / avgSessionMinutes).round();

    // Calculate weeks of reading
    final weeksReading = (getDaysReading() / 7).clamp(1.0, double.infinity);

    // Sessions per week
    return (totalSessions / weeksReading).round();
  }

  // Calculate average session time
  String getAverageSessionTime() {
    if (getDaysReading() <= 0 || totalReadingTimeMinutes <= 0) {
      return '0m';
    }

    // Calculate average session time based on total reading time and days
    // This gives a more realistic average since users don't read every day
    final avgMinutes = totalReadingTimeMinutes / getDaysReading();
    final hours = avgMinutes ~/ 60;
    final minutes = (avgMinutes % 60).round();

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  // Calculate pages per hour
  int getPagesPerHour(int totalPages) {
    if (totalReadingTimeMinutes <= 0 || totalPages <= 0 || currentPage <= 0) {
      return 0;
    }

    final hours = totalReadingTimeMinutes / 60;
    if (hours <= 0) return 0;

    // Calculate pages per hour based on current page progress
    // This assumes reading started from page 1 (or 0), which is typical
    final pagesPerHour = (currentPage / hours).round();

    // Cap at reasonable reading speed (e.g., 100 pages/hour max)
    return pagesPerHour.clamp(0, 100);
  }

  // Format last read date with relative time
  String getLastReadFormatted() {
    final last = endDate ?? startDate;
    final now = DateTime.now();
    final difference = now.difference(last);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) {
      return '${difference.inHours} hr${difference.inHours == 1 ? '' : 's'} ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }

    // Fallback to short date like "Oct 14, 2025"
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
    final m = months[last.month - 1];
    return '$m ${last.day}, ${last.year}';
  }

  // Create a copy with updated values
  ReadingProgress copyWith({
    int? id,
    int? bookId,
    int? currentPage,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    int? totalReadingTimeMinutes,
  }) {
    return ReadingProgress(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      currentPage: currentPage ?? this.currentPage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      totalReadingTimeMinutes:
          totalReadingTimeMinutes ?? this.totalReadingTimeMinutes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingProgress && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
