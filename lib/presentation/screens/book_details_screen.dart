import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_progress.dart';
import '../widgets/progress_update_bottom_sheet.dart';
import '../providers/book_details_provider.dart';
import '../providers/book_list_provider.dart';
import 'package:provider/provider.dart';

class BookDetailsScreen extends StatefulWidget {
  final BookEntity book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<BookListProvider>(
      builder: (context, bookListProvider, child) {
        // Get the updated book from the provider
        final updatedBook =
            bookListProvider.books
                .where((book) => book.id == widget.book.id)
                .firstOrNull ??
            widget.book;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleMenuAction(context, value, updatedBook),
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                tooltip: 'More options',
                offset: const Offset(-8, 48), // Position below the icon
                // Alternative: Use position to control horizontal alignment
                // position: PopupMenuPosition.under, // or .over
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 8,
                color: Theme.of(context).colorScheme.surface,
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Remove Book',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Centered book cover
                _buildBookCover(context, updatedBook),
                const SizedBox(height: 24),

                // Book title and authors
                _buildBookTitle(context, updatedBook),
                const SizedBox(height: 24),

                // Reading progress section
                _buildReadingProgress(context, updatedBook),
                const SizedBox(height: 16),

                // Reading statistics
                _buildReadingStats(context, updatedBook),
                const SizedBox(height: 16),

                // Book info box
                _buildBookInfoBox(context, updatedBook),
                const SizedBox(height: 16),

                // Book info
                _buildBookInfo(context, updatedBook),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookCover(BuildContext context, BookEntity book) {
    return Center(
      child: Hero(
        tag: 'book_cover_${book.id}',
        child: Material(
          elevation: 8,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: Container(
            height: 280,
            width: 200,
            child: book.thumbnailUrl != null
                ? CachedNetworkImage(
                    imageUrl: book.thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.book,
                        size: 80,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.book,
                      size: 80,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookTitle(BuildContext context, BookEntity book) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            book.title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            book.authors,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBookInfoBox(BuildContext context, BookEntity book) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book Information',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Pages
              if (book.pageCount != null) ...[
                Expanded(
                  child: _buildInfoItem(
                    context,
                    Icons.menu_book,
                    'Pages',
                    '${book.pageCount}',
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // Published
              if (book.publishedDate != null) ...[
                Expanded(
                  child: _buildInfoItem(
                    context,
                    Icons.calendar_today,
                    'Published',
                    _formatPublishedDate(book.publishedDate!),
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // Rating
              Expanded(
                child: _buildInfoItem(
                  context,
                  Icons.star,
                  'Rating',
                  book.hasRating ? book.formattedRating : 'N/A',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatPublishedDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      final now = DateTime.now();
      final difference = now.difference(parsedDate);

      if (difference.inDays < 30) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months month${months == 1 ? '' : 's'} ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years year${years == 1 ? '' : 's'} ago';
      }
    } catch (e) {
      return date; // Return original if parsing fails
    }
  }

  Widget _buildBookInfo(BuildContext context, BookEntity book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (book.description != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildExpandableDescription(context, book),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildExpandableDescription(BuildContext context, BookEntity book) {
    final description = book.description!;
    final needsExpansion = description.length > 200; // Approximate 3 lines

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: _isDescriptionExpanded ? null : 3,
          overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
        ),
        if (needsExpansion) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isDescriptionExpanded ? 'Show less' : 'Show more',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isDescriptionExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReadingProgress(BuildContext context, BookEntity book) {
    if (!book.hasReadingProgress) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Start reading to track your progress',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final progress = book.readingProgress!;
    final progressPercentage = book.progressPercentage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reading Progress',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Progress bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: book.isCompleted ? 1.0 : progressPercentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: book.isCompleted
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Progress details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${book.isCompleted ? '100' : progressPercentage.toStringAsFixed(1)}% complete',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (book.pageCount != null)
                Text(
                  '${book.isCompleted ? book.pageCount : progress.currentPage}/${book.pageCount} pages',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Last time read
          Row(
            children: [
              Icon(
                Icons.history,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Last read: ' +
                    _formatLastRead(progress.endDate, progress.startDate),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Consumer<BookDetailsProvider>(
            builder: (context, bookDetailsProvider, child) {
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showProgressModal(
                        context,
                        bookDetailsProvider,
                        book,
                      ),
                      label: Text(
                        book.hasReadingProgress
                            ? (book.isCompleted ? 'Update Progress' : 'Update')
                            : 'Start Reading',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (book.hasReadingProgress && !book.isCompleted)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await bookDetailsProvider.completeReading(book.id!);
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        label: const Text('Mark Complete'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatLastRead(DateTime? endDate, DateTime startDate) {
    final last = endDate ?? startDate;
    final now = DateTime.now();
    final difference = now.difference(last);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24)
      return '${difference.inHours} hr${difference.inHours == 1 ? '' : 's'} ago';
    if (difference.inDays < 7)
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';

    // Fallback to short date like "Oct 14, 2025"
    const months = [
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
    final m = months[last.month - 1];
    return '$m ${last.day}, ${last.year}';
  }

  String _formatShortDate(DateTime date) {
    const months = [
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
    final m = months[date.month - 1];
    return '$m ${date.day}, ${date.year}';
  }

  Widget _buildReadingStats(BuildContext context, BookEntity book) {
    if (!book.hasReadingProgress) return const SizedBox.shrink();

    final progress = book.readingProgress!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reading Statistics',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Stats grid - 2 columns, each item is its own card
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              context,
              'Started',
              _formatShortDate(progress.startDate),
              Icons.calendar_today,
            ),
            _buildStatCard(
              context,
              'Reading Streak',
              '${book.readingStreak} days',
              Icons.local_fire_department,
            ),
            _buildStatCard(
              context,
              'Total Time',
              progress.getFormattedReadingTime(),
              Icons.timer,
            ),
            _buildStatCard(
              context,
              'Sessions/Week',
              _calculateSessionsPerWeek(progress, book),
              Icons.trending_up,
            ),
            if (progress.totalReadingTimeMinutes > 0 &&
                book.daysReading > 0 &&
                book.pageCount != null &&
                progress.currentPage > 0)
              _buildStatCard(
                context,
                'Pages/Hour',
                _calculatePagesPerHour(progress, book),
                Icons.speed,
              ),
            if (progress.totalReadingTimeMinutes > 0 &&
                book.daysReading > 0 &&
                book.pageCount != null &&
                progress.currentPage > 0)
              _buildStatCard(
                context,
                'Avg. Session',
                _calculateAverageSessionTime(progress, book),
                Icons.schedule,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showProgressModal(
    BuildContext context,
    BookDetailsProvider bookDetailsProvider,
    BookEntity book,
  ) {
    showProgressUpdateBottomSheet(
      context: context,
      book: book,
      onUpdateProgress: (currentPage) {
        bookDetailsProvider.updateProgress(book.id!, currentPage);
      },
      onCompleteReading: () {
        bookDetailsProvider.completeReading(book.id!);
      },
    );
  }

  String _calculateSessionsPerWeek(ReadingProgress progress, BookEntity book) {
    if (book.daysReading <= 0 || progress.totalReadingTimeMinutes <= 0) {
      return '0';
    }

    // Calculate how many reading sessions per week
    // Assume each timer session is ~30 minutes on average
    final avgSessionMinutes = 30;
    final totalSessions = (progress.totalReadingTimeMinutes / avgSessionMinutes)
        .round();

    // Calculate weeks of reading
    final weeksReading = (book.daysReading / 7).clamp(1.0, double.infinity);

    // Sessions per week
    final sessionsPerWeek = (totalSessions / weeksReading).round();

    return '$sessionsPerWeek';
  }

  String _calculateAverageSessionTime(
    ReadingProgress progress,
    BookEntity book,
  ) {
    if (book.daysReading <= 0 || progress.totalReadingTimeMinutes <= 0) {
      return '0m';
    }

    // Calculate average session time based on total reading time and days
    // This gives a more realistic average since users don't read every day
    final avgMinutes = progress.totalReadingTimeMinutes / book.daysReading;
    final hours = avgMinutes ~/ 60;
    final minutes = (avgMinutes % 60).round();

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  String _calculatePagesPerHour(ReadingProgress progress, BookEntity book) {
    if (progress.totalReadingTimeMinutes <= 0 ||
        book.pageCount == null ||
        progress.currentPage <= 0) {
      return '0';
    }

    final hours = progress.totalReadingTimeMinutes / 60;
    if (hours <= 0) return '0';

    // Calculate pages per hour based on current page progress
    // This assumes reading started from page 1 (or 0), which is typical
    final pagesPerHour = (progress.currentPage / hours).round();

    // Cap at reasonable reading speed (e.g., 100 pages/hour max)
    final cappedPagesPerHour = pagesPerHour.clamp(0, 100);
    return '$cappedPagesPerHour';
  }

  void _handleMenuAction(BuildContext context, String action, BookEntity book) {
    switch (action) {
      case 'delete':
        _showDeleteConfirmation(context, book);
        break;
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    BookEntity book,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Book'),
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
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Use BookListProvider to delete the book and update the UI
      final bookListProvider = context.read<BookListProvider>();
      await bookListProvider.deleteBook(book.googleBooksId);
      if (mounted) {
        Navigator.of(context).pop(); // Go back to main screen
      }
    }
  }
}
