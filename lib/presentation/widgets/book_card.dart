import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';
import '../../domain/entities/book.dart';

class BookCard extends StatelessWidget {
  final BookEntity book;
  final VoidCallback? onDelete;

  const BookCard({super.key, required this.book, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('book_${book.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.cardMargin,
          vertical: AppConstants.cardVerticalMargin,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        onDelete?.call();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.cardMargin,
          vertical: AppConstants.cardVerticalMargin,
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover
              Container(
                height: AppConstants.bookCoverHeight,
                width: AppConstants.bookCoverWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: book.thumbnailUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: book.thumbnailUrl!,
                          height: AppConstants.bookCoverHeight,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildPlaceholder(),
                          errorWidget: (context, url, error) =>
                              _buildErrorWidget(),
                        ),
                      )
                    : _buildErrorWidget(),
              ),
              const SizedBox(width: AppConstants.largeSpacing),
              // Book details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.titleFontSize,
                        color: Colors.white,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),
                    Text(
                      book.authors,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: AppConstants.subtitleFontSize,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),
                    if (book.pageCount != null) ...[
                      Text(
                        '${book.pageCount} pages',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: AppConstants.bodyFontSize,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallSpacing),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Book'),
              content: Text(
                'Are you sure you want to remove "${book.title}" from your library?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _buildPlaceholder() {
    return Container(
      height: AppConstants.bookCoverHeight,
      width: AppConstants.bookCoverWidth,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: AppConstants.bookCoverHeight,
      width: AppConstants.bookCoverWidth,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Icon(
        Icons.book,
        size: AppConstants.bookIconSize,
        color: Colors.grey,
      ),
    );
  }
}
