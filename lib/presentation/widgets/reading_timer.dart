import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/book_details_provider.dart';
import '../providers/ui_state_provider.dart';
import '../../application/services/timer_service.dart';
import '../../domain/entities/book.dart';

class ReadingTimer extends StatefulWidget {
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
  State<ReadingTimer> createState() => _ReadingTimerState();
}

class _ReadingTimerState extends State<ReadingTimer>
    with SingleTickerProviderStateMixin {
  bool _showSetup = false;
  int _selectedMinutes = 20;
  bool _wasSelectedByButton = false;
  final List<int> _presetMinutes = [5, 10, 15, 20, 30, 60, 120, 0];
  late TextEditingController _pageController;
  int? _inlineCurrentPage;
  bool _forceProgressUpdate = false;
  bool _isInvalidPageInput = false;

  @override
  void initState() {
    super.initState();
    _inlineCurrentPage = widget.book.readingProgress?.currentPage ?? 1;
    _pageController = TextEditingController(
      text: (_inlineCurrentPage ?? 1).toString(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isValidPageInput(int? page) {
    // If page is null (empty field), treat as 0 which is valid
    if (page == null) return true;
    if (page < 0) return false;
    if (widget.book.pageCount != null && page > widget.book.pageCount!)
      return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookDetailsProvider, TimerService>(
      builder: (context, bookDetailsProvider, timerService, child) {
        final isCurrentBook = timerService.currentBookId == widget.bookId;
        final isRunning = timerService.isTimerRunning && isCurrentBook;
        final isCompleted =
            timerService.remainingSeconds <= 0 &&
            timerService.totalSeconds > 0 &&
            isCurrentBook;
        final timeText = isCurrentBook ? timerService.formattedTime : '';
        final hasTimer = timerService.totalSeconds > 0 && isCurrentBook;

        // If timer moved to another book, collapse setup (ignore when no current book)
        if (!hasTimer &&
            !isCompleted &&
            _showSetup == true &&
            timerService.currentBookId != null &&
            timerService.currentBookId != widget.bookId) {
          _showSetup = false;
        }

        // Show page update modal after completion
        final uiStateProvider = context.read<UIStateProvider>();
        if (uiStateProvider.shouldShowPageUpdateModal && isCurrentBook) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            uiStateProvider.hidePageUpdateModal();
            setState(() {
              _forceProgressUpdate = true;
            });
          });
        }

        Widget childContent;
        if (isCompleted || _forceProgressUpdate) {
          childContent = _buildCompletedState(
            context,
            bookDetailsProvider,
            timerService,
          );
        } else if (hasTimer) {
          childContent = _buildActiveTimerState(
            context,
            bookDetailsProvider,
            timerService,
            timeText,
            isRunning,
          );
        } else if (_showSetup) {
          childContent = _buildTimerSetupState(
            context,
            bookDetailsProvider,
            timerService,
          );
        } else {
          childContent = _buildStartButton(context);
        }

        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: childContent,
          ),
        );
      },
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _showSetup = true;
            });
          },

          label: Text(
            widget.book.hasReadingProgress
                ? 'Continue Reading'
                : 'Start Reading',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(56),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTimerState(
    BuildContext context,
    BookDetailsProvider bookDetailsProvider,
    TimerService timerService,
    String timeText,
    bool isRunning,
  ) {
    return Container(
      key: const ValueKey('active'),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeText,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (timerService.isTimerPaused &&
                        timerService.currentBookId == widget.bookId) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Paused',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => timerService.stopTimer(),
                    icon: const Icon(Icons.stop),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      foregroundColor: const Color(0xFFDD4B41),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed:
                        (timerService.isTimerPaused &&
                            timerService.currentBookId == widget.bookId)
                        ? () => timerService.resumeTimer()
                        : () => timerService.pauseTimer(),
                    icon: Icon(
                      (timerService.isTimerPaused &&
                              timerService.currentBookId == widget.bookId)
                          ? Icons.play_arrow
                          : Icons.pause,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: timerService.totalSeconds > 0
                  ? (timerService.totalSeconds -
                            timerService.remainingSeconds) /
                        timerService.totalSeconds
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
    );
  }

  Widget _buildTimerSetupState(
    BuildContext context,
    BookDetailsProvider bookDetailsProvider,
    TimerService timerService,
  ) {
    return Container(
      key: const ValueKey('setup'),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Text(
            _selectedMinutes == 0
                ? '5 seconds'
                : (_selectedMinutes >= 60
                      ? _formatHourMinutes(_selectedMinutes)
                      : '$_selectedMinutes minutes'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Theme.of(
                context,
              ).colorScheme.outline.withOpacity(0.2),
              thumbColor: Theme.of(context).colorScheme.primary,
              overlayColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              trackHeight: 6,
            ),
            child: Slider(
              value: _selectedMinutes == 0 ? 5.0 : _selectedMinutes.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              onChanged: (value) {
                setState(() {
                  _selectedMinutes = value.round();
                  _wasSelectedByButton = false;
                });
              },
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _presetMinutes.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final minutes = _presetMinutes[index];
                final isSelected =
                    _selectedMinutes == minutes && _wasSelectedByButton;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMinutes = minutes;
                      _wasSelectedByButton = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        minutes == 0
                            ? '5s'
                            : (minutes >= 60
                                  ? '${minutes ~/ 60}h'
                                  : '${minutes}m'),
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showSetup = false;
                  });
                },
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(56),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final minutes = _selectedMinutes;
                    final effectiveMinutes =
                        minutes; // 0 means 5s handled in provider UI like bottom sheet
                    timerService.setTimer(widget.book.id!, effectiveMinutes);
                    timerService.startTimer(widget.book.id!);
                    setState(() {
                      _showSetup = false;
                    });
                  },

                  label: const Text('Start Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(56),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedState(
    BuildContext context,
    BookDetailsProvider bookDetailsProvider,
    TimerService timerService,
  ) {
    final pageCount = widget.book.pageCount;
    return Container(
      key: const ValueKey('completed'),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session finished.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Great job! Now let\'s update your progress.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(
                  6,
                ), // Max 6 digits for page numbers
              ],
              decoration: InputDecoration(
                filled: true,
                fillColor: _isInvalidPageInput
                    ? Theme.of(
                        context,
                      ).colorScheme.errorContainer.withOpacity(0.1)
                    : Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: _isInvalidPageInput
                      ? BorderSide(
                          color: Theme.of(context).colorScheme.error,
                          width: 1,
                        )
                      : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                    color: _isInvalidPageInput
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                suffixText: pageCount != null ? 'of $pageCount' : null,
                suffixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _isInvalidPageInput
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                errorText: _isInvalidPageInput && pageCount != null
                    ? 'Cannot exceed $pageCount pages'
                    : null,
              ),
              onChanged: (value) {
                final page = int.tryParse(value);
                setState(() {
                  _isInvalidPageInput = !_isValidPageInput(page);
                  if (page != null) {
                    _inlineCurrentPage = page;
                  } else if (value.isEmpty) {
                    _inlineCurrentPage = 0; // Default to 0 when empty
                  }
                });
              },
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isInvalidPageInput
                        ? null
                        : () {
                            final newPage =
                                int.tryParse(_pageController.text) ??
                                0; // Default to 0 if empty
                            if (newPage >= 0) {
                              // Use atomic method to update both progress and reading time
                              // Calculate actual reading time: total time - remaining time
                              final actualReadingSeconds =
                                  timerService.totalSeconds -
                                  timerService.remainingSeconds;

                              // Convert to minutes with proper rounding and minimum validation
                              final minutesRead = _calculateReadingMinutes(
                                actualReadingSeconds,
                              );
                              bookDetailsProvider.updateProgressWithTime(
                                widget.book.id!,
                                newPage,
                                minutesRead,
                              );
                              final uiStateProvider = context
                                  .read<UIStateProvider>();
                              uiStateProvider.hidePageUpdateModal();
                              setState(() {
                                _forceProgressUpdate = false;
                              });
                              // Reset timer after user completes the modal
                              timerService.resetTimer();
                            }
                          },

                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    label: const Text('Update Progress'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatHourMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }

  // Calculate reading minutes with proper rounding and validation
  int _calculateReadingMinutes(int actualReadingSeconds) {
    if (actualReadingSeconds <= 0) return 0;

    // Convert to minutes with ceiling (round up) to avoid losing time
    final minutes = (actualReadingSeconds / 60).ceil();

    // Ensure minimum of 1 minute for any reading session
    // This handles the testing case where 5 seconds = 1 minute
    return minutes.clamp(1, 999); // Cap at reasonable maximum
  }

  // Modal helpers removed; inline progress UI is used instead.
}
