import '../repositories/books_repository.dart';

class UpdateProgressUseCase {
  final BooksRepository _repository;

  UpdateProgressUseCase(this._repository);

  Future<void> call(int bookId, int currentPage) async {
    await _repository.updateReadingProgress(bookId, currentPage);
  }
}
