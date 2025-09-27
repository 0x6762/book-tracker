import 'reading_progress.dart';

class BookEntity {
  final int? id;
  final String googleBooksId;
  final String title;
  final String authors;
  final String? description;
  final String? thumbnailUrl;
  final String? publishedDate;
  final int? pageCount;
  final ReadingProgress? readingProgress;

  const BookEntity({
    this.id,
    required this.googleBooksId,
    required this.title,
    required this.authors,
    this.description,
    this.thumbnailUrl,
    this.publishedDate,
    this.pageCount,
    this.readingProgress,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookEntity && other.googleBooksId == googleBooksId;
  }

  @override
  int get hashCode => googleBooksId.hashCode;

  // Reading progress helpers
  double get progressPercentage {
    if (readingProgress == null || pageCount == null || pageCount! <= 0) {
      return 0.0;
    }
    return readingProgress!.getProgressPercentage(pageCount!);
  }

  bool get isCurrentlyReading =>
      readingProgress != null && !readingProgress!.isCompleted;

  bool get isCompleted => readingProgress?.isCompleted ?? false;

  bool get hasReadingProgress => readingProgress != null;

  int get daysReading => readingProgress?.getDaysReading() ?? 0;
}
