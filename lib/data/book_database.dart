import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../domain/entities/book.dart';
import '../domain/entities/reading_progress.dart';
import '../domain/business/book_validation_service.dart';

part 'book_database.g.dart';

// Simplified table with reading progress embedded
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get googleBooksId => text().unique()();
  TextColumn get title => text()();
  TextColumn get authors => text()();
  TextColumn get description => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get publishedDate => text().nullable()();
  IntColumn get pageCount => integer().nullable()();

  // Reading progress fields embedded in books table
  IntColumn get currentPage => integer().withDefault(const Constant(0))();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  // Reading time tracking
  IntColumn get totalReadingTimeMinutes =>
      integer().withDefault(const Constant(0))();

  // Book ratings
  RealColumn get averageRating => real().nullable()();
  IntColumn get ratingsCount => integer().nullable()();

  Set<Index> get indexes => {
    Index('idx_google_books_id', 'googleBooksId'),
    Index('idx_is_completed', 'isCompleted'),
    Index('idx_start_date', 'startDate'),
  };
}

// Book colors table for caching extracted accent colors
class BookColors extends Table {
  IntColumn get bookId => integer().references(Books, #id)();
  IntColumn get accentColor => integer().nullable()();
  DateTimeColumn get extractedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {bookId};
}

// Daily reading activity tracking for accurate streak calculation
class DailyReadingActivity extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId =>
      integer().references(Books, #id).nullable()(); // null = global activity
  DateTimeColumn get activityDate => dateTime()(); // Date only (no time)
  IntColumn get minutesRead => integer().withDefault(const Constant(0))();
  IntColumn get pagesRead => integer().withDefault(const Constant(0))();
  IntColumn get sessionCount => integer().withDefault(const Constant(0))();

  Set<Index> get indexes => {
    Index('idx_activity_date', 'activityDate'),
    Index('idx_book_activity', 'bookId, activityDate'),
  };
}

@DriftDatabase(tables: [Books, BookColors, DailyReadingActivity])
class BookDatabase extends _$BookDatabase {
  BookDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Add totalReadingTimeMinutes column
        await m.addColumn(books, books.totalReadingTimeMinutes);
      }
      if (from < 3) {
        // Add rating columns
        await m.addColumn(books, books.averageRating);
        await m.addColumn(books, books.ratingsCount);
      }
      if (from < 4) {
        // Add BookColors table
        await m.createTable(bookColors);
      }
    },
  );

  // Simple methods - no complex joins needed
  Future<List<Book>> getAllBooks() => select(books).get();

  Future<int> insertBook(BooksCompanion book) => into(books).insert(book);

  // Transactional method to add book with color extraction
  Future<int> addBookWithColor(BooksCompanion book, int? accentColor) async {
    return await transaction(() async {
      // Insert the book
      final bookId = await into(books).insert(book);

      // If color is provided, insert it
      if (accentColor != null) {
        await into(bookColors).insert(
          BookColorsCompanion(
            bookId: Value(bookId),
            accentColor: Value(accentColor),
            extractedAt: Value(DateTime.now()),
          ),
        );
      }

      return bookId;
    });
  }

  Future<int> deleteBook(int id) async {
    // First delete related BookColors to prevent orphaned records
    await deleteBookColor(id);

    // Then delete the book
    return (delete(books)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<bool> bookExists(String googleBooksId) async {
    final result =
        await (select(books)
              ..where((tbl) => tbl.googleBooksId.equals(googleBooksId)))
            .getSingleOrNull();
    return result != null;
  }

  Future<void> updateProgress(int bookId, int currentPage) async {
    // Get book for validation
    final book = await (select(
      books,
    )..where((tbl) => tbl.id.equals(bookId))).getSingleOrNull();

    // Validate using domain service
    BookValidationService.validateBookExists(book);
    BookValidationService.validateCurrentPage(currentPage, book!.pageCount);

    // Determine if book should be marked as completed or not
    final shouldBeCompleted =
        book.pageCount != null && currentPage >= book.pageCount!;

    // If this is the first time updating progress (no startDate), set it
    final shouldSetStartDate = book.startDate == null;

    await (update(books)..where((tbl) => tbl.id.equals(bookId))).write(
      BooksCompanion(
        currentPage: Value(currentPage),
        startDate: shouldSetStartDate
            ? Value(DateTime.now())
            : const Value.absent(),
        // Update completion status based on current page
        isCompleted: Value(shouldBeCompleted),
        endDate: shouldBeCompleted
            ? Value(DateTime.now())
            : const Value.absent(),
      ),
    );
  }

  // Transactional method to update progress and reading time atomically
  Future<void> updateProgressWithTime(
    int bookId,
    int currentPage,
    int minutesRead,
  ) async {
    return await transaction(() async {
      // Get book for validation
      final book = await (select(
        books,
      )..where((tbl) => tbl.id.equals(bookId))).getSingleOrNull();

      // Validate using domain service
      BookValidationService.validateBookExists(book);
      BookValidationService.validateCurrentPage(currentPage, book!.pageCount);
      BookValidationService.validateReadingTime(minutesRead);

      // Calculate new total reading time
      final newTotalTime = BookValidationService.validateTotalReadingTime(
        book.totalReadingTimeMinutes,
        minutesRead,
      );

      // Determine if book should be marked as completed or not
      final shouldBeCompleted =
          book.pageCount != null && currentPage >= book.pageCount!;

      // Update both progress and reading time atomically
      // If this is the first time updating progress (no startDate), set it
      final shouldSetStartDate = book.startDate == null;
      await (update(books)..where((tbl) => tbl.id.equals(bookId))).write(
        BooksCompanion(
          currentPage: Value(currentPage),
          totalReadingTimeMinutes: Value(newTotalTime),
          startDate: shouldSetStartDate
              ? Value(DateTime.now())
              : const Value.absent(),
          // Update completion status based on current page
          isCompleted: Value(shouldBeCompleted),
          endDate: shouldBeCompleted
              ? Value(DateTime.now())
              : const Value.absent(),
        ),
      );
    });
  }

  Future<void> completeReading(int bookId) async {
    // Get book to access pageCount
    final book = await (select(
      books,
    )..where((tbl) => tbl.id.equals(bookId))).getSingleOrNull();

    if (book == null) return;

    await (update(books)..where((tbl) => tbl.id.equals(bookId))).write(
      BooksCompanion(
        isCompleted: const Value(true),
        endDate: Value(DateTime.now()),
        // Set currentPage to pageCount to show 100% progress
        currentPage: book.pageCount != null
            ? Value(book.pageCount!)
            : const Value.absent(),
      ),
    );
  }

  Future<void> startReading(int bookId, int currentPage) async {
    // Get book for validation
    final book = await (select(
      books,
    )..where((tbl) => tbl.id.equals(bookId))).getSingleOrNull();

    // Validate using domain service
    BookValidationService.validateBookExists(book);
    BookValidationService.validateCurrentPage(currentPage, book!.pageCount);

    await (update(books)..where((tbl) => tbl.id.equals(bookId))).write(
      BooksCompanion(
        currentPage: Value(currentPage),
        startDate: Value(DateTime.now()),
        isCompleted: const Value(false),
      ),
    );
  }

  // Add reading time to book's total
  Future<void> addReadingTime(int bookId, int minutes) async {
    final book = await (select(
      books,
    )..where((tbl) => tbl.id.equals(bookId))).getSingleOrNull();

    // Validate using domain service
    BookValidationService.validateBookExists(book);
    BookValidationService.validateReadingTime(minutes);

    final newTotalTime = BookValidationService.validateTotalReadingTime(
      book!.totalReadingTimeMinutes,
      minutes,
    );

    await (update(books)..where((tbl) => tbl.id.equals(bookId))).write(
      BooksCompanion(totalReadingTimeMinutes: Value(newTotalTime)),
    );
  }

  // Book colors DAO methods
  Future<BookColor?> getBookColor(int bookId) => (select(
    bookColors,
  )..where((tbl) => tbl.bookId.equals(bookId))).getSingleOrNull();

  Future<int> insertOrUpdateBookColor(BookColorsCompanion color) =>
      into(bookColors).insertOnConflictUpdate(color);

  Future<int> deleteBookColor(int bookId) =>
      (delete(bookColors)..where((tbl) => tbl.bookId.equals(bookId))).go();

  // Daily reading activity DAO methods
  Future<void> recordDailyActivity({
    required int? bookId, // null for global activity
    required DateTime date,
    required int minutesRead,
    required int pagesRead,
  }) async {
    final activityDate = DateTime(date.year, date.month, date.day);

    // Check if activity already exists for this date and book
    final existing =
        await (select(dailyReadingActivity)..where(
              (tbl) =>
                  (bookId == null
                      ? tbl.bookId.isNull()
                      : tbl.bookId.equals(bookId)) &
                  tbl.activityDate.equals(activityDate),
            ))
            .getSingleOrNull();

    if (existing != null) {
      // Update existing activity
      await (update(
        dailyReadingActivity,
      )..where((tbl) => tbl.id.equals(existing.id))).write(
        DailyReadingActivityCompanion(
          minutesRead: Value(existing.minutesRead + minutesRead),
          pagesRead: Value(existing.pagesRead + pagesRead),
          sessionCount: Value(existing.sessionCount + 1),
        ),
      );
    } else {
      // Insert new activity
      await into(dailyReadingActivity).insert(
        DailyReadingActivityCompanion(
          bookId: Value(bookId),
          activityDate: Value(activityDate),
          minutesRead: Value(minutesRead),
          pagesRead: Value(pagesRead),
          sessionCount: const Value(1),
        ),
      );
    }
  }

  Future<List<DailyReadingActivityData>> getDailyActivity({
    int? bookId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Build query with all conditions
    final query = select(dailyReadingActivity)
      ..where((tbl) {
        Expression<bool> condition = const Constant(true);

        if (bookId != null) {
          condition = condition & tbl.bookId.equals(bookId);
        }

        if (fromDate != null) {
          final from = DateTime(fromDate.year, fromDate.month, fromDate.day);
          condition = condition & tbl.activityDate.isBiggerOrEqualValue(from);
        }

        if (toDate != null) {
          final to = DateTime(toDate.year, toDate.month, toDate.day);
          condition = condition & tbl.activityDate.isSmallerOrEqualValue(to);
        }

        return condition;
      })
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.activityDate)]);

    return await query.get();
  }

  Future<int> calculateBookStreak(int bookId, {DateTime? asOf}) async {
    final endDate = asOf ?? DateTime.now();
    final startDate = endDate.subtract(
      const Duration(days: 365),
    ); // Look back 1 year max

    final activities = await getDailyActivity(
      bookId: bookId,
      fromDate: startDate,
      toDate: endDate,
    );

    if (activities.isEmpty) return 0;

    // Sort by date descending
    activities.sort((a, b) => b.activityDate.compareTo(a.activityDate));

    int streak = 0;
    DateTime currentDate = DateTime(endDate.year, endDate.month, endDate.day);

    for (final activity in activities) {
      final activityDate = DateTime(
        activity.activityDate.year,
        activity.activityDate.month,
        activity.activityDate.day,
      );

      final daysDiff = currentDate.difference(activityDate).inDays;

      if (daysDiff == streak) {
        // Consecutive day found
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (daysDiff > streak) {
        // Gap found, streak broken
        break;
      }
    }

    return streak;
  }

  Future<int> calculateGlobalStreak({DateTime? asOf}) async {
    final endDate = asOf ?? DateTime.now();
    final startDate = endDate.subtract(
      const Duration(days: 365),
    ); // Look back 1 year max

    final activities = await getDailyActivity(
      fromDate: startDate,
      toDate: endDate,
    );

    if (activities.isEmpty) return 0;

    // Group by date and check for any reading activity per day
    final dailyActivity = <DateTime, bool>{};
    for (final activity in activities) {
      final date = DateTime(
        activity.activityDate.year,
        activity.activityDate.month,
        activity.activityDate.day,
      );
      dailyActivity[date] = true;
    }

    int streak = 0;
    DateTime currentDate = DateTime(endDate.year, endDate.month, endDate.day);

    for (int i = 0; i < 365; i++) {
      if (dailyActivity.containsKey(currentDate)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    print('🔌 Opening book database connection...');
    final stopwatch = Stopwatch()..start();

    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'book_tracker.db'));
    final database = NativeDatabase(file);

    stopwatch.stop();
    print(
      '🔌 Book database connection opened in ${stopwatch.elapsedMilliseconds}ms',
    );
    return database;
  });
}

// Simple extension to convert to domain entity
extension BookToEntity on Book {
  BookEntity toEntity() {
    return BookEntity(
      id: id,
      googleBooksId: googleBooksId,
      title: title,
      authors: authors,
      description: description,
      thumbnailUrl: thumbnailUrl,
      publishedDate: publishedDate,
      pageCount: pageCount,
      readingProgress: startDate != null
          ? ReadingProgress(
              id: id,
              bookId: id,
              currentPage: currentPage,
              startDate: startDate!,
              endDate: endDate,
              isCompleted: isCompleted,
              totalReadingTimeMinutes: totalReadingTimeMinutes,
            )
          : null,
      // Map rating fields
      averageRating: averageRating,
      ratingsCount: ratingsCount,
    );
  }
}
