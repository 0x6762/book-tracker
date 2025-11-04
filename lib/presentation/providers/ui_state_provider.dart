import 'package:flutter/foundation.dart';

/// Provider responsible for UI state management (progress update forms, loading states, etc.)
class UIStateProvider with ChangeNotifier {
  bool _isAddingBook = false;
  bool _shouldShowPageUpdateModal = false;
  int? _bookIdForPageUpdate;
  bool _isReadingSessionActive = false;

  // Getters
  bool get isAddingBook => _isAddingBook;
  bool get shouldShowPageUpdateModal => _shouldShowPageUpdateModal;
  int? get bookIdForPageUpdate => _bookIdForPageUpdate;
  bool get isReadingSessionActive => _isReadingSessionActive;

  /// Set adding book state
  void setAddingBook(bool adding) {
    _isAddingBook = adding;
    notifyListeners();
  }

  /// Start reading session (when user clicks Start/Continue Reading)
  void startReadingSession() {
    _isReadingSessionActive = true;
    notifyListeners();
  }

  /// End reading session (when progress update is completed or cancelled)
  void endReadingSession() {
    _isReadingSessionActive = false;
    notifyListeners();
  }

  /// Trigger embedded progress update form for a specific book
  /// Note: Despite the name "modal", this shows an embedded form in ReadingTimer widget
  void showPageUpdateModal(int bookId) {
    _shouldShowPageUpdateModal = true;
    _bookIdForPageUpdate = bookId;
    notifyListeners();
  }

  /// Hide embedded progress update form
  void hidePageUpdateModal() {
    _shouldShowPageUpdateModal = false;
    _bookIdForPageUpdate = null;
    notifyListeners();
  }
}
