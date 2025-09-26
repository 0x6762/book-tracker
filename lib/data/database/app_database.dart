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

@DriftDatabase(tables: [Books])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Books DAO methods
  Future<List<Book>> getAllBooks() => select(books).get();

  Future<int> insertBook(BooksCompanion book) => into(books).insert(book);

  Future<int> deleteBook(int id) =>
      (delete(books)..where((tbl) => tbl.id.equals(id))).go();
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
