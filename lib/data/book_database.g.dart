// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_database.dart';

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
  static const VerificationMeta _sessionsCountMeta = const VerificationMeta(
    'sessionsCount',
  );
  @override
  late final GeneratedColumn<int> sessionsCount = GeneratedColumn<int>(
    'sessions_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentStreakMeta = const VerificationMeta(
    'currentStreak',
  );
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
    'current_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestStreakMeta = const VerificationMeta(
    'longestStreak',
  );
  @override
  late final GeneratedColumn<int> longestStreak = GeneratedColumn<int>(
    'longest_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestStreakDateMeta = const VerificationMeta(
    'longestStreakDate',
  );
  @override
  late final GeneratedColumn<DateTime> longestStreakDate =
      GeneratedColumn<DateTime>(
        'longest_streak_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
    sessionsCount,
    currentStreak,
    longestStreak,
    longestStreakDate,
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
    if (data.containsKey('sessions_count')) {
      context.handle(
        _sessionsCountMeta,
        sessionsCount.isAcceptableOrUnknown(
          data['sessions_count']!,
          _sessionsCountMeta,
        ),
      );
    }
    if (data.containsKey('current_streak')) {
      context.handle(
        _currentStreakMeta,
        currentStreak.isAcceptableOrUnknown(
          data['current_streak']!,
          _currentStreakMeta,
        ),
      );
    }
    if (data.containsKey('longest_streak')) {
      context.handle(
        _longestStreakMeta,
        longestStreak.isAcceptableOrUnknown(
          data['longest_streak']!,
          _longestStreakMeta,
        ),
      );
    }
    if (data.containsKey('longest_streak_date')) {
      context.handle(
        _longestStreakDateMeta,
        longestStreakDate.isAcceptableOrUnknown(
          data['longest_streak_date']!,
          _longestStreakDateMeta,
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
      sessionsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sessions_count'],
      )!,
      currentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak'],
      )!,
      longestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_streak'],
      )!,
      longestStreakDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}longest_streak_date'],
      ),
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
  final int sessionsCount;
  final int currentStreak;
  final int longestStreak;
  final DateTime? longestStreakDate;
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
    required this.sessionsCount,
    required this.currentStreak,
    required this.longestStreak,
    this.longestStreakDate,
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
    map['sessions_count'] = Variable<int>(sessionsCount);
    map['current_streak'] = Variable<int>(currentStreak);
    map['longest_streak'] = Variable<int>(longestStreak);
    if (!nullToAbsent || longestStreakDate != null) {
      map['longest_streak_date'] = Variable<DateTime>(longestStreakDate);
    }
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
      sessionsCount: Value(sessionsCount),
      currentStreak: Value(currentStreak),
      longestStreak: Value(longestStreak),
      longestStreakDate: longestStreakDate == null && nullToAbsent
          ? const Value.absent()
          : Value(longestStreakDate),
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
      sessionsCount: serializer.fromJson<int>(json['sessionsCount']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      longestStreak: serializer.fromJson<int>(json['longestStreak']),
      longestStreakDate: serializer.fromJson<DateTime?>(
        json['longestStreakDate'],
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
      'sessionsCount': serializer.toJson<int>(sessionsCount),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'longestStreak': serializer.toJson<int>(longestStreak),
      'longestStreakDate': serializer.toJson<DateTime?>(longestStreakDate),
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
    int? sessionsCount,
    int? currentStreak,
    int? longestStreak,
    Value<DateTime?> longestStreakDate = const Value.absent(),
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
    sessionsCount: sessionsCount ?? this.sessionsCount,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    longestStreakDate: longestStreakDate.present
        ? longestStreakDate.value
        : this.longestStreakDate,
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
      sessionsCount: data.sessionsCount.present
          ? data.sessionsCount.value
          : this.sessionsCount,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      longestStreak: data.longestStreak.present
          ? data.longestStreak.value
          : this.longestStreak,
      longestStreakDate: data.longestStreakDate.present
          ? data.longestStreakDate.value
          : this.longestStreakDate,
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
          ..write('sessionsCount: $sessionsCount, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('longestStreakDate: $longestStreakDate, ')
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
    sessionsCount,
    currentStreak,
    longestStreak,
    longestStreakDate,
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
          other.sessionsCount == this.sessionsCount &&
          other.currentStreak == this.currentStreak &&
          other.longestStreak == this.longestStreak &&
          other.longestStreakDate == this.longestStreakDate &&
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
  final Value<int> sessionsCount;
  final Value<int> currentStreak;
  final Value<int> longestStreak;
  final Value<DateTime?> longestStreakDate;
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
    this.sessionsCount = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.longestStreakDate = const Value.absent(),
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
    this.sessionsCount = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.longestStreakDate = const Value.absent(),
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
    Expression<int>? sessionsCount,
    Expression<int>? currentStreak,
    Expression<int>? longestStreak,
    Expression<DateTime>? longestStreakDate,
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
      if (sessionsCount != null) 'sessions_count': sessionsCount,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (longestStreakDate != null) 'longest_streak_date': longestStreakDate,
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
    Value<int>? sessionsCount,
    Value<int>? currentStreak,
    Value<int>? longestStreak,
    Value<DateTime?>? longestStreakDate,
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
      sessionsCount: sessionsCount ?? this.sessionsCount,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      longestStreakDate: longestStreakDate ?? this.longestStreakDate,
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
    if (sessionsCount.present) {
      map['sessions_count'] = Variable<int>(sessionsCount.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (longestStreakDate.present) {
      map['longest_streak_date'] = Variable<DateTime>(longestStreakDate.value);
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
          ..write('sessionsCount: $sessionsCount, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('longestStreakDate: $longestStreakDate, ')
          ..write('averageRating: $averageRating, ')
          ..write('ratingsCount: $ratingsCount')
          ..write(')'))
        .toString();
  }
}

class $BookColorsTable extends BookColors
    with TableInfo<$BookColorsTable, BookColor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookColorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _accentColorMeta = const VerificationMeta(
    'accentColor',
  );
  @override
  late final GeneratedColumn<int> accentColor = GeneratedColumn<int>(
    'accent_color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extractedAtMeta = const VerificationMeta(
    'extractedAt',
  );
  @override
  late final GeneratedColumn<DateTime> extractedAt = GeneratedColumn<DateTime>(
    'extracted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, accentColor, extractedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_colors';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookColor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    }
    if (data.containsKey('accent_color')) {
      context.handle(
        _accentColorMeta,
        accentColor.isAcceptableOrUnknown(
          data['accent_color']!,
          _accentColorMeta,
        ),
      );
    }
    if (data.containsKey('extracted_at')) {
      context.handle(
        _extractedAtMeta,
        extractedAt.isAcceptableOrUnknown(
          data['extracted_at']!,
          _extractedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_extractedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  BookColor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookColor(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      accentColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accent_color'],
      ),
      extractedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}extracted_at'],
      )!,
    );
  }

  @override
  $BookColorsTable createAlias(String alias) {
    return $BookColorsTable(attachedDatabase, alias);
  }
}

class BookColor extends DataClass implements Insertable<BookColor> {
  final int bookId;
  final int? accentColor;
  final DateTime extractedAt;
  const BookColor({
    required this.bookId,
    this.accentColor,
    required this.extractedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<int>(bookId);
    if (!nullToAbsent || accentColor != null) {
      map['accent_color'] = Variable<int>(accentColor);
    }
    map['extracted_at'] = Variable<DateTime>(extractedAt);
    return map;
  }

  BookColorsCompanion toCompanion(bool nullToAbsent) {
    return BookColorsCompanion(
      bookId: Value(bookId),
      accentColor: accentColor == null && nullToAbsent
          ? const Value.absent()
          : Value(accentColor),
      extractedAt: Value(extractedAt),
    );
  }

  factory BookColor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookColor(
      bookId: serializer.fromJson<int>(json['bookId']),
      accentColor: serializer.fromJson<int?>(json['accentColor']),
      extractedAt: serializer.fromJson<DateTime>(json['extractedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<int>(bookId),
      'accentColor': serializer.toJson<int?>(accentColor),
      'extractedAt': serializer.toJson<DateTime>(extractedAt),
    };
  }

  BookColor copyWith({
    int? bookId,
    Value<int?> accentColor = const Value.absent(),
    DateTime? extractedAt,
  }) => BookColor(
    bookId: bookId ?? this.bookId,
    accentColor: accentColor.present ? accentColor.value : this.accentColor,
    extractedAt: extractedAt ?? this.extractedAt,
  );
  BookColor copyWithCompanion(BookColorsCompanion data) {
    return BookColor(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      accentColor: data.accentColor.present
          ? data.accentColor.value
          : this.accentColor,
      extractedAt: data.extractedAt.present
          ? data.extractedAt.value
          : this.extractedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookColor(')
          ..write('bookId: $bookId, ')
          ..write('accentColor: $accentColor, ')
          ..write('extractedAt: $extractedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, accentColor, extractedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookColor &&
          other.bookId == this.bookId &&
          other.accentColor == this.accentColor &&
          other.extractedAt == this.extractedAt);
}

class BookColorsCompanion extends UpdateCompanion<BookColor> {
  final Value<int> bookId;
  final Value<int?> accentColor;
  final Value<DateTime> extractedAt;
  const BookColorsCompanion({
    this.bookId = const Value.absent(),
    this.accentColor = const Value.absent(),
    this.extractedAt = const Value.absent(),
  });
  BookColorsCompanion.insert({
    this.bookId = const Value.absent(),
    this.accentColor = const Value.absent(),
    required DateTime extractedAt,
  }) : extractedAt = Value(extractedAt);
  static Insertable<BookColor> custom({
    Expression<int>? bookId,
    Expression<int>? accentColor,
    Expression<DateTime>? extractedAt,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (accentColor != null) 'accent_color': accentColor,
      if (extractedAt != null) 'extracted_at': extractedAt,
    });
  }

  BookColorsCompanion copyWith({
    Value<int>? bookId,
    Value<int?>? accentColor,
    Value<DateTime>? extractedAt,
  }) {
    return BookColorsCompanion(
      bookId: bookId ?? this.bookId,
      accentColor: accentColor ?? this.accentColor,
      extractedAt: extractedAt ?? this.extractedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (accentColor.present) {
      map['accent_color'] = Variable<int>(accentColor.value);
    }
    if (extractedAt.present) {
      map['extracted_at'] = Variable<DateTime>(extractedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookColorsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('accentColor: $accentColor, ')
          ..write('extractedAt: $extractedAt')
          ..write(')'))
        .toString();
  }
}

class $DailyReadingActivityTable extends DailyReadingActivity
    with TableInfo<$DailyReadingActivityTable, DailyReadingActivityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyReadingActivityTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _activityDateMeta = const VerificationMeta(
    'activityDate',
  );
  @override
  late final GeneratedColumn<DateTime> activityDate = GeneratedColumn<DateTime>(
    'activity_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutesReadMeta = const VerificationMeta(
    'minutesRead',
  );
  @override
  late final GeneratedColumn<int> minutesRead = GeneratedColumn<int>(
    'minutes_read',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pagesReadMeta = const VerificationMeta(
    'pagesRead',
  );
  @override
  late final GeneratedColumn<int> pagesRead = GeneratedColumn<int>(
    'pages_read',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sessionCountMeta = const VerificationMeta(
    'sessionCount',
  );
  @override
  late final GeneratedColumn<int> sessionCount = GeneratedColumn<int>(
    'session_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    activityDate,
    minutesRead,
    pagesRead,
    sessionCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_reading_activity';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyReadingActivityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    }
    if (data.containsKey('activity_date')) {
      context.handle(
        _activityDateMeta,
        activityDate.isAcceptableOrUnknown(
          data['activity_date']!,
          _activityDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityDateMeta);
    }
    if (data.containsKey('minutes_read')) {
      context.handle(
        _minutesReadMeta,
        minutesRead.isAcceptableOrUnknown(
          data['minutes_read']!,
          _minutesReadMeta,
        ),
      );
    }
    if (data.containsKey('pages_read')) {
      context.handle(
        _pagesReadMeta,
        pagesRead.isAcceptableOrUnknown(data['pages_read']!, _pagesReadMeta),
      );
    }
    if (data.containsKey('session_count')) {
      context.handle(
        _sessionCountMeta,
        sessionCount.isAcceptableOrUnknown(
          data['session_count']!,
          _sessionCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyReadingActivityData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyReadingActivityData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      ),
      activityDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}activity_date'],
      )!,
      minutesRead: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes_read'],
      )!,
      pagesRead: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages_read'],
      )!,
      sessionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_count'],
      )!,
    );
  }

  @override
  $DailyReadingActivityTable createAlias(String alias) {
    return $DailyReadingActivityTable(attachedDatabase, alias);
  }
}

class DailyReadingActivityData extends DataClass
    implements Insertable<DailyReadingActivityData> {
  final int id;
  final int? bookId;
  final DateTime activityDate;
  final int minutesRead;
  final int pagesRead;
  final int sessionCount;
  const DailyReadingActivityData({
    required this.id,
    this.bookId,
    required this.activityDate,
    required this.minutesRead,
    required this.pagesRead,
    required this.sessionCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || bookId != null) {
      map['book_id'] = Variable<int>(bookId);
    }
    map['activity_date'] = Variable<DateTime>(activityDate);
    map['minutes_read'] = Variable<int>(minutesRead);
    map['pages_read'] = Variable<int>(pagesRead);
    map['session_count'] = Variable<int>(sessionCount);
    return map;
  }

  DailyReadingActivityCompanion toCompanion(bool nullToAbsent) {
    return DailyReadingActivityCompanion(
      id: Value(id),
      bookId: bookId == null && nullToAbsent
          ? const Value.absent()
          : Value(bookId),
      activityDate: Value(activityDate),
      minutesRead: Value(minutesRead),
      pagesRead: Value(pagesRead),
      sessionCount: Value(sessionCount),
    );
  }

  factory DailyReadingActivityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyReadingActivityData(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int?>(json['bookId']),
      activityDate: serializer.fromJson<DateTime>(json['activityDate']),
      minutesRead: serializer.fromJson<int>(json['minutesRead']),
      pagesRead: serializer.fromJson<int>(json['pagesRead']),
      sessionCount: serializer.fromJson<int>(json['sessionCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int?>(bookId),
      'activityDate': serializer.toJson<DateTime>(activityDate),
      'minutesRead': serializer.toJson<int>(minutesRead),
      'pagesRead': serializer.toJson<int>(pagesRead),
      'sessionCount': serializer.toJson<int>(sessionCount),
    };
  }

  DailyReadingActivityData copyWith({
    int? id,
    Value<int?> bookId = const Value.absent(),
    DateTime? activityDate,
    int? minutesRead,
    int? pagesRead,
    int? sessionCount,
  }) => DailyReadingActivityData(
    id: id ?? this.id,
    bookId: bookId.present ? bookId.value : this.bookId,
    activityDate: activityDate ?? this.activityDate,
    minutesRead: minutesRead ?? this.minutesRead,
    pagesRead: pagesRead ?? this.pagesRead,
    sessionCount: sessionCount ?? this.sessionCount,
  );
  DailyReadingActivityData copyWithCompanion(
    DailyReadingActivityCompanion data,
  ) {
    return DailyReadingActivityData(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      activityDate: data.activityDate.present
          ? data.activityDate.value
          : this.activityDate,
      minutesRead: data.minutesRead.present
          ? data.minutesRead.value
          : this.minutesRead,
      pagesRead: data.pagesRead.present ? data.pagesRead.value : this.pagesRead,
      sessionCount: data.sessionCount.present
          ? data.sessionCount.value
          : this.sessionCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyReadingActivityData(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('activityDate: $activityDate, ')
          ..write('minutesRead: $minutesRead, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('sessionCount: $sessionCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    activityDate,
    minutesRead,
    pagesRead,
    sessionCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyReadingActivityData &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.activityDate == this.activityDate &&
          other.minutesRead == this.minutesRead &&
          other.pagesRead == this.pagesRead &&
          other.sessionCount == this.sessionCount);
}

class DailyReadingActivityCompanion
    extends UpdateCompanion<DailyReadingActivityData> {
  final Value<int> id;
  final Value<int?> bookId;
  final Value<DateTime> activityDate;
  final Value<int> minutesRead;
  final Value<int> pagesRead;
  final Value<int> sessionCount;
  const DailyReadingActivityCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.activityDate = const Value.absent(),
    this.minutesRead = const Value.absent(),
    this.pagesRead = const Value.absent(),
    this.sessionCount = const Value.absent(),
  });
  DailyReadingActivityCompanion.insert({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    required DateTime activityDate,
    this.minutesRead = const Value.absent(),
    this.pagesRead = const Value.absent(),
    this.sessionCount = const Value.absent(),
  }) : activityDate = Value(activityDate);
  static Insertable<DailyReadingActivityData> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<DateTime>? activityDate,
    Expression<int>? minutesRead,
    Expression<int>? pagesRead,
    Expression<int>? sessionCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (activityDate != null) 'activity_date': activityDate,
      if (minutesRead != null) 'minutes_read': minutesRead,
      if (pagesRead != null) 'pages_read': pagesRead,
      if (sessionCount != null) 'session_count': sessionCount,
    });
  }

  DailyReadingActivityCompanion copyWith({
    Value<int>? id,
    Value<int?>? bookId,
    Value<DateTime>? activityDate,
    Value<int>? minutesRead,
    Value<int>? pagesRead,
    Value<int>? sessionCount,
  }) {
    return DailyReadingActivityCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      activityDate: activityDate ?? this.activityDate,
      minutesRead: minutesRead ?? this.minutesRead,
      pagesRead: pagesRead ?? this.pagesRead,
      sessionCount: sessionCount ?? this.sessionCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (activityDate.present) {
      map['activity_date'] = Variable<DateTime>(activityDate.value);
    }
    if (minutesRead.present) {
      map['minutes_read'] = Variable<int>(minutesRead.value);
    }
    if (pagesRead.present) {
      map['pages_read'] = Variable<int>(pagesRead.value);
    }
    if (sessionCount.present) {
      map['session_count'] = Variable<int>(sessionCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyReadingActivityCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('activityDate: $activityDate, ')
          ..write('minutesRead: $minutesRead, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('sessionCount: $sessionCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$BookDatabase extends GeneratedDatabase {
  _$BookDatabase(QueryExecutor e) : super(e);
  $BookDatabaseManager get managers => $BookDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $BookColorsTable bookColors = $BookColorsTable(this);
  late final $DailyReadingActivityTable dailyReadingActivity =
      $DailyReadingActivityTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    books,
    bookColors,
    dailyReadingActivity,
  ];
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
      Value<int> sessionsCount,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<DateTime?> longestStreakDate,
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
      Value<int> sessionsCount,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<DateTime?> longestStreakDate,
      Value<double?> averageRating,
      Value<int?> ratingsCount,
    });

final class $$BooksTableReferences
    extends BaseReferences<_$BookDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookColorsTable, List<BookColor>>
  _bookColorsRefsTable(_$BookDatabase db) => MultiTypedResultKey.fromTable(
    db.bookColors,
    aliasName: $_aliasNameGenerator(db.books.id, db.bookColors.bookId),
  );

  $$BookColorsTableProcessedTableManager get bookColorsRefs {
    final manager = $$BookColorsTableTableManager(
      $_db,
      $_db.bookColors,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookColorsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $DailyReadingActivityTable,
    List<DailyReadingActivityData>
  >
  _dailyReadingActivityRefsTable(_$BookDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.dailyReadingActivity,
        aliasName: $_aliasNameGenerator(
          db.books.id,
          db.dailyReadingActivity.bookId,
        ),
      );

  $$DailyReadingActivityTableProcessedTableManager
  get dailyReadingActivityRefs {
    final manager = $$DailyReadingActivityTableTableManager(
      $_db,
      $_db.dailyReadingActivity,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dailyReadingActivityRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$BookDatabase, $BooksTable> {
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

  ColumnFilters<int> get sessionsCount => $composableBuilder(
    column: $table.sessionsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get longestStreakDate => $composableBuilder(
    column: $table.longestStreakDate,
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

  Expression<bool> bookColorsRefs(
    Expression<bool> Function($$BookColorsTableFilterComposer f) f,
  ) {
    final $$BookColorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookColors,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookColorsTableFilterComposer(
            $db: $db,
            $table: $db.bookColors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dailyReadingActivityRefs(
    Expression<bool> Function($$DailyReadingActivityTableFilterComposer f) f,
  ) {
    final $$DailyReadingActivityTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyReadingActivity,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyReadingActivityTableFilterComposer(
            $db: $db,
            $table: $db.dailyReadingActivity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$BookDatabase, $BooksTable> {
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

  ColumnOrderings<int> get sessionsCount => $composableBuilder(
    column: $table.sessionsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get longestStreakDate => $composableBuilder(
    column: $table.longestStreakDate,
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
    extends Composer<_$BookDatabase, $BooksTable> {
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

  GeneratedColumn<int> get sessionsCount => $composableBuilder(
    column: $table.sessionsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get longestStreakDate => $composableBuilder(
    column: $table.longestStreakDate,
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

  Expression<T> bookColorsRefs<T extends Object>(
    Expression<T> Function($$BookColorsTableAnnotationComposer a) f,
  ) {
    final $$BookColorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookColors,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookColorsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookColors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dailyReadingActivityRefs<T extends Object>(
    Expression<T> Function($$DailyReadingActivityTableAnnotationComposer a) f,
  ) {
    final $$DailyReadingActivityTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.dailyReadingActivity,
          getReferencedColumn: (t) => t.bookId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DailyReadingActivityTableAnnotationComposer(
                $db: $db,
                $table: $db.dailyReadingActivity,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$BookDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, $$BooksTableReferences),
          Book,
          PrefetchHooks Function({
            bool bookColorsRefs,
            bool dailyReadingActivityRefs,
          })
        > {
  $$BooksTableTableManager(_$BookDatabase db, $BooksTable table)
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
                Value<int> sessionsCount = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<DateTime?> longestStreakDate = const Value.absent(),
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
                sessionsCount: sessionsCount,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                longestStreakDate: longestStreakDate,
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
                Value<int> sessionsCount = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<DateTime?> longestStreakDate = const Value.absent(),
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
                sessionsCount: sessionsCount,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                longestStreakDate: longestStreakDate,
                averageRating: averageRating,
                ratingsCount: ratingsCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BooksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({bookColorsRefs = false, dailyReadingActivityRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (bookColorsRefs) db.bookColors,
                    if (dailyReadingActivityRefs) db.dailyReadingActivity,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (bookColorsRefs)
                        await $_getPrefetchedData<Book, $BooksTable, BookColor>(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._bookColorsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).bookColorsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dailyReadingActivityRefs)
                        await $_getPrefetchedData<
                          Book,
                          $BooksTable,
                          DailyReadingActivityData
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._dailyReadingActivityRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).dailyReadingActivityRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$BookDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, $$BooksTableReferences),
      Book,
      PrefetchHooks Function({
        bool bookColorsRefs,
        bool dailyReadingActivityRefs,
      })
    >;
typedef $$BookColorsTableCreateCompanionBuilder =
    BookColorsCompanion Function({
      Value<int> bookId,
      Value<int?> accentColor,
      required DateTime extractedAt,
    });
typedef $$BookColorsTableUpdateCompanionBuilder =
    BookColorsCompanion Function({
      Value<int> bookId,
      Value<int?> accentColor,
      Value<DateTime> extractedAt,
    });

final class $$BookColorsTableReferences
    extends BaseReferences<_$BookDatabase, $BookColorsTable, BookColor> {
  $$BookColorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$BookDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.bookColors.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookColorsTableFilterComposer
    extends Composer<_$BookDatabase, $BookColorsTable> {
  $$BookColorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get extractedAt => $composableBuilder(
    column: $table.extractedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookColorsTableOrderingComposer
    extends Composer<_$BookDatabase, $BookColorsTable> {
  $$BookColorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get extractedAt => $composableBuilder(
    column: $table.extractedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookColorsTableAnnotationComposer
    extends Composer<_$BookDatabase, $BookColorsTable> {
  $$BookColorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get extractedAt => $composableBuilder(
    column: $table.extractedAt,
    builder: (column) => column,
  );

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookColorsTableTableManager
    extends
        RootTableManager<
          _$BookDatabase,
          $BookColorsTable,
          BookColor,
          $$BookColorsTableFilterComposer,
          $$BookColorsTableOrderingComposer,
          $$BookColorsTableAnnotationComposer,
          $$BookColorsTableCreateCompanionBuilder,
          $$BookColorsTableUpdateCompanionBuilder,
          (BookColor, $$BookColorsTableReferences),
          BookColor,
          PrefetchHooks Function({bool bookId})
        > {
  $$BookColorsTableTableManager(_$BookDatabase db, $BookColorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookColorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookColorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookColorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> bookId = const Value.absent(),
                Value<int?> accentColor = const Value.absent(),
                Value<DateTime> extractedAt = const Value.absent(),
              }) => BookColorsCompanion(
                bookId: bookId,
                accentColor: accentColor,
                extractedAt: extractedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> bookId = const Value.absent(),
                Value<int?> accentColor = const Value.absent(),
                required DateTime extractedAt,
              }) => BookColorsCompanion.insert(
                bookId: bookId,
                accentColor: accentColor,
                extractedAt: extractedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookColorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$BookColorsTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$BookColorsTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookColorsTableProcessedTableManager =
    ProcessedTableManager<
      _$BookDatabase,
      $BookColorsTable,
      BookColor,
      $$BookColorsTableFilterComposer,
      $$BookColorsTableOrderingComposer,
      $$BookColorsTableAnnotationComposer,
      $$BookColorsTableCreateCompanionBuilder,
      $$BookColorsTableUpdateCompanionBuilder,
      (BookColor, $$BookColorsTableReferences),
      BookColor,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$DailyReadingActivityTableCreateCompanionBuilder =
    DailyReadingActivityCompanion Function({
      Value<int> id,
      Value<int?> bookId,
      required DateTime activityDate,
      Value<int> minutesRead,
      Value<int> pagesRead,
      Value<int> sessionCount,
    });
typedef $$DailyReadingActivityTableUpdateCompanionBuilder =
    DailyReadingActivityCompanion Function({
      Value<int> id,
      Value<int?> bookId,
      Value<DateTime> activityDate,
      Value<int> minutesRead,
      Value<int> pagesRead,
      Value<int> sessionCount,
    });

final class $$DailyReadingActivityTableReferences
    extends
        BaseReferences<
          _$BookDatabase,
          $DailyReadingActivityTable,
          DailyReadingActivityData
        > {
  $$DailyReadingActivityTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BooksTable _bookIdTable(_$BookDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.dailyReadingActivity.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager? get bookId {
    final $_column = $_itemColumn<int>('book_id');
    if ($_column == null) return null;
    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DailyReadingActivityTableFilterComposer
    extends Composer<_$BookDatabase, $DailyReadingActivityTable> {
  $$DailyReadingActivityTableFilterComposer({
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

  ColumnFilters<DateTime> get activityDate => $composableBuilder(
    column: $table.activityDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutesRead => $composableBuilder(
    column: $table.minutesRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pagesRead => $composableBuilder(
    column: $table.pagesRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionCount => $composableBuilder(
    column: $table.sessionCount,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyReadingActivityTableOrderingComposer
    extends Composer<_$BookDatabase, $DailyReadingActivityTable> {
  $$DailyReadingActivityTableOrderingComposer({
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

  ColumnOrderings<DateTime> get activityDate => $composableBuilder(
    column: $table.activityDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutesRead => $composableBuilder(
    column: $table.minutesRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pagesRead => $composableBuilder(
    column: $table.pagesRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionCount => $composableBuilder(
    column: $table.sessionCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyReadingActivityTableAnnotationComposer
    extends Composer<_$BookDatabase, $DailyReadingActivityTable> {
  $$DailyReadingActivityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get activityDate => $composableBuilder(
    column: $table.activityDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minutesRead => $composableBuilder(
    column: $table.minutesRead,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pagesRead =>
      $composableBuilder(column: $table.pagesRead, builder: (column) => column);

  GeneratedColumn<int> get sessionCount => $composableBuilder(
    column: $table.sessionCount,
    builder: (column) => column,
  );

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyReadingActivityTableTableManager
    extends
        RootTableManager<
          _$BookDatabase,
          $DailyReadingActivityTable,
          DailyReadingActivityData,
          $$DailyReadingActivityTableFilterComposer,
          $$DailyReadingActivityTableOrderingComposer,
          $$DailyReadingActivityTableAnnotationComposer,
          $$DailyReadingActivityTableCreateCompanionBuilder,
          $$DailyReadingActivityTableUpdateCompanionBuilder,
          (DailyReadingActivityData, $$DailyReadingActivityTableReferences),
          DailyReadingActivityData,
          PrefetchHooks Function({bool bookId})
        > {
  $$DailyReadingActivityTableTableManager(
    _$BookDatabase db,
    $DailyReadingActivityTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyReadingActivityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyReadingActivityTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DailyReadingActivityTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> bookId = const Value.absent(),
                Value<DateTime> activityDate = const Value.absent(),
                Value<int> minutesRead = const Value.absent(),
                Value<int> pagesRead = const Value.absent(),
                Value<int> sessionCount = const Value.absent(),
              }) => DailyReadingActivityCompanion(
                id: id,
                bookId: bookId,
                activityDate: activityDate,
                minutesRead: minutesRead,
                pagesRead: pagesRead,
                sessionCount: sessionCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> bookId = const Value.absent(),
                required DateTime activityDate,
                Value<int> minutesRead = const Value.absent(),
                Value<int> pagesRead = const Value.absent(),
                Value<int> sessionCount = const Value.absent(),
              }) => DailyReadingActivityCompanion.insert(
                id: id,
                bookId: bookId,
                activityDate: activityDate,
                minutesRead: minutesRead,
                pagesRead: pagesRead,
                sessionCount: sessionCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DailyReadingActivityTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable:
                                    $$DailyReadingActivityTableReferences
                                        ._bookIdTable(db),
                                referencedColumn:
                                    $$DailyReadingActivityTableReferences
                                        ._bookIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DailyReadingActivityTableProcessedTableManager =
    ProcessedTableManager<
      _$BookDatabase,
      $DailyReadingActivityTable,
      DailyReadingActivityData,
      $$DailyReadingActivityTableFilterComposer,
      $$DailyReadingActivityTableOrderingComposer,
      $$DailyReadingActivityTableAnnotationComposer,
      $$DailyReadingActivityTableCreateCompanionBuilder,
      $$DailyReadingActivityTableUpdateCompanionBuilder,
      (DailyReadingActivityData, $$DailyReadingActivityTableReferences),
      DailyReadingActivityData,
      PrefetchHooks Function({bool bookId})
    >;

class $BookDatabaseManager {
  final _$BookDatabase _db;
  $BookDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$BookColorsTableTableManager get bookColors =>
      $$BookColorsTableTableManager(_db, _db.bookColors);
  $$DailyReadingActivityTableTableManager get dailyReadingActivity =>
      $$DailyReadingActivityTableTableManager(_db, _db.dailyReadingActivity);
}
