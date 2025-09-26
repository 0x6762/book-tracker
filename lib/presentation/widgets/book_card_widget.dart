import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/book_provider.dart';
import '../constants/app_constants.dart';
import '../../domain/entities/book.dart';

class BookCardWidget extends StatelessWidget {
  final BookEntity book;
  final VoidCallback? onDelete;

  const BookCardWidget({super.key, required this.book, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
                  if (book.publishedDate != null &&
                      book.publishedDate!.isNotEmpty) ...[
                    Text(
                      'Published: ${book.publishedDate}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: AppConstants.bodyFontSize,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallSpacing),
                  ],
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
                  const SizedBox(height: AppConstants.largeSpacing),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: AppConstants.deleteIconSize,
                      ),
                      onPressed:
                          onDelete ??
                          () {
                            context.read<BookProvider>().deleteBook(book.id!);
                          },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
