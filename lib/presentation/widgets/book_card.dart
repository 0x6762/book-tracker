import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';
import '../../domain/entities/book.dart';
import 'reading_timer.dart';
import '../screens/book_details_screen.dart';

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
      child: GestureDetector(
        onTap: () => _navigateToDetails(context),
        child: Card(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.cardMargin,
            vertical: AppConstants.cardVerticalMargin,
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with book cover and details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book cover with Hero animation
                    Hero(
                      tag: 'book_cover_${book.id}',
                      child: Container(
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
                                  placeholder: (context, url) =>
                                      _buildPlaceholder(),
                                  errorWidget: (context, url, error) =>
                                      _buildErrorWidget(),
                                ),
                              )
                            : _buildErrorWidget(),
                      ),
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
                            maxLines: 2,
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
                          const SizedBox(height: AppConstants.largeSpacing),
                          // Reading progress section
                          if (book.hasReadingProgress) ...[
                            _buildProgressSection(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                // Reading timer - full width
                const SizedBox(height: AppConstants.largeSpacing),
                GestureDetector(
                  onTap: () {}, // Prevent tap from bubbling up to card
                  child: ReadingTimer(
                    bookId: book.id!,
                    bookTitle: book.title,
                    book: book,
                  ),
                ),
              ],
            ),
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
      ],
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BookDetailsScreen(book: book),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Simple fade in effect
          var fadeTween = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeInOut));

          return FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}
