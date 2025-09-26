class BookEntity {
  final int? id;
  final String googleBooksId;
  final String title;
  final String authors;
  final String? description;
  final String? thumbnailUrl;
  final String? publishedDate;
  final int? pageCount;

  const BookEntity({
    this.id,
    required this.googleBooksId,
    required this.title,
    required this.authors,
    this.description,
    this.thumbnailUrl,
    this.publishedDate,
    this.pageCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookEntity && other.googleBooksId == googleBooksId;
  }

  @override
  int get hashCode => googleBooksId.hashCode;
}
