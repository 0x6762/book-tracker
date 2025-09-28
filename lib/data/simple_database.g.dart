// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _googleBooksIdMeta = const VerificationMeta(
    'googleBooksId',
  );
  @override
  late final GeneratedColumn<String> googleBooksId = GeneratedColumn<String>(
    'google_books_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorsMeta = const VerificationMeta(
    'authors',
  );
  @override
  late final GeneratedColumn<String> authors = GeneratedColumn<String>(
    'authors',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedDateMeta = const VerificationMeta(
    'publishedDate',
  );
  @override
  late final GeneratedColumn<String> publishedDate = GeneratedColumn<String>(
    'published_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentPageMeta = const VerificationMeta(
    'currentPage',
  );
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
    'current_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _totalReadingTimeMinutesMeta =
      const VerificationMeta('totalReadingTimeMinutes');
  @override
  late final GeneratedColumn<int> totalReadingTimeMinutes =
      GeneratedColumn<int>(
        'total_reading_time_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _averageRatingMeta = const VerificationMeta(
    'averageRating',
  );
  @override
  late final GeneratedColumn<double> averageRating = GeneratedColumn<double>(
    'average_rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingsCountMeta = const VerificationMeta(
    'ratingsCount',
  );
  @override
  late final GeneratedColumn<int> ratingsCount = GeneratedColumn<int>(
    'ratings_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    googleBooksId,
    title,
    authors,
    description,
    thumbnailUrl,
    publishedDate,
    pageCount,
    currentPage,
    startDate,
    endDate,
    isCompleted,
    totalReadingTimeMinutes,
    averageRating,
    ratingsCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('google_books_id')) {
      context.handle(
        _googleBooksIdMeta,
        googleBooksId.isAcceptableOrUnknown(
          data['google_books_id']!,
          _googleBooksIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_googleBooksIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('authors')) {
      context.handle(
        _authorsMeta,
        authors.isAcceptableOrUnknown(data['authors']!, _authorsMeta),
      );
    } else if (isInserting) {
      context.missing(_authorsMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('published_date')) {
      context.handle(
        _publishedDateMeta,
        publishedDate.isAcceptableOrUnknown(
          data['published_date']!,
          _publishedDateMeta,
        ),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('current_page')) {
      context.handle(
        _currentPageMeta,
        currentPage.isAcceptableOrUnknown(
          data['current_page']!,
          _currentPageMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('total_reading_time_minutes')) {
      context.handle(
        _totalReadingTimeMinutesMeta,
        totalReadingTimeMinutes.isAcceptableOrUnknown(
          data['total_reading_time_minutes']!,
          _totalReadingTimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('average_rating')) {
      context.handle(
        _averageRatingMeta,
        averageRating.isAcceptableOrUnknown(
          data['average_rating']!,
          _averageRatingMeta,
        ),
      );
    }
    if (data.containsKey('ratings_count')) {
      context.handle(
        _ratingsCountMeta,
        ratingsCount.isAcceptableOrUnknown(
          data['ratings_count']!,
          _ratingsCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      googleBooksId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}google_books_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      authors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authors'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      publishedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}published_date'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      currentPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_page'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      totalReadingTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_reading_time_minutes'],
      )!,
      averageRating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_rating'],
      ),
      ratingsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ratings_count'],
      ),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String googleBooksId;
  final String title;
  final String authors;
  final String? description;
  final String? thumbnailUrl;
  final String? publishedDate;
  final int? pageCount;
  final int currentPage;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCompleted;
  final int totalReadingTimeMinutes;
  final double? averageRating;
  final int? ratingsCount;
  const Book({
    required this.id,
    required this.googleBooksId,
    required this.title,
    required this.authors,
    this.description,
    this.thumbnailUrl,
    this.publishedDate,
    this.pageCount,
    required this.currentPage,
    this.startDate,
    this.endDate,
    required this.isCompleted,
    required this.totalReadingTimeMinutes,
    this.averageRating,
    this.ratingsCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['google_books_id'] = Variable<String>(googleBooksId);
    map['title'] = Variable<String>(title);
    map['authors'] = Variable<String>(authors);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || publishedDate != null) {
      map['published_date'] = Variable<String>(publishedDate);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    map['current_page'] = Variable<int>(currentPage);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['total_reading_time_minutes'] = Variable<int>(totalReadingTimeMinutes);
    if (!nullToAbsent || averageRating != null) {
      map['average_rating'] = Variable<double>(averageRating);
    }
    if (!nullToAbsent || ratingsCount != null) {
      map['ratings_count'] = Variable<int>(ratingsCount);
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      googleBooksId: Value(googleBooksId),
      title: Value(title),
      authors: Value(authors),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      publishedDate: publishedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedDate),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      currentPage: Value(currentPage),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isCompleted: Value(isCompleted),
      totalReadingTimeMinutes: Value(totalReadingTimeMinutes),
      averageRating: averageRating == null && nullToAbsent
          ? const Value.absent()
          : Value(averageRating),
      ratingsCount: ratingsCount == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingsCount),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      googleBooksId: serializer.fromJson<String>(json['googleBooksId']),
      title: serializer.fromJson<String>(json['title']),
      authors: serializer.fromJson<String>(json['authors']),
      description: serializer.fromJson<String?>(json['description']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      publishedDate: serializer.fromJson<String?>(json['publishedDate']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      currentPage: serializer.fromJson<int>(json['currentPage']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      totalReadingTimeMinutes: serializer.fromJson<int>(
        json['totalReadingTimeMinutes'],
      ),
      averageRating: serializer.fromJson<double?>(json['averageRating']),
      ratingsCount: serializer.fromJson<int?>(json['ratingsCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'googleBooksId': serializer.toJson<String>(googleBooksId),
      'title': serializer.toJson<String>(title),
      'authors': serializer.toJson<String>(authors),
      'description': serializer.toJson<String?>(description),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'publishedDate': serializer.toJson<String?>(publishedDate),
      'pageCount': serializer.toJson<int?>(pageCount),
      'currentPage': serializer.toJson<int>(currentPage),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'totalReadingTimeMinutes': serializer.toJson<int>(
        totalReadingTimeMinutes,
      ),
      'averageRating': serializer.toJson<double?>(averageRating),
      'ratingsCount': serializer.toJson<int?>(ratingsCount),
    };
  }

  Book copyWith({
    int? id,
    String? googleBooksId,
    String? title,
    String? authors,
    Value<String?> description = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<String?> publishedDate = const Value.absent(),
    Value<int?> pageCount = const Value.absent(),
    int? currentPage,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    bool? isCompleted,
    int? totalReadingTimeMinutes,
    Value<double?> averageRating = const Value.absent(),
    Value<int?> ratingsCount = const Value.absent(),
  }) => Book(
    id: id ?? this.id,
    googleBooksId: googleBooksId ?? this.googleBooksId,
    title: title ?? this.title,
    authors: authors ?? this.authors,
    description: description.present ? description.value : this.description,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    publishedDate: publishedDate.present
        ? publishedDate.value
        : this.publishedDate,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    currentPage: currentPage ?? this.currentPage,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    isCompleted: isCompleted ?? this.isCompleted,
    totalReadingTimeMinutes:
        totalReadingTimeMinutes ?? this.totalReadingTimeMinutes,
    averageRating: averageRating.present
        ? averageRating.value
        : this.averageRating,
    ratingsCount: ratingsCount.present ? ratingsCount.value : this.ratingsCount,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      googleBooksId: data.googleBooksId.present
          ? data.googleBooksId.value
          : this.googleBooksId,
      title: data.title.present ? data.title.value : this.title,
      authors: data.authors.present ? data.authors.value : this.authors,
      description: data.description.present
          ? data.description.value
          : this.description,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      publishedDate: data.publishedDate.present
          ? data.publishedDate.value
          : this.publishedDate,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      currentPage: data.currentPage.present
          ? data.currentPage.value
          : this.currentPage,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      totalReadingTimeMinutes: data.totalReadingTimeMinutes.present
          ? data.totalReadingTimeMinutes.value
          : this.totalReadingTimeMinutes,
      averageRating: data.averageRating.present
          ? data.averageRating.value
          : this.averageRating,
      ratingsCount: data.ratingsCount.present
          ? data.ratingsCount.value
          : this.ratingsCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('googleBooksId: $googleBooksId, ')
          ..write('title: $title, ')
          ..write('authors: $authors, ')
          ..write('description: $description, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('publishedDate: $publishedDate, ')
          ..write('pageCount: $pageCount, ')
          ..write('currentPage: $currentPage, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('totalReadingTimeMinutes: $totalReadingTimeMinutes, ')
          ..write('averageRating: $averageRating, ')
          ..write('ratingsCount: $ratingsCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    googleBooksId,
    title,
    authors,
    description,
    thumbnailUrl,
    publishedDate,
    pageCount,
    currentPage,
    startDate,
    endDate,
    isCompleted,
    totalReadingTimeMinutes,
    averageRating,
    ratingsCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.googleBooksId == this.googleBooksId &&
          other.title == this.title &&
          other.authors == this.authors &&
          other.description == this.description &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.publishedDate == this.publishedDate &&
          other.pageCount == this.pageCount &&
          other.currentPage == this.currentPage &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isCompleted == this.isCompleted &&
          other.totalReadingTimeMinutes == this.totalReadingTimeMinutes &&
          other.averageRating == this.averageRating &&
          other.ratingsCount == this.ratingsCount);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> googleBooksId;
  final Value<String> title;
  final Value<String> authors;
  final Value<String?> description;
  final Value<String?> thumbnailUrl;
  final Value<String?> publishedDate;
  final Value<int?> pageCount;
  final Value<int> currentPage;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<bool> isCompleted;
  final Value<int> totalReadingTimeMinutes;
  final Value<double?> averageRating;
  final Value<int?> ratingsCount;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.googleBooksId = const Value.absent(),
    this.title = const Value.absent(),
    this.authors = const Value.absent(),
    this.description = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.publishedDate = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.totalReadingTimeMinutes = const Value.absent(),
    this.averageRating = const Value.absent(),
    this.ratingsCount = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String googleBooksId,
    required String title,
    required String authors,
    this.description = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.publishedDate = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.totalReadingTimeMinutes = const Value.absent(),
    this.averageRating = const Value.absent(),
    this.ratingsCount = const Value.absent(),
  }) : googleBooksId = Value(googleBooksId),
       title = Value(title),
       authors = Value(authors);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? googleBooksId,
    Expression<String>? title,
    Expression<String>? authors,
    Expression<String>? description,
    Expression<String>? thumbnailUrl,
    Expression<String>? publishedDate,
    Expression<int>? pageCount,
    Expression<int>? currentPage,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? isCompleted,
    Expression<int>? totalReadingTimeMinutes,
    Expression<double>? averageRating,
    Expression<int>? ratingsCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (googleBooksId != null) 'google_books_id': googleBooksId,
      if (title != null) 'title': title,
      if (authors != null) 'authors': authors,
      if (description != null) 'description': description,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (publishedDate != null) 'published_date': publishedDate,
      if (pageCount != null) 'page_count': pageCount,
      if (currentPage != null) 'current_page': currentPage,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (totalReadingTimeMinutes != null)
        'total_reading_time_minutes': totalReadingTimeMinutes,
      if (averageRating != null) 'average_rating': averageRating,
      if (ratingsCount != null) 'ratings_count': ratingsCount,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? googleBooksId,
    Value<String>? title,
    Value<String>? authors,
    Value<String?>? description,
    Value<String?>? thumbnailUrl,
    Value<String?>? publishedDate,
    Value<int?>? pageCount,
    Value<int>? currentPage,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<bool>? isCompleted,
    Value<int>? totalReadingTimeMinutes,
    Value<double?>? averageRating,
    Value<int?>? ratingsCount,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      googleBooksId: googleBooksId ?? this.googleBooksId,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      publishedDate: publishedDate ?? this.publishedDate,
      pageCount: pageCount ?? this.pageCount,
      currentPage: currentPage ?? this.currentPage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      totalReadingTimeMinutes:
          totalReadingTimeMinutes ?? this.totalReadingTimeMinutes,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (googleBooksId.present) {
      map['google_books_id'] = Variable<String>(googleBooksId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (authors.present) {
      map['authors'] = Variable<String>(authors.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (publishedDate.present) {
      map['published_date'] = Variable<String>(publishedDate.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (totalReadingTimeMinutes.present) {
      map['total_reading_time_minutes'] = Variable<int>(
        totalReadingTimeMinutes.value,
      );
    }
    if (averageRating.present) {
      map['average_rating'] = Variable<double>(averageRating.value);
    }
    if (ratingsCount.present) {
      map['ratings_count'] = Variable<int>(ratingsCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('googleBooksId: $googleBooksId, ')
          ..write('title: $title, ')
          ..write('authors: $authors, ')
          ..write('description: $description, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('publishedDate: $publishedDate, ')
          ..write('pageCount: $pageCount, ')
          ..write('currentPage: $currentPage, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('totalReadingTimeMinutes: $totalReadingTimeMinutes, ')
          ..write('averageRating: $averageRating, ')
          ..write('ratingsCount: $ratingsCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$SimpleDatabase extends GeneratedDatabase {
  _$SimpleDatabase(QueryExecutor e) : super(e);
  $SimpleDatabaseManager get managers => $SimpleDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [books];
}

typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      required String googleBooksId,
      required String title,
      required String authors,
      Value<String?> description,
      Value<String?> thumbnailUrl,
      Value<String?> publishedDate,
      Value<int?> pageCount,
      Value<int> currentPage,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<bool> isCompleted,
      Value<int> totalReadingTimeMinutes,
      Value<double?> averageRating,
      Value<int?> ratingsCount,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      Value<String> googleBooksId,
      Value<String> title,
      Value<String> authors,
      Value<String?> description,
      Value<String?> thumbnailUrl,
      Value<String?> publishedDate,
      Value<int?> pageCount,
      Value<int> currentPage,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<bool> isCompleted,
      Value<int> totalReadingTimeMinutes,
      Value<double?> averageRating,
      Value<int?> ratingsCount,
    });

class $$BooksTableFilterComposer
    extends Composer<_$SimpleDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get googleBooksId => $composableBuilder(
    column: $table.googleBooksId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publishedDate => $composableBuilder(
    column: $table.publishedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalReadingTimeMinutes => $composableBuilder(
    column: $table.totalReadingTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageRating => $composableBuilder(
    column: $table.averageRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ratingsCount => $composableBuilder(
    column: $table.ratingsCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BooksTableOrderingComposer
    extends Composer<_$SimpleDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get googleBooksId => $composableBuilder(
    column: $table.googleBooksId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publishedDate => $composableBuilder(
    column: $table.publishedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalReadingTimeMinutes => $composableBuilder(
    column: $table.totalReadingTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageRating => $composableBuilder(
    column: $table.averageRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ratingsCount => $composableBuilder(
    column: $table.ratingsCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$SimpleDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get googleBooksId => $composableBuilder(
    column: $table.googleBooksId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get authors =>
      $composableBuilder(column: $table.authors, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publishedDate => $composableBuilder(
    column: $table.publishedDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalReadingTimeMinutes => $composableBuilder(
    column: $table.totalReadingTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageRating => $composableBuilder(
    column: $table.averageRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ratingsCount => $composableBuilder(
    column: $table.ratingsCount,
    builder: (column) => column,
  );
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$SimpleDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, BaseReferences<_$SimpleDatabase, $BooksTable, Book>),
          Book,
          PrefetchHooks Function()
        > {
  $$BooksTableTableManager(_$SimpleDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> googleBooksId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> authors = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> publishedDate = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> totalReadingTimeMinutes = const Value.absent(),
                Value<double?> averageRating = const Value.absent(),
                Value<int?> ratingsCount = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                googleBooksId: googleBooksId,
                title: title,
                authors: authors,
                description: description,
                thumbnailUrl: thumbnailUrl,
                publishedDate: publishedDate,
                pageCount: pageCount,
                currentPage: currentPage,
                startDate: startDate,
                endDate: endDate,
                isCompleted: isCompleted,
                totalReadingTimeMinutes: totalReadingTimeMinutes,
                averageRating: averageRating,
                ratingsCount: ratingsCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String googleBooksId,
                required String title,
                required String authors,
                Value<String?> description = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> publishedDate = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> totalReadingTimeMinutes = const Value.absent(),
                Value<double?> averageRating = const Value.absent(),
                Value<int?> ratingsCount = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                googleBooksId: googleBooksId,
                title: title,
                authors: authors,
                description: description,
                thumbnailUrl: thumbnailUrl,
                publishedDate: publishedDate,
                pageCount: pageCount,
                currentPage: currentPage,
                startDate: startDate,
                endDate: endDate,
                isCompleted: isCompleted,
                totalReadingTimeMinutes: totalReadingTimeMinutes,
                averageRating: averageRating,
                ratingsCount: ratingsCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$SimpleDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, BaseReferences<_$SimpleDatabase, $BooksTable, Book>),
      Book,
      PrefetchHooks Function()
    >;

class $SimpleDatabaseManager {
  final _$SimpleDatabase _db;
  $SimpleDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
}
