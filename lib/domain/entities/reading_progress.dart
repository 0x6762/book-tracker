class ReadingProgress {
  final int? id;
  final int bookId;
  final int currentPage;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCompleted;

  const ReadingProgress({
    this.id,
    required this.bookId,
    required this.currentPage,
    required this.startDate,
    this.endDate,
    this.isCompleted = false,
  });

  // Calculate progress percentage
  double getProgressPercentage(int totalPages) {
    if (totalPages <= 0) return 0.0;
    return (currentPage / totalPages * 100).clamp(0.0, 100.0);
  }

  // Calculate days reading
  int getDaysReading() {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate).inDays + 1;
  }

  // Create a copy with updated values
  ReadingProgress copyWith({
    int? id,
    int? bookId,
    int? currentPage,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
  }) {
    return ReadingProgress(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      currentPage: currentPage ?? this.currentPage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
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
