import 'package:flutter/foundation.dart';
import '../data/simple_database.dart';
import '../data/datasources/google_books_api_service.dart';
import '../domain/entities/book.dart';

class SimpleBookProvider with ChangeNotifier {
  final SimpleDatabase _database = SimpleDatabase();
  final GoogleBooksApiService _apiService = GoogleBooksApiService();

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

  Future<void> loadBooks() async {
    _setLoading(true);
    try {
      print('🔄 Loading books...');
      final stopwatch = Stopwatch()..start();

      final dbBooks = await _database.getAllBooks();
      _books = dbBooks.map((book) => book.toEntity()).toList();

      stopwatch.stop();
      print(
        '📚 Loaded ${_books.length} books in ${stopwatch.elapsedMilliseconds}ms',
      );
      _error = null;
    } catch (e) {
      print('❌ Error loading books: $e');
      _error = 'Failed to load books: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addBook(BookEntity book) async {
    try {
      // Check if book already exists
      final exists = await _database.bookExists(book.googleBooksId);
      if (exists) {
        _error = 'Book already exists in your library';
        notifyListeners();
        return;
      }

      await _database.insertBook(book.toCompanion());
      await loadBooks(); // Refresh list
    } catch (e) {
      _error = 'Failed to add book: $e';
      notifyListeners();
    }
  }

  Future<void> deleteBook(int id) async {
    try {
      await _database.deleteBook(id);
      await loadBooks(); // Refresh list
    } catch (e) {
      _error = 'Failed to delete book: $e';
      notifyListeners();
    }
  }

  Future<void> updateProgress(int bookId, int currentPage) async {
    try {
      // Check if book has reading progress
      final book = _books.firstWhere((b) => b.id == bookId);

      if (book.readingProgress == null) {
        // Start reading
        await _database.startReading(bookId, currentPage);
      } else {
        // Update progress
        await _database.updateProgress(bookId, currentPage);
      }

      await loadBooks(); // Refresh list
    } catch (e) {
      _error = 'Failed to update progress: $e';
      notifyListeners();
    }
  }

  Future<void> completeReading(int bookId) async {
    try {
      await _database.completeReading(bookId);
      await loadBooks(); // Refresh list
    } catch (e) {
      _error = 'Failed to complete reading: $e';
      notifyListeners();
    }
  }

  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    if (query.trim().length < 3) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _setSearching(true);
    try {
      _searchResults = await _apiService.searchBooks(query);
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
