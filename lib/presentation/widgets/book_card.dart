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

    // Extract color from book cover
    _extractBookColor();
  }

  void _extractBookColor() async {
    if (widget.book.thumbnailUrl != null) {
      final color = await ColorExtractor.extractColorFromImage(
        widget.book.thumbnailUrl,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  children: [
                    // Full cover background
                    Positioned.fill(
                      child: Hero(
                        tag: 'book_cover_${widget.book.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: widget.book.thumbnailUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: widget.book.thumbnailUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      _buildPlaceholder(),
                                  errorWidget: (context, url, error) =>
                                      _buildErrorWidget(),
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
                        height: 200, // Bigger gradient overlay
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(
                                context,
                              ).colorScheme.surface.withOpacity(0.8),
                              Theme.of(
                                context,
                              ).colorScheme.surface.withOpacity(1),
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
                                  const SizedBox(height: 16),

                                  // Reading progress section
                                  if (widget.book.hasReadingProgress) ...[
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
            color: Colors.grey[700],
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
                          ColorExtractor.getFallbackColor(widget.book.title)),
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
