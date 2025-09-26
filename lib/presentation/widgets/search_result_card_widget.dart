import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../constants/app_constants.dart';
import 'book_cover_widget.dart';
import '../../domain/entities/book.dart';

class SearchResultCardWidget extends StatelessWidget {
  final BookEntity book;
  final VoidCallback? onAdd;

  const SearchResultCardWidget({super.key, required this.book, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.cardMargin,
        vertical: AppConstants.smallSpacing,
      ),
      child: ListTile(
        leading: BookCoverWidget(
          thumbnailUrl: book.thumbnailUrl,
          height: AppConstants.searchBookHeight,
          width: AppConstants.searchBookWidth,
          iconSize: 50,
          showShadow: false,
        ),
        title: Text(book.title),
        subtitle: Text(book.authors),
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed:
              onAdd ??
              () {
                context.read<BookProvider>().addBook(book);
                // Clear search input and results after adding
                // This would need to be handled by the parent widget
              },
        ),
      ),
    );
  }
}
