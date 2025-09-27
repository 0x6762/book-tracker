import '../../data/database/app_database.dart';
import '../../data/database/database_extensions.dart';
import '../../data/datasources/google_books_api_service.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_progress.dart' as domain;
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
    final allProgress = await _database.getAllReadingProgress();

    // Create a map for quick lookup
    final progressMap = <int, ReadingProgressData>{};
    for (final progress in allProgress) {
      progressMap[progress.bookId] = progress;
    }

    return books.map((book) {
      final bookEntity = book.toEntity();
      final readingProgress = progressMap[book.id];
      return BookEntity(
        id: bookEntity.id,
        googleBooksId: bookEntity.googleBooksId,
        title: bookEntity.title,
        authors: bookEntity.authors,
        description: bookEntity.description,
        thumbnailUrl: bookEntity.thumbnailUrl,
        publishedDate: bookEntity.publishedDate,
        pageCount: bookEntity.pageCount,
        readingProgress: readingProgress?.toEntity(),
      );
    }).toList();
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

  @override
  Future<void> addReadingProgress(domain.ReadingProgress progress) async {
    await _database.insertReadingProgress(progress.toCompanion());
  }

  @override
  Future<void> updateReadingProgress(int bookId, int currentPage) async {
    final existingProgress = await _database.getReadingProgressByBookId(bookId);
    if (existingProgress != null) {
      final updatedProgress = existingProgress.toEntity().copyWith(
        currentPage: currentPage,
      );
      await _database.updateReadingProgress(updatedProgress.toCompanion());
    }
  }

  @override
  Future<void> completeReading(int bookId) async {
    final existingProgress = await _database.getReadingProgressByBookId(bookId);
    if (existingProgress != null) {
      final completedProgress = existingProgress.toEntity().copyWith(
        isCompleted: true,
        endDate: DateTime.now(),
      );
      await _database.updateReadingProgress(completedProgress.toCompanion());
    }
  }

  @override
  Future<domain.ReadingProgress?> getReadingProgress(int bookId) async {
    final progress = await _database.getReadingProgressByBookId(bookId);
    return progress?.toEntity();
  }
}
