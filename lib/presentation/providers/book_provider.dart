import 'package:flutter/foundation.dart';
import '../../data/database/app_database.dart';
import '../../data/datasources/google_books_api_service.dart';
import '../../data/repositories/books_repository_impl.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/books_repository.dart';

class BookProvider with ChangeNotifier {
  final BooksRepository _repository;

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
          );

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

  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

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
}
