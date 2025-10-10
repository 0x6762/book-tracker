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
