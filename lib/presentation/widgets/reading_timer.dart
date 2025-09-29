import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import 'timer_bottom_sheet.dart';
import 'progress_update_bottom_sheet.dart';
import '../../domain/entities/book.dart';

class ReadingTimer extends StatelessWidget {
  final int bookId;
  final String bookTitle;
  final BookEntity book;

  const ReadingTimer({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        final isCurrentBook = bookProvider.currentBookId == bookId;
        final isRunning = bookProvider.isTimerRunning && isCurrentBook;
        final isCompleted = bookProvider.isTimerCompleted && isCurrentBook;
        final timeText = isCurrentBook ? bookProvider.formattedTime : '';
        final hasTimer = bookProvider.totalSeconds > 0 && isCurrentBook;

        // Check if we should show page update modal
        if (bookProvider.shouldShowPageUpdateModal && isCurrentBook) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            bookProvider.clearPageUpdateModalFlag();
            _showPageUpdateModal(context, bookProvider);
            // Clear the current book after showing modal
            bookProvider.clearCurrentBook();
          });
        }

        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: hasTimer
              ? Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Timer info
                          Expanded(
                            child: Text(
                              timeText,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isCurrentBook
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),

                          // Timer controls
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Stop button
                              IconButton(
                                onPressed: () => bookProvider.stopTimer(),
                                icon: const Icon(Icons.stop),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.grey.withOpacity(0.2),
                                  foregroundColor: const Color(0xFFDD4B41),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Pause/Resume button
                              IconButton(
                                onPressed: isRunning
                                    ? () => bookProvider.pauseTimer()
                                    : () => bookProvider.resumeTimer(),
                                icon: Icon(
                                  isRunning ? Icons.pause : Icons.play_arrow,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Progress bar
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: bookProvider.totalSeconds > 0
                              ? (bookProvider.totalSeconds -
                                        bookProvider.remainingSeconds) /
                                    bookProvider.totalSeconds
                              : 0.0,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showTimerBottomSheet(context),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: Text(
                        book.hasReadingProgress
                            ? 'Continue Reading'
                            : 'Start Reading',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(56),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _showTimerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimerBottomSheet(book: book),
    );
  }

  void _showPageUpdateModal(BuildContext context, BookProvider bookProvider) {
    showProgressUpdateBottomSheet(
      context: context,
      book: book,
      isFromTimerCompletion: true,
      onUpdateProgress: (currentPage) {
        bookProvider.updateProgress(book.id!, currentPage);
      },
      onCompleteReading: () {
        bookProvider.completeReading(book.id!);
      },
    );
  }
}
