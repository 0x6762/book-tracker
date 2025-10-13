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
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Centered book cover
                _buildBookCover(context, updatedBook),
                const SizedBox(height: 24),

                // Book title and authors
                _buildBookTitle(context, updatedBook),
                const SizedBox(height: 16),

                // Book info box
                _buildBookInfoBox(context, updatedBook),
                const SizedBox(height: 24),

                // Book info
                _buildBookInfo(context, updatedBook),
                const SizedBox(height: 24),

                // Reading progress section
                _buildReadingProgress(context, updatedBook),
                const SizedBox(height: 24),

                // Reading statistics
                _buildReadingStats(context, updatedBook),
                const SizedBox(height: 32),

                // Delete book button
                _buildDeleteButton(context, updatedBook),
                const SizedBox(height: 16),
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
          const SizedBox(height: 8),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
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
          Text(
            'Description',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildExpandableDescription(context, book),
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
          borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
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
              widthFactor: progressPercentage / 100,
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
                '${progressPercentage.toStringAsFixed(1)}% complete',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (book.pageCount != null)
                Text(
                  '${progress.currentPage}/${book.pageCount} pages',
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
                        book.hasReadingProgress ? 'Update' : 'Start Reading',
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
                        onPressed: () {
                          bookDetailsProvider.completeReading(book.id!);
                          Navigator.of(context).pop();
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

  Widget _buildReadingStats(BuildContext context, BookEntity book) {
    if (!book.hasReadingProgress) return const SizedBox.shrink();

    final progress = book.readingProgress!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reading Statistics',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Stats grid - Row 1
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Days Reading',
                  '${book.daysReading}',
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Reading Streak',
                  '${book.readingStreak} days',
                  Icons.local_fire_department,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Stats grid - Row 2
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Time',
                  progress.getFormattedReadingTime(),
                  Icons.timer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Sessions/Week',
                  _calculateSessionsPerWeek(progress, book),
                  Icons.trending_up,
                ),
              ),
            ],
          ),

          if (progress.totalReadingTimeMinutes > 0 &&
              book.daysReading > 0 &&
              book.pageCount != null &&
              progress.currentPage > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Pages/Hour',
                    _calculatePagesPerHour(progress, book),
                    Icons.speed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Avg. Session',
                    _calculateAverageSessionTime(progress, book),
                    Icons.schedule,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
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

  Widget _buildDeleteButton(BuildContext context, BookEntity book) {
    return Consumer<BookDetailsProvider>(
      builder: (context, bookDetailsProvider, child) {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                _showDeleteConfirmation(context, bookDetailsProvider, book),
            label: const Text(
              'Remove Book',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    BookDetailsProvider bookDetailsProvider,
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
