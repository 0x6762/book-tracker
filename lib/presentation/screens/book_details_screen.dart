import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/book.dart';
import '../../domain/business/book_display_service.dart';
import '../widgets/progress_update_bottom_sheet.dart';
import '../widgets/app_card.dart';
import '../providers/book_details_provider.dart';
import '../providers/book_list_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/text_styles.dart';
import 'package:provider/provider.dart';

class BookDetailsScreen extends StatefulWidget {
  final BookEntity book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen>
    with TickerProviderStateMixin {
  bool _isDescriptionExpanded = false;
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Initialize to show elements when screen first loads
    _fadeController.value = 1.0;

    // Initialize tab controller
    _tabController = TabController(length: 2, vsync: this);

    // Listen to scroll changes to update fade animation
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fadeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const double fadeStartOffset = 120.0; // Start fading
    const double fadeEndOffset = 350.0; // Complete fade

    final offset = _scrollController.offset;

    if (offset <= fadeStartOffset) {
      _fadeController.value = 1.0; // Fully visible (reverse logic)
    } else if (offset >= fadeEndOffset) {
      _fadeController.value = 0.0; // Fully faded (reverse logic)
    } else {
      // Smooth interpolation between fade start and end (reversed)
      final progress =
          (offset - fadeStartOffset) / (fadeEndOffset - fadeStartOffset);
      _fadeController.value = 1.0 - progress; // Reverse the progress
    }
  }

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
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animated book cover
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale:
                                  1.0 -
                                  ((1.0 - _fadeAnimation.value) *
                                      0.1), // Slight scale down
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: _buildBookCover(context, updatedBook),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppConstants.lg),
                        // Animated book title and author
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                (1.0 - _fadeAnimation.value) * 1,
                              ), // Slight upward movement
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: _buildBookTitle(context, updatedBook),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppConstants.lg),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppConstants.md,
                    ),
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Statistics'),
                        Tab(text: 'Book Details'),
                      ],
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      indicatorWeight: 3,
                      labelStyle: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: AppTextStyles.titleMedium,
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // Statistics Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReadingProgress(context, updatedBook),
                      const SizedBox(height: AppConstants.lg),
                      _buildReadingStats(context, updatedBook),
                    ],
                  ),
                ),
                // Book Details Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBookInfoBox(context, updatedBook),
                      const SizedBox(height: AppConstants.md),
                      _buildBookInfo(context, updatedBook),
                    ],
                  ),
                ),
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
            style: AppTextStyles.headlineMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppConstants.xs),
          Text(
            book.authors,
            style: AppTextStyles.bookAuthor.copyWith(
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book Information',
            style: AppTextStyles.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.md),
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
                const SizedBox(width: AppConstants.md),
              ],

              // Published
              if (book.publishedDate != null) ...[
                Expanded(
                  child: _buildInfoItem(
                    context,
                    Icons.calendar_today,
                    'Published',
                    book.formattedPublishedDate,
                  ),
                ),
                const SizedBox(width: AppConstants.md),
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
        const SizedBox(height: AppConstants.sm),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.xs),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBookInfo(BuildContext context, BookEntity book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (book.hasDescription) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.sm),
                _buildExpandableDescription(context, book),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.md),
        ],
      ],
    );
  }

  Widget _buildExpandableDescription(BuildContext context, BookEntity book) {
    final needsExpansion = book.needsDescriptionExpansion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isDescriptionExpanded ? book.description! : book.shortDescription,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: _isDescriptionExpanded ? null : 3,
          overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
        ),
        if (needsExpansion) ...[
          const SizedBox(height: AppConstants.sm),
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
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppConstants.xs),
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
      return AppInfoCard(
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppConstants.sm + AppConstants.xs),
            Expanded(
              child: Text(
                'Start reading to track your progress',
                style: AppTextStyles.bodyMedium.copyWith(
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

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reading Progress',
            style: AppTextStyles.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.md),

          // Progress bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(
                AppConstants.progressBarBorderRadius,
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: book.isCompleted ? 1.0 : progressPercentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: book.isCompleted
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(
                    AppConstants.progressBarBorderRadius,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.sm + AppConstants.xs),

          // Progress details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${book.isCompleted ? '100' : progressPercentage.toStringAsFixed(1)}% complete',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (book.pageCount != null)
                Text(
                  '${book.isCompleted ? book.pageCount : progress.currentPage}/${book.pageCount} pages',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.sm + AppConstants.xs),

          // Last time read
          Row(
            children: [
              Icon(
                Icons.history,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppConstants.sm),
              Text(
                'Last read: ${progress.getLastReadFormatted()}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.md),

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
                        BookDisplayService.getProgressButtonText(book),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.sm + AppConstants.xs,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.sm + AppConstants.xs),
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
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.sm + AppConstants.xs,
                          ),
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
              BookDisplayService.formatShortDate(progress.startDate),
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
              '${progress.getSessionsPerWeek()}',
              Icons.trending_up,
            ),
            if (BookDisplayService.shouldShowAdvancedStats(book))
              _buildStatCard(
                context,
                'Pages/Hour',
                '${progress.getPagesPerHour(book.pageCount!)}',
                Icons.speed,
              ),
            if (BookDisplayService.shouldShowAdvancedStats(book))
              _buildStatCard(
                context,
                'Avg. Session',
                progress.getAverageSessionTime(),
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
