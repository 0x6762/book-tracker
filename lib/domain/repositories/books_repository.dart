import '../entities/book.dart';

abstract class BooksRepository {
  Future<List<BookEntity>> getAllBooks();
  Future<void> addBook(BookEntity book);
  Future<void> deleteBook(int id);
  Future<List<BookEntity>> searchBooks(String query);
}
