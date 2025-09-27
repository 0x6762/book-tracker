import '../repositories/books_repository.dart';

class CompleteReadingUseCase {
  final BooksRepository _repository;

  CompleteReadingUseCase(this._repository);

  Future<void> call(int bookId) async {
    await _repository.completeReading(bookId);
  }
}
