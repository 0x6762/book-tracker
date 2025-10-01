import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/simple_database.dart';
import '../../data/datasources/google_books_api_service.dart';
import '../../domain/entities/book.dart';
import '../utils/color_extractor.dart';

class BookProvider with ChangeNotifier {
  final SimpleDatabase _database = SimpleDatabase();
  final GoogleBooksApiService _apiService = GoogleBooksApiService();

  BookProvider() {
    // Initialize ColorExtractor with database reference
    ColorExtractor.initializeDatabase(_database);
  }

  List<BookEntity> _books = [];
  List<BookEntity> _searchResults = [];
  bool _isLoading =
      true; // Start with loading true to prevent empty state flash
  bool _isSearching = false;
  bool _isAddingBook = false;
  String? _error;
  String? _lastAddedBookId; // Track the last added book's Google Books ID

  // Page update modal state
  bool _shouldShowPageUpdateModal = false;
  int? _bookIdForPageUpdate;

  List<BookEntity> get books => _books;
  List<BookEntity> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isAddingBook => _isAddingBook;
  String? get error => _error;
  String? get lastAddedBookId => _lastAddedBookId;
  bool get shouldShowPageUpdateModal => _shouldShowPageUpdateModal;
  int? get bookIdForPageUpdate => _bookIdForPageUpdate;

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
    _setAddingBook(true);
    try {
      // Check if book already exists
      final exists = await _database.bookExists(book.googleBooksId);
      if (exists) {
        _error = 'Book already exists in your library';
        notifyListeners();
        return;
      }

      print('📖 Adding book: ${book.title}');
      final stopwatch = Stopwatch()..start();

      // Add book to database
      await _database.insertBook(book.toCompanion());

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
    } finally {
      _setAddingBook(false);
    }
  }

  Future<void> updateBook(BookEntity book) async {
    try {
      print('📝 Updating book: ${book.title}');
      await _database.update(_database.books).replace(book.toCompanion());
      await loadBooks(); // Refresh the list
      _error = null;
    } catch (e) {
      print('❌ Error updating book: $e');
      _error = 'Failed to update book: $e';
    }
  }

  Future<void> deleteBook(String googleBooksId) async {
    try {
      print('🗑️ Deleting book: $googleBooksId');
      // Find the book by googleBooksId and delete by id
      final book = _books.firstWhere((b) => b.googleBooksId == googleBooksId);
      await _database.deleteBook(book.id!);
      await loadBooks(); // Refresh the list
      _error = null;
    } catch (e) {
      print('❌ Error deleting book: $e');
      _error = 'Failed to delete book: $e';
    }
  }

  Future<void> searchBooks(String query) async {
    if (query.isEmpty) {
      _setSearching(false);
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setSearching(true);
    try {
      print('🔍 Searching for: $query');
      final stopwatch = Stopwatch()..start();

      final results = await _apiService.searchBooks(query);
      _searchResults = results;

      stopwatch.stop();
      print(
        '🔍 Found ${results.length} results in ${stopwatch.elapsedMilliseconds}ms',
      );
      _error = null;
    } catch (e) {
      print('❌ Error searching books: $e');
      _error = 'Failed to search books: $e';
      _searchResults = [];
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

  void _setAddingBook(bool adding) {
    _isAddingBook = adding;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearLastAddedBookId() {
    _lastAddedBookId = null;
    notifyListeners();
  }

  // Page update modal methods
  void showPageUpdateModal(int bookId) {
    _shouldShowPageUpdateModal = true;
    _bookIdForPageUpdate = bookId;
    notifyListeners();
  }

  void hidePageUpdateModal() {
    _shouldShowPageUpdateModal = false;
    _bookIdForPageUpdate = null;
    notifyListeners();
  }

  // Add reading time to book
  Future<void> addReadingTimeToBook(int bookId, int minutesRead) async {
    try {
      final book = _books.firstWhere((b) => b.id == bookId);
      await _database.addReadingTime(bookId, minutesRead);
      await loadBooks(); // Refresh the list
      print('📖 Added $minutesRead minutes to ${book.title}');
    } catch (e) {
      print('❌ Error adding reading time: $e');
    }
  }

  // Update reading progress
  Future<void> updateProgress(int bookId, int currentPage) async {
    try {
      await _database.updateProgress(bookId, currentPage);
      await loadBooks(); // Refresh the list
      print('📖 Updated progress for book $bookId to page $currentPage');
    } catch (e) {
      print('❌ Error updating progress: $e');
    }
  }

  // Complete reading
  Future<void> completeReading(int bookId) async {
    try {
      await _database.completeReading(bookId);
      await loadBooks(); // Refresh the list
      print('📖 Marked book $bookId as completed');
    } catch (e) {
      print('❌ Error completing book: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
