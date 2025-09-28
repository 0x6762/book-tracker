import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';
import '../../domain/entities/book.dart';

class BookCard extends StatelessWidget {
  final BookEntity book;
  final VoidCallback? onDelete;
  final VoidCallback? onUpdateProgress;
  final VoidCallback? onCompleteReading;

  const BookCard({
    super.key,
    required this.book,
    this.onDelete,
    this.onUpdateProgress,
    this.onCompleteReading,
  });

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
                    const SizedBox(height: AppConstants.smallSpacing),
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
                    // Reading progress section
                    if (book.hasReadingProgress) ...[
                      _buildProgressSection(),
                      const SizedBox(height: AppConstants.smallSpacing),
                    ],
                    // Action buttons
                    _buildActionButtons(),
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

  Widget _buildProgressSection() {
    final progress = book.readingProgress!;
    final progressPercentage = book.progressPercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progressPercentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: book.isCompleted ? Colors.green : Colors.blue,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Progress text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${progressPercentage.toStringAsFixed(1)}% complete',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (book.pageCount != null)
              Text(
                '${progress.currentPage}/${book.pageCount}',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
          ],
        ),
        if (book.daysReading > 0) ...[
          const SizedBox(height: 2),
          Text(
            '${book.daysReading} days reading',
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (book.isCompleted) ...[
          // Completed indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Completed',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Update progress button (for all non-completed books)
          ElevatedButton.icon(
            onPressed: onUpdateProgress,
            icon: const Icon(Icons.edit, size: 16),
            label: Text(book.hasReadingProgress ? 'Update' : 'Start Reading'),
            style: ElevatedButton.styleFrom(
              backgroundColor: book.hasReadingProgress
                  ? Colors.orange
                  : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
          if (book.hasReadingProgress) ...[
            const SizedBox(width: 8),
            // Complete button (only for books with progress)
            ElevatedButton.icon(
              onPressed: onCompleteReading,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
