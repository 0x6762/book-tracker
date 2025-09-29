import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';
import '../../domain/entities/book.dart';
import 'reading_timer.dart';
import '../screens/book_details_screen.dart';
import '../utils/color_extractor.dart';

class BookCard extends StatefulWidget {
  final BookEntity book;
  final EdgeInsetsGeometry? margin;

  const BookCard({super.key, required this.book, this.margin});

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  Color? _bookAccentColor;

  // Constants
  static const double _cardBorderRadius = 28.0;
  static const double _imageScale = 1.01;
  static const double _gradientHeight = 300.0;
  static const Duration _animationDelay = Duration(milliseconds: 300);
  static const Duration _colorExtractionDelay = Duration(
    milliseconds: 800,
  ); // Increased for better timing
  static const Duration _animationDuration = Duration(milliseconds: 400);
  static const double _progressBarHeight = 8.0;
  static const double _progressBarRadius = 56.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.1), // Start 10% down (more subtle)
          end: Offset.zero, // End at normal position
        ).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    // Start the slide animation after a short delay
    _startAnimation();

    // Extract color after image has time to load and display
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(_colorExtractionDelay, _extractBookColor);
    });
  }

  void _extractBookColor() async {
    // Skip extraction for completed books; use green bar already
    if (widget.book.isCompleted) return;
    if (widget.book.thumbnailUrl != null && widget.book.id != null) {
      final theme = Theme.of(context);
      final color = await ColorExtractor.extractColorForBook(
        widget.book.id!,
        widget.book.thumbnailUrl,
        blendAnchor: theme.colorScheme.primary,
        contrastAgainstSurface: theme.colorScheme.surface,
      );
      if (mounted) {
        setState(() {
          _bookAccentColor = color;
        });
      }
    }
  }

  void _startAnimation() {
    _animationController.reset();
    // Shorter delay to start after Hero animation begins but before it completes
    Future.delayed(_animationDelay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only restart animation if we're coming back from navigation
    if (mounted && _animationController.status == AnimationStatus.dismissed) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Book card without timer
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToDetails(context),
            child: Card(
              margin:
                  widget.margin ??
                  const EdgeInsets.symmetric(
                    horizontal: AppConstants.cardMargin,
                    vertical: AppConstants.cardVerticalMargin,
                  ),
              elevation: 2,
              color: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_cardBorderRadius),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  // Solid background to avoid white seams before/around image
                  Positioned.fill(child: Container(color: colorScheme.surface)),
                  // Full cover background with fixed aspect ratio
                  Positioned.fill(
                    child: Hero(
                      tag: 'book_cover_${widget.book.id}',
                      child: widget.book.thumbnailUrl != null
                          ? Transform.scale(
                              scale: _imageScale,
                              alignment: Alignment.center,
                              child: CachedNetworkImage(
                                imageUrl: widget.book.thumbnailUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                                filterQuality: FilterQuality.high,
                                memCacheWidth: 600,
                                memCacheHeight: 900,
                                placeholder: (context, url) =>
                                    _buildPlaceholder(),
                                errorWidget: (context, url, error) =>
                                    _buildErrorWidget(),
                              ),
                            )
                          : _buildErrorWidget(),
                    ),
                  ),

                  // Gradient overlay at bottom for readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: _gradientHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            colorScheme.surface.withOpacity(0.8),
                            colorScheme.surface,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content overlaid on gradient with slide animation
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Book title and authors
                                Text(
                                  widget.book.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.book.authors,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.book.hasReadingProgress) ...[
                                  const SizedBox(height: 16),
                                  _buildProgressSection(),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Timer box below the card
        GestureDetector(
          onTap: () {}, // Prevent tap from bubbling up to card
          child: ReadingTimer(
            bookId: widget.book.id!,
            bookTitle: widget.book.title,
            book: widget.book,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_cardBorderRadius),
      child: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_cardBorderRadius),
      child: Container(
        decoration: BoxDecoration(color: Colors.grey[300]),
        child: Icon(
          Icons.book,
          size: AppConstants.bookIconSize,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final progress = widget.book.readingProgress!;
    final progressPercentage = widget.book.progressPercentage;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Container(
          width: double.infinity,
          height: _progressBarHeight,
          decoration: BoxDecoration(
            color: Colors.grey[200]?.withOpacity(0.1),
            borderRadius: BorderRadius.circular(_progressBarRadius),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progressPercentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: _getProgressBarColor(),
                borderRadius: BorderRadius.circular(_progressBarRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Progress text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${progressPercentage.toStringAsFixed(1)}% complete',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.book.pageCount != null)
              Text(
                '${progress.currentPage}/${widget.book.pageCount}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[400],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Color _getProgressBarColor() {
    if (widget.book.isCompleted) {
      return Colors.green;
    }
    return _bookAccentColor ?? Theme.of(context).colorScheme.primary;
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BookDetailsScreen(book: widget.book),
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
