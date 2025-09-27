import '../entities/book.dart';
import '../entities/reading_progress.dart';

abstract class BooksRepository {
  Future<List<BookEntity>> getAllBooks();
  Future<void> addBook(BookEntity book);
  Future<void> deleteBook(int id);
  Future<List<BookEntity>> searchBooks(String query);

  // Reading progress methods
  Future<void> addReadingProgress(ReadingProgress progress);
  Future<void> updateReadingProgress(int bookId, int currentPage);
  Future<void> completeReading(int bookId);
  Future<ReadingProgress?> getReadingProgress(int bookId);
}
