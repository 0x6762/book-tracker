import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../domain/entities/book.dart';

part 'app_database.g.dart';

// Drift table definition
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get googleBooksId => text().unique()();
  TextColumn get title => text()();
  TextColumn get authors => text()();
  TextColumn get description => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get publishedDate => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
}

// Reading progress table
class ReadingProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  IntColumn get currentPage => integer()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Books, ReadingProgress])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Add ReadingProgress table
        await m.createTable(readingProgress);
      }
    },
  );

  // Books DAO methods
  Future<List<Book>> getAllBooks() => select(books).get();

  Future<int> insertBook(BooksCompanion book) => into(books).insert(book);

  Future<int> deleteBook(int id) =>
      (delete(books)..where((tbl) => tbl.id.equals(id))).go();

  // Reading progress DAO methods
  Future<List<ReadingProgressData>> getAllReadingProgress() =>
      select(readingProgress).get();

  Future<ReadingProgressData?> getReadingProgressByBookId(int bookId) =>
      (select(
        readingProgress,
      )..where((tbl) => tbl.bookId.equals(bookId))).getSingleOrNull();

  Future<int> insertReadingProgress(ReadingProgressCompanion progress) =>
      into(readingProgress).insert(progress);

  Future<int> updateReadingProgress(ReadingProgressCompanion progress) =>
      (update(
        readingProgress,
      )..where((tbl) => tbl.id.equals(progress.id.value))).write(progress);

  Future<int> deleteReadingProgress(int id) =>
      (delete(readingProgress)..where((tbl) => tbl.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'book_tracker.db'));
    return NativeDatabase.createInBackground(file);
  });
}

// Extension to convert between Drift data and domain entities
extension DriftBookExtension on Book {
  // Convert from Drift data to domain entity
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
    );
  }
}

// Extension to convert from domain entity to Drift companion
extension DomainBookExtension on BookEntity {
  // Convert from domain entity to Drift companion
  BooksCompanion toCompanion() {
    return BooksCompanion(
      id: id != null ? Value(id!) : const Value.absent(),
      googleBooksId: Value(googleBooksId),
      title: Value(title),
      authors: Value(authors),
      description: Value(description),
      thumbnailUrl: Value(thumbnailUrl),
      publishedDate: Value(publishedDate),
      pageCount: Value(pageCount),
    );
  }
}
