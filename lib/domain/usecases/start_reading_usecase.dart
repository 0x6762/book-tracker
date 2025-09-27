import '../entities/reading_progress.dart';
import '../repositories/books_repository.dart';

class StartReadingUseCase {
  final BooksRepository _repository;

  StartReadingUseCase(this._repository);

  Future<void> call(int bookId, {int startPage = 1}) async {
    final readingProgress = ReadingProgress(
      bookId: bookId,
      currentPage: startPage,
      startDate: DateTime.now(),
      isCompleted: false,
    );

    await _repository.addReadingProgress(readingProgress);
  }
}
