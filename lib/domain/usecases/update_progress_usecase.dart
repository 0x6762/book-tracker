import '../repositories/books_repository.dart';
import '../entities/reading_progress.dart';

class UpdateProgressUseCase {
  final BooksRepository _repository;

  UpdateProgressUseCase(this._repository);

  Future<void> call(int bookId, int currentPage) async {
    // Check if reading progress already exists
    final existingProgress = await _repository.getReadingProgress(bookId);

    if (existingProgress == null) {
      // No progress exists, create new reading progress (start reading)
      final readingProgress = ReadingProgress(
        bookId: bookId,
        currentPage: currentPage,
        startDate: DateTime.now(),
        isCompleted: false,
      );
      await _repository.addReadingProgress(readingProgress);
    } else {
      // Progress exists, update it
      await _repository.updateReadingProgress(bookId, currentPage);
    }
  }
}
