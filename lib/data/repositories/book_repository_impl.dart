import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../book_database.dart';
import '../mappers/book_mapper.dart';

/// Implementation of BookRepository using local database
class BookRepositoryImpl implements BookRepository {
  final BookDatabase _database;

  BookRepositoryImpl(this._database);

  @override
  Future<List<BookEntity>> getAllBooks() async {
    final dbBooks = await _database.getAllBooks();
    return dbBooks.map((book) => book.toEntity()).toList();
  }

  @override
  Future<BookEntity?> getBookById(int id) async {
    final dbBooks = await _database.getAllBooks();
    final book = dbBooks.where((b) => b.id == id).firstOrNull;
    return book?.toEntity();
  }

  @override
  Future<BookEntity?> getBookByGoogleId(String googleBooksId) async {
    final dbBooks = await _database.getAllBooks();
    final book = dbBooks
        .where((b) => b.googleBooksId == googleBooksId)
        .firstOrNull;
    return book?.toEntity();
  }

  @override
  Future<int> addBook(BookEntity book) async {
    return await _database.insertBook(BookMapper.toCompanion(book));
  }

  @override
  Future<void> updateBook(BookEntity book) async {
    await _database
        .update(_database.books)
        .replace(BookMapper.toCompanion(book));
  }

  @override
  Future<void> deleteBook(String googleBooksId) async {
    final book = await getBookByGoogleId(googleBooksId);
    if (book?.id != null) {
      await _database.deleteBook(book!.id!);
    }
  }

  @override
  Future<bool> bookExists(String googleBooksId) async {
    return await _database.bookExists(googleBooksId);
  }

  @override
  Future<List<BookEntity>> searchBooks(String query) async {
    final allBooks = await getAllBooks();
    if (query.trim().isEmpty) return allBooks;

    final lowercaseQuery = query.toLowerCase();
    return allBooks.where((book) {
      return book.title.toLowerCase().contains(lowercaseQuery) ||
          book.authors.toLowerCase().contains(lowercaseQuery) ||
          (book.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  @override
  Future<List<BookEntity>> getBooksByCompletionStatus(bool isCompleted) async {
    final allBooks = await getAllBooks();
    return allBooks.where((book) => book.isCompleted == isCompleted).toList();
  }

  @override
  Future<List<BookEntity>> getCurrentlyReadingBooks() async {
    final allBooks = await getAllBooks();
    return allBooks.where((book) => book.isCurrentlyReading).toList();
  }

  @override
  Future<List<BookEntity>> getCompletedBooks() async {
    return await getBooksByCompletionStatus(true);
  }

  @override
  Future<List<BookEntity>> getRecentlyAddedBooks({int limit = 10}) async {
    final allBooks = await getAllBooks();
    // Sort by ID descending (assuming higher ID = more recent)
    allBooks.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return allBooks.take(limit).toList();
  }

  @override
  Future<List<BookEntity>> getBooksByAuthor(String author) async {
    final allBooks = await getAllBooks();
    final lowercaseAuthor = author.toLowerCase();
    return allBooks
        .where((book) => book.authors.toLowerCase().contains(lowercaseAuthor))
        .toList();
  }

  @override
  Future<List<BookEntity>> getBooksByRating({
    double minRating = 0.0,
    double maxRating = 5.0,
  }) async {
    final allBooks = await getAllBooks();
    return allBooks.where((book) {
      if (book.averageRating == null) return false;
      return book.averageRating! >= minRating &&
          book.averageRating! <= maxRating;
    }).toList();
  }
}
