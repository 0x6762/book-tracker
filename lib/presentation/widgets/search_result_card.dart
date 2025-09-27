import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../constants/app_constants.dart';
import '../../domain/entities/book.dart';

class SearchResultCard extends StatelessWidget {
  final BookEntity book;
  final VoidCallback? onAdd;

  const SearchResultCard({super.key, required this.book, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.cardMargin,
        vertical: AppConstants.smallSpacing,
      ),
      child: ListTile(
        leading: Container(
          height: AppConstants.searchBookHeight,
          width: AppConstants.searchBookWidth,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: book.thumbnailUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  child: Image.network(
                    book.thumbnailUrl!,
                    height: AppConstants.searchBookHeight,
                    width: AppConstants.searchBookWidth,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildPlaceholder();
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _buildErrorWidget(),
                  ),
                )
              : _buildErrorWidget(),
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

  Widget _buildPlaceholder() {
    return Container(
      height: AppConstants.searchBookHeight,
      width: AppConstants.searchBookWidth,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: AppConstants.searchBookHeight,
      width: AppConstants.searchBookWidth,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: const Icon(Icons.book, size: 50, color: Colors.grey),
    );
  }
}
