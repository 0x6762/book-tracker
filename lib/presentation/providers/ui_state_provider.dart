import 'package:flutter/foundation.dart';

/// Provider responsible for UI state management (modals, loading states, etc.)
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

  /// Show page update modal for a specific book
  void showPageUpdateModal(int bookId) {
    _shouldShowPageUpdateModal = true;
    _bookIdForPageUpdate = bookId;
    notifyListeners();
  }

  /// Hide page update modal
  void hidePageUpdateModal() {
    _shouldShowPageUpdateModal = false;
    _bookIdForPageUpdate = null;
    notifyListeners();
  }
}
