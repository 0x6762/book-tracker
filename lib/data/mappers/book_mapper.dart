import 'package:drift/drift.dart';
import '../../domain/entities/book.dart';
import '../book_database.dart';

/// Mapper class to convert between domain entities and database models
class BookMapper {
  /// Convert BookEntity to BooksCompanion for database operations
  static BooksCompanion toCompanion(BookEntity book) {
    return BooksCompanion(
      id: book.id != null ? Value(book.id!) : const Value.absent(),
      googleBooksId: Value(book.googleBooksId),
      title: Value(book.title),
      authors: Value(book.authors),
      description: Value(book.description),
      thumbnailUrl: Value(book.thumbnailUrl),
      publishedDate: Value(book.publishedDate),
      pageCount: Value(book.pageCount),
      currentPage: Value(book.readingProgress?.currentPage ?? 0),
      startDate: Value(book.readingProgress?.startDate),
      endDate: Value(book.readingProgress?.endDate),
      isCompleted: Value(book.readingProgress?.isCompleted ?? false),
      totalReadingTimeMinutes: Value(
        book.readingProgress?.totalReadingTimeMinutes ?? 0,
      ),
      averageRating: Value(book.averageRating),
      ratingsCount: Value(book.ratingsCount),
    );
  }

  /// Convert BookEntity to BookColorsCompanion for color operations
  static BookColorsCompanion toColorCompanion(int bookId, int accentColor) {
    return BookColorsCompanion(
      bookId: Value(bookId),
      accentColor: Value(accentColor),
      extractedAt: Value(DateTime.now()),
    );
  }
}
