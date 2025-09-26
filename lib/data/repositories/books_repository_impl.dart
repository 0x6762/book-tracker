import '../../data/database/app_database.dart';
import '../../data/datasources/google_books_api_service.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/books_repository.dart';

class BooksRepositoryImpl implements BooksRepository {
  final AppDatabase _database;
  final GoogleBooksApiService _apiService;

  BooksRepositoryImpl({
    required AppDatabase database,
    required GoogleBooksApiService apiService,
  }) : _database = database,
       _apiService = apiService;

  @override
  Future<List<BookEntity>> getAllBooks() async {
    final books = await _database.getAllBooks();
    return books.map((book) => book.toEntity()).toList();
  }

  @override
  Future<void> addBook(BookEntity book) async {
    await _database.insertBook(book.toCompanion());
  }

  @override
  Future<void> deleteBook(int id) async {
    await _database.deleteBook(id);
  }

  @override
  Future<List<BookEntity>> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    return await _apiService.searchBooks(query);
  }
}
