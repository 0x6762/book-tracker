import 'package:drift/drift.dart';
import '../../domain/entities/reading_progress.dart' as domain;
import 'app_database.dart';

// Extension to convert between Drift data and ReadingProgress domain entity
extension DriftReadingProgressExtension on ReadingProgressData {
  // Convert from Drift data to domain entity
  domain.ReadingProgress toEntity() {
    return domain.ReadingProgress(
      id: id,
      bookId: bookId,
      currentPage: currentPage,
      startDate: startDate,
      endDate: endDate,
      isCompleted: isCompleted,
    );
  }
}

// Extension to convert from domain entity to Drift companion
extension DomainReadingProgressExtension on domain.ReadingProgress {
  // Convert from domain entity to Drift companion
  ReadingProgressCompanion toCompanion() {
    return ReadingProgressCompanion(
      id: id != null ? Value(id!) : const Value.absent(),
      bookId: Value(bookId),
      currentPage: Value(currentPage),
      startDate: Value(startDate),
      endDate: Value(endDate),
      isCompleted: Value(isCompleted),
    );
  }
}
