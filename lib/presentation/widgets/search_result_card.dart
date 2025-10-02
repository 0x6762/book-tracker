import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../providers/ui_state_provider.dart';
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
        vertical: AppConstants.mediumSpacing,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Container(
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
            const SizedBox(width: 12),
            // Book details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.authors,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Additional book information
                  Row(
                    children: [
                      if (book.pageCount != null) ...[
                        Icon(
                          Icons.menu_book,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${book.pageCount} pages',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (book.publishedDate != null) ...[
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatPublishedDate(book.publishedDate!),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ],
                  ),
                  if (book.hasRating) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber[600]),
                        const SizedBox(width: 4),
                        Text(
                          book.fullRatingText,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Add button
            SizedBox(
              height: AppConstants.searchBookHeight,
              child: Align(
                alignment: Alignment.center,
                child: Consumer<UIStateProvider>(
                  builder: (context, uiStateProvider, child) {
                    final isAdding = uiStateProvider.isAddingBook;
                    return Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: IconButton(
                        icon: isAdding
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.add),
                        onPressed: isAdding ? null : onAdd,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
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
      child: const Icon(Icons.book, size: 60, color: Colors.grey),
    );
  }

  String _formatPublishedDate(String publishedDate) {
    try {
      // Handle different date formats from Google Books API
      if (publishedDate.length == 4) {
        // Just year (e.g., "2023")
        return publishedDate;
      } else if (publishedDate.length == 7) {
        // Year-Month (e.g., "2023-05")
        final parts = publishedDate.split('-');
        if (parts.length == 2) {
          final year = parts[0];
          final month = parts[1];
          final monthNames = [
            '',
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          final monthIndex = int.tryParse(month);
          if (monthIndex != null && monthIndex >= 1 && monthIndex <= 12) {
            return '${monthNames[monthIndex]} $year';
          }
        }
        return publishedDate;
      } else if (publishedDate.length == 10) {
        // Full date (e.g., "2023-05-15")
        final parts = publishedDate.split('-');
        if (parts.length == 3) {
          final year = parts[0];
          final month = parts[1];
          final day = parts[2];
          final monthNames = [
            '',
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          final monthIndex = int.tryParse(month);
          if (monthIndex != null && monthIndex >= 1 && monthIndex <= 12) {
            return '${monthNames[monthIndex]} $day, $year';
          }
        }
        return publishedDate;
      }
      return publishedDate;
    } catch (e) {
      return publishedDate;
    }
  }
}
