import 'package:flutter/foundation.dart';

/// Provider responsible for UI state management (progress update forms, loading states, etc.)
class UIStateProvider with ChangeNotifier {
  bool _isAddingBook = false;
  bool _shouldShowPageUpdateModal = false;
  int? _bookIdForPageUpdate;

  // Getters
  bool get isAddingBook => _isAddingBook;
  bool get shouldShowPageUpdateModal => _shouldShowPageUpdateModal;
  int? get bookIdForPageUpdate => _bookIdForPageUpdate;

  /// Set adding book state
  void setAddingBook(bool adding) {
    _isAddingBook = adding;
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
