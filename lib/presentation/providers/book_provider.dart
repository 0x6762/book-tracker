import 'package:flutter/foundation.dart';
import '../../data/database/app_database.dart';
import '../../data/datasources/google_books_api_service.dart';
import '../../data/repositories/books_repository_impl.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/books_repository.dart';
import '../../domain/usecases/start_reading_usecase.dart';
import '../../domain/usecases/update_progress_usecase.dart';
import '../../domain/usecases/complete_reading_usecase.dart';

class BookProvider with ChangeNotifier {
  final BooksRepository _repository;
  late final StartReadingUseCase _startReadingUseCase;
  late final UpdateProgressUseCase _updateProgressUseCase;
  late final CompleteReadingUseCase _completeReadingUseCase;
  static const int _minQueryLength = 3;

  List<BookEntity> _books = [];
  List<BookEntity> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  List<BookEntity> get books => _books;
  List<BookEntity> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;

  BookProvider({BooksRepository? repository})
    : _repository =
          repository ??
          BooksRepositoryImpl(
            database: AppDatabase(),
            apiService: GoogleBooksApiService(),
          ) {
    _startReadingUseCase = StartReadingUseCase(_repository);
    _updateProgressUseCase = UpdateProgressUseCase(_repository);
    _completeReadingUseCase = CompleteReadingUseCase(_repository);
  }

  Future<void> loadBooks() async {
    _setLoading(true);
    try {
      _books = await _repository.getAllBooks();
      _error = null;
    } catch (e) {
      _error = 'Failed to load books: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addBook(BookEntity book) async {
    try {
      await _repository.addBook(book);
      await loadBooks(); // Refresh the list
    } catch (e) {
      _error = 'Failed to add book: $e';
      notifyListeners();
    }
  }

  Future<void> deleteBook(int id) async {
    try {
      await _repository.deleteBook(id);
      await loadBooks(); // Refresh the list
    } catch (e) {
      _error = 'Failed to delete book: $e';
      notifyListeners();
    }
  }

  void searchBooks(String query) {
    final trimmedQuery = query.trim();

    // Clear results immediately if query is empty
    if (trimmedQuery.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    // Don't search if query is too short
    if (trimmedQuery.length < _minQueryLength) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    // Perform search immediately (no debouncing needed)
    _performSearch(trimmedQuery);
  }

  Future<void> _performSearch(String query) async {
    _setSearching(true);
    try {
      _searchResults = await _repository.searchBooks(query);
      _error = null;
    } catch (e) {
      _error = 'Failed to search books: $e';
    } finally {
      _setSearching(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  // Reading progress methods
  Future<void> startReading(int bookId) async {
    try {
      await _startReadingUseCase(bookId);
      await _refreshBooks();
    } catch (e) {
      _error = 'Failed to start reading: $e';
      notifyListeners();
    }
  }

  Future<void> updateProgress(int bookId, int currentPage) async {
    try {
      await _updateProgressUseCase(bookId, currentPage);
      await _refreshBooks();
    } catch (e) {
      _error = 'Failed to update progress: $e';
      notifyListeners();
    }
  }

  Future<void> completeReading(int bookId) async {
    try {
      await _completeReadingUseCase(bookId);
      await _refreshBooks();
    } catch (e) {
      _error = 'Failed to complete reading: $e';
      notifyListeners();
    }
  }

  Future<void> _refreshBooks() async {
    try {
      _books = await _repository.getAllBooks();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to refresh books: $e';
      notifyListeners();
    }
  }
}
