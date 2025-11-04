import 'package:flutter/foundation.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/book.dart';

/// Provider responsible for book list management (CRUD operations)
class BookListProvider with ChangeNotifier {
  final ServiceLocator _serviceLocator = ServiceLocator();

  BookListProvider();

  List<BookEntity> _books = [];
  bool _isLoading = false;
  bool _isInitialized = false; // Track if we've loaded books at least once
  String? _error;
  String? _lastAddedBookId; // Track the last added book's Google Books ID

  // Getters
  List<BookEntity> get books => _books;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  String? get lastAddedBookId => _lastAddedBookId;

  /// Load all books from database
  Future<void> loadBooks() async {
    _setLoading(true);
    try {
      print('🔄 Loading books...');
      final stopwatch = Stopwatch()..start();

      final allBooks = await _serviceLocator.bookManagementService.getAllBooks();
      
      // Sort books: active books first, completed books last
      _books = [
        ...allBooks.where((book) => !book.isCompleted).toList(),
        ...allBooks.where((book) => book.isCompleted).toList(),
      ];

      stopwatch.stop();
      print(
        '📚 Loaded ${_books.length} books in ${stopwatch.elapsedMilliseconds}ms',
      );
      _error = null;
      _isInitialized = true; // Mark as initialized
    } catch (e) {
      print('❌ Error loading books: $e');
      _error = 'Failed to load books: $e';
      _isInitialized = true; // Mark as initialized even on error
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new book to the library
  Future<void> addBook(BookEntity book) async {
    try {
      // Check if book already exists
      final exists = await _serviceLocator.bookManagementService.bookExists(
        book.googleBooksId,
      );
      if (exists) {
        _error = 'Book already exists in your library';
        notifyListeners();
        return;
      }

      print('📖 Adding book: ${book.title}');
      final stopwatch = Stopwatch()..start();

      // Add book to database (color will be extracted in UI)
      await _serviceLocator.bookManagementService.addBookWithColor(book, null);

      // Load books to refresh the list
      await loadBooks();

      // Set the last added book ID for scrolling
      _lastAddedBookId = book.googleBooksId;

      stopwatch.stop();
      print('✅ Book added successfully in ${stopwatch.elapsedMilliseconds}ms');

      _error = null;
    } catch (e) {
      print('❌ Error adding book: $e');
      _error = 'Failed to add book: $e';
    }
  }

  /// Update an existing book
  Future<void> updateBook(BookEntity book) async {
    try {
      print('📝 Updating book: ${book.title}');
      await _serviceLocator.bookManagementService.updateBook(book);
      await loadBooks(); // Refresh the list
      _error = null;
    } catch (e) {
      print('❌ Error updating book: $e');
      _error = 'Failed to update book: $e';
    }
  }

  /// Delete a book from the library
  Future<void> deleteBook(String googleBooksId) async {
    try {
      print('🗑️ Deleting book: $googleBooksId');
      // Find the book by googleBooksId and delete by id
      final book = _books.firstWhere((b) => b.googleBooksId == googleBooksId);
      await _serviceLocator.bookManagementService.deleteBook(book.id!);
      await loadBooks(); // Refresh the list
      _error = null;
    } catch (e) {
      print('❌ Error deleting book: $e');
      _error = 'Failed to delete book: $e';
    }
  }

  /// Clear the last added book ID
  void clearLastAddedBookId() {
    _lastAddedBookId = null;
    notifyListeners();
  }

  /// Clear any error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
