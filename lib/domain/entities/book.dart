import 'reading_progress.dart';
import 'package:drift/drift.dart';
import '../../data/book_database.dart';

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
  final double? averageRating;
  final int? ratingsCount;

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
    this.averageRating,
    this.ratingsCount,
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

  // Rating helpers
  bool get hasRating => averageRating != null && averageRating! > 0;

  String get formattedRating {
    if (!hasRating) return 'No rating';
    return '${averageRating!.toStringAsFixed(1)}/5.0';
  }

  String get formattedRatingCount {
    if (ratingsCount == null || ratingsCount! <= 0) return '';
    if (ratingsCount! >= 1000) {
      return '(${(ratingsCount! / 1000).toStringAsFixed(1)}k)';
    }
    return '($ratingsCount)';
  }

  String get fullRatingText {
    if (!hasRating) return 'No rating';
    return '$formattedRating ${formattedRatingCount}';
  }

  // Create a copy with updated fields
  BookEntity copyWith({
    int? id,
    String? googleBooksId,
    String? title,
    String? authors,
    String? description,
    String? thumbnailUrl,
    String? publishedDate,
    int? pageCount,
    ReadingProgress? readingProgress,
    double? averageRating,
    int? ratingsCount,
  }) {
    return BookEntity(
      id: id ?? this.id,
      googleBooksId: googleBooksId ?? this.googleBooksId,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      publishedDate: publishedDate ?? this.publishedDate,
      pageCount: pageCount ?? this.pageCount,
      readingProgress: readingProgress ?? this.readingProgress,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
    );
  }

  // Convert to database companion
  BooksCompanion toCompanion() {
    return BooksCompanion(
      id: id != null ? Value(id!) : const Value.absent(),
      googleBooksId: Value(googleBooksId),
      title: Value(title),
      authors: Value(authors),
      description: Value(description),
      thumbnailUrl: Value(thumbnailUrl),
      publishedDate: Value(publishedDate),
      pageCount: Value(pageCount),
      currentPage: Value(readingProgress?.currentPage ?? 0),
      startDate: Value(readingProgress?.startDate),
      endDate: Value(readingProgress?.endDate),
      isCompleted: Value(readingProgress?.isCompleted ?? false),
      totalReadingTimeMinutes: Value(
        readingProgress?.totalReadingTimeMinutes ?? 0,
      ),
      averageRating: Value(averageRating),
      ratingsCount: Value(ratingsCount),
    );
  }
}
