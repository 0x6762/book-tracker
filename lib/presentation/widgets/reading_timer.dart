import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import 'timer_bottom_sheet.dart';
import 'progress_update_modal.dart';
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
        final timeText = bookProvider.formattedTime;
        final hasTimer = bookProvider.totalSeconds > 0 && isCurrentBook;

        // Check if we should show page update modal
        if (bookProvider.shouldShowPageUpdateModal && isCurrentBook) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            bookProvider.clearPageUpdateModalFlag();
            _showPageUpdateModal(context, bookProvider);
          });
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isCompleted
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrentBook
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: isCurrentBook ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Timer info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isCompleted ? 'Reading Complete!' : 'Reading Timer',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: isCompleted
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isCompleted ? '🎉 Well done!' : timeText,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isCurrentBook
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Timer controls
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCompleted) ...[
                        // Reset button
                        IconButton(
                          onPressed: () => bookProvider.stopTimer(),
                          icon: const Icon(Icons.refresh),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                        ),
                      ] else if (hasTimer && isRunning) ...[
                        // Pause button
                        IconButton(
                          onPressed: () => bookProvider.pauseTimer(),
                          icon: const Icon(Icons.pause),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Stop button
                        IconButton(
                          onPressed: () => bookProvider.stopTimer(),
                          icon: const Icon(Icons.stop),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.errorContainer,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ] else if (hasTimer && !isRunning) ...[
                        // Resume button
                        IconButton(
                          onPressed: () => bookProvider.resumeTimer(),
                          icon: const Icon(Icons.play_arrow),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Stop button
                        IconButton(
                          onPressed: () => bookProvider.stopTimer(),
                          icon: const Icon(Icons.stop),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.errorContainer,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ] else ...[
                        // Set timer button
                        IconButton(
                          onPressed: () => _showTimerBottomSheet(context),
                          icon: const Icon(Icons.timer),
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
                    ],
                  ),
                ],
              ),

              // Progress bar
              if (hasTimer && !isCompleted) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
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
                ),
              ],
            ],
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
    showDialog(
      context: context,
      builder: (context) => ProgressUpdateModal(
        book: book,
        isFromTimerCompletion: true,
        onUpdateProgress: (currentPage) {
          bookProvider.updateProgress(book.id!, currentPage);
          Navigator.of(context).pop();
        },
        onCompleteReading: () {
          bookProvider.completeReading(book.id!);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
