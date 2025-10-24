import 'package:flutter/material.dart';
import '../../domain/entities/book.dart';
import '../../domain/business/book_display_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/text_styles.dart';
import '../../core/di/service_locator.dart';
import '../../application/services/simple_color_extraction_service.dart';
import 'app_card.dart';

class BookDetailsTabs extends StatefulWidget {
  final BookEntity book;

  const BookDetailsTabs({super.key, required this.book});

  @override
  State<BookDetailsTabs> createState() => _BookDetailsTabsState();
}

class _BookDetailsTabsState extends State<BookDetailsTabs>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Color? _bookAccentColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Extract color after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndExtractColor();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkAndExtractColor() async {
    // Skip extraction for completed books; use green bar already
    if (widget.book.isCompleted) return;
    if (widget.book.thumbnailUrl == null || widget.book.id == null || !mounted)
      return;

    // Check if color is already cached in database
    try {
      final database = ServiceLocator().database;
      final bookColor = await database.getBookColor(widget.book.id!);
      if (bookColor?.accentColor != null) {
        // Color is cached - use it immediately
        final color = Color(bookColor!.accentColor!);
        if (mounted) {
          setState(() {
            _bookAccentColor = color;
          });
        }
        return;
      }
    } catch (e) {
      print('Error checking cached color: $e');
    }

    // Color not cached - extract with a small delay for image loading
    Future.delayed(const Duration(milliseconds: 500), _extractBookColor);
  }

  void _extractBookColor() async {
    if (widget.book.isCompleted) return;
    if (widget.book.thumbnailUrl != null && widget.book.id != null && mounted) {
      final color = await SimpleColorExtractionService.extractColor(
        widget.book.thumbnailUrl!,
        widget.book.id!,
      );

      // Double-check mounted state after async operation
      if (mounted) {
        setState(() {
          _bookAccentColor = color;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.md),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Statistics'),
                  Tab(text: 'Book Details'),
                ],
                labelColor: Theme.of(context).colorScheme.onSurface,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
                indicatorColor: Theme.of(context).colorScheme.primary,
                indicatorWeight: 3,
                dividerColor: Theme.of(
                  context,
                ).colorScheme.outline.withOpacity(0.3),
                splashFactory: NoSplash.splashFactory,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                labelStyle: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTextStyles.titleMedium,
              ),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildStatisticsTab(), _buildBookDetailsTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReadingProgress(),
          const SizedBox(height: AppConstants.lg),
          _buildReadingStats(),
        ],
      ),
    );
  }

  Widget _buildBookDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookInfoBox(),
          const SizedBox(height: AppConstants.md),
          _buildBookInfo(),
        ],
      ),
    );
  }

  Widget _buildReadingProgress() {
    if (!widget.book.hasReadingProgress) {
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

    final progress = widget.book.readingProgress!;
    final progressPercentage = widget.book.progressPercentage;

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
              widthFactor: widget.book.isCompleted
                  ? 1.0
                  : progressPercentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: _getProgressBarColor(),
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
                '${widget.book.isCompleted ? '100' : progressPercentage.toStringAsFixed(1)}% complete',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.book.pageCount != null)
                Text(
                  '${widget.book.isCompleted ? widget.book.pageCount : progress.currentPage}/${widget.book.pageCount} pages',
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
        ],
      ),
    );
  }

  Widget _buildReadingStats() {
    if (!widget.book.hasReadingProgress) return const SizedBox.shrink();

    final progress = widget.book.readingProgress!;

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
        // Stats grid with custom layout
        Column(
          children: [
            // First row: Streak stats (3 boxes)
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Last Read',
                      progress.getLastReadFormatted(),
                      Icons.history,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Current Streak',
                      '${widget.book.readingStreak} days',
                      Icons.local_fire_department,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Longest Streak',
                      '${widget.book.readingStreak} days', // TODO: Add longest streak calculation
                      Icons.emoji_events,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Second row: Started date and Total time (2 boxes)
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Started',
                      BookDisplayService.formatShortDate(progress.startDate),
                      Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Time',
                      progress.getFormattedReadingTime(),
                      Icons.timer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Third row: Pages/Hour and Avg Session (2 boxes)
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Pages/Hour',
                      '${progress.getPagesPerHour(widget.book.pageCount!)}',
                      Icons.speed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Avg. Session',
                      progress.getAverageSessionTime(),
                      Icons.schedule,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
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

  Widget _buildBookInfoBox() {
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
              if (widget.book.pageCount != null) ...[
                Expanded(
                  child: _buildInfoItem(
                    Icons.menu_book,
                    'Pages',
                    '${widget.book.pageCount}',
                  ),
                ),
                const SizedBox(width: AppConstants.md),
              ],

              // Published
              if (widget.book.publishedDate != null) ...[
                Expanded(
                  child: _buildInfoItem(
                    Icons.calendar_today,
                    'Published',
                    widget.book.formattedPublishedDate,
                  ),
                ),
                const SizedBox(width: AppConstants.md),
              ],

              // Rating
              Expanded(
                child: _buildInfoItem(
                  Icons.star,
                  'Rating',
                  widget.book.hasRating ? widget.book.formattedRating : 'N/A',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
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

  Widget _buildBookInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.book.hasDescription) ...[
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
                _buildExpandableDescription(),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.md),
        ],
      ],
    );
  }

  Widget _buildExpandableDescription() {
    final needsExpansion = widget.book.needsDescriptionExpansion;
    bool isDescriptionExpanded = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isDescriptionExpanded
                  ? widget.book.description!
                  : widget.book.shortDescription,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: isDescriptionExpanded ? null : 3,
              overflow: isDescriptionExpanded ? null : TextOverflow.ellipsis,
            ),
            if (needsExpansion) ...[
              const SizedBox(height: AppConstants.sm),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isDescriptionExpanded = !isDescriptionExpanded;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isDescriptionExpanded ? 'Show less' : 'Show more',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppConstants.xs),
                    Icon(
                      isDescriptionExpanded
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
      },
    );
  }

  Color _getProgressBarColor() {
    if (widget.book.isCompleted) {
      return Colors.green;
    }
    return _bookAccentColor ?? Theme.of(context).colorScheme.primary;
  }
}
