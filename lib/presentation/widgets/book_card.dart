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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
      Future.delayed(const Duration(milliseconds: 500), _extractBookColor);
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
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only restart animation if we're coming back from navigation
    // This is a more targeted approach
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _animationController.status == AnimationStatus.dismissed) {
        _startAnimation();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              clipBehavior: Clip.hardEdge,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    // Solid background to avoid white seams before/around image
                    Positioned.fill(
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    // Full cover background with fixed aspect ratio
                    Positioned.fill(
                      child: Hero(
                        tag: 'book_cover_${widget.book.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          clipBehavior: Clip.hardEdge,
                          child: widget.book.thumbnailUrl != null
                              ? Transform.scale(
                                  scale: 1.01,
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
                                    imageBuilder: (context, imageProvider) {
                                      // Just return the image - no color extraction here
                                      return Image(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      );
                                    },
                                    placeholder: (context, url) =>
                                        _buildPlaceholder(),
                                    errorWidget: (context, url, error) =>
                                        _buildErrorWidget(),
                                  ),
                                )
                              : _buildErrorWidget(),
                        ),
                      ),
                    ),

                    // Gradient overlay at bottom for readability
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 300, // Gradient overlay
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(
                                context,
                              ).colorScheme.surface.withOpacity(0.8),
                              Theme.of(context).colorScheme.surface,
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.book.authors,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
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
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200]?.withOpacity(0.1),
            borderRadius: BorderRadius.circular(56),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progressPercentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: widget.book.isCompleted
                    ? Colors.green
                    : (_bookAccentColor ??
                          Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(56),
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
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.book.pageCount != null)
              Text(
                '${progress.currentPage}/${widget.book.pageCount}',
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
