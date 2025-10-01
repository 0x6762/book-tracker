import '../../data/book_database.dart';
import '../../data/mappers/book_mapper.dart';
import '../../domain/entities/book.dart';

/// Application service for book management operations
class BookManagementService {
  final BookDatabase _database;

  BookManagementService(this._database);

  /// Add a book with color extraction
  Future<int> addBookWithColor(BookEntity book, int? accentColor) async {
    return await _database.addBookWithColor(
      BookMapper.toCompanion(book),
      accentColor,
    );
  }

  /// Check if a book exists in the library
  Future<bool> bookExists(String googleBooksId) async {
    return await _database.bookExists(googleBooksId);
  }

  /// Get all books from the library
  Future<List<BookEntity>> getAllBooks() async {
    final dbBooks = await _database.getAllBooks();
    return dbBooks.map((book) => book.toEntity()).toList();
  }

  /// Update a book in the library
  Future<void> updateBook(BookEntity book) async {
    await _database
        .update(_database.books)
        .replace(BookMapper.toCompanion(book));
  }

  /// Delete a book from the library
  Future<void> deleteBook(int bookId) async {
    await _database.deleteBook(bookId);
  }
}
