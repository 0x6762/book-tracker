import 'package:flutter/foundation.dart';
import '../../data/database/app_database.dart';
import '../../domain/entities/book.dart';

class BookProvider with ChangeNotifier {
  final AppDatabase _database = AppDatabase();

  List<BookEntity> _books = [];
  bool _isLoading = false;
  String? _error;

  List<BookEntity> get books => _books;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBooks() async {
    _setLoading(true);
    try {
      final bookDataList = await _database.getAllBooks();
      _books = bookDataList.map((bookData) => bookData.toEntity()).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load books: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addBook(BookEntity book) async {
    try {
      await _database.insertBook(book.toCompanion());
      await loadBooks(); // Refresh the list
    } catch (e) {
      _error = 'Failed to add book: $e';
      notifyListeners();
    }
  }

  Future<void> deleteBook(int id) async {
    try {
      await _database.deleteBook(id);
      await loadBooks(); // Refresh the list
    } catch (e) {
      _error = 'Failed to delete book: $e';
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
