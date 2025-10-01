import '../entities/book.dart';

/// Repository interface for book data operations
/// This defines the contract that data layer implementations must follow
abstract class BookRepository {
  /// Get all books
  Future<List<BookEntity>> getAllBooks();

  /// Get a book by its ID
  Future<BookEntity?> getBookById(int id);

  /// Get a book by its Google Books ID
  Future<BookEntity?> getBookByGoogleId(String googleBooksId);

  /// Add a new book
  Future<int> addBook(BookEntity book);

  /// Update an existing book
  Future<void> updateBook(BookEntity book);

  /// Delete a book by its Google Books ID
  Future<void> deleteBook(String googleBooksId);

  /// Check if a book exists by Google Books ID
  Future<bool> bookExists(String googleBooksId);

  /// Search books by query
  Future<List<BookEntity>> searchBooks(String query);

  /// Get books by completion status
  Future<List<BookEntity>> getBooksByCompletionStatus(bool isCompleted);

  /// Get books by reading status
  Future<List<BookEntity>> getCurrentlyReadingBooks();

  /// Get completed books
  Future<List<BookEntity>> getCompletedBooks();

  /// Get recently added books
  Future<List<BookEntity>> getRecentlyAddedBooks({int limit = 10});

  /// Get books by author
  Future<List<BookEntity>> getBooksByAuthor(String author);

  /// Get books by rating range
  Future<List<BookEntity>> getBooksByRating({
    double minRating = 0.0,
    double maxRating = 5.0,
  });
}
