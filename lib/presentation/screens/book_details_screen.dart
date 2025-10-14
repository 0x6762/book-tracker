import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/book.dart';
import '../widgets/book_details_tabs.dart';
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
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

    // Listen to scroll changes to update fade animation
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const double fadeStartOffset = 24.0; // Start fading
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
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
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
              ];
            },
            body: BookDetailsTabs(book: updatedBook),
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
