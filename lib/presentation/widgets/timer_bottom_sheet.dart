import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../../domain/entities/book.dart';
import 'progress_update_modal.dart';

class TimerBottomSheet extends StatefulWidget {
  final BookEntity book;

  const TimerBottomSheet({super.key, required this.book});

  @override
  State<TimerBottomSheet> createState() => _TimerBottomSheetState();
}

class _TimerBottomSheetState extends State<TimerBottomSheet> {
  int _selectedMinutes = 20;
  final List<int> _presetMinutes = [
    5,
    10,
    15,
    20,
    30,
    60,
    120,
    0,
  ]; // 0 = 5 seconds for testing
  bool _wasSelectedByButton = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        final isCurrentBook = bookProvider.currentBookId == widget.book.id;
        final isRunning = bookProvider.isTimerRunning && isCurrentBook;
        final isCompleted = bookProvider.isTimerCompleted && isCurrentBook;
        final timeText = bookProvider.formattedTime;
        final hasTimer = bookProvider.totalSeconds > 0 && isCurrentBook;

        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Reading Timer',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              if (isCompleted) ...[
                // Timer completed state
                _buildCompletedState(context, bookProvider),
              ] else if (hasTimer) ...[
                // Active timer state
                _buildActiveTimerState(
                  context,
                  bookProvider,
                  timeText,
                  isRunning,
                ),
              ] else ...[
                // Timer setup state
                _buildTimerSetupState(context, bookProvider),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedState(BuildContext context, BookProvider bookProvider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Reading Session Complete!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Great job! Time to update your progress.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  bookProvider.stopTimer();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
                label: const Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  bookProvider.stopTimer();
                  Navigator.of(context).pop();
                  // Show progress modal
                  _showProgressModal(context, bookProvider);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Update Progress'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveTimerState(
    BuildContext context,
    BookProvider bookProvider,
    String timeText,
    bool isRunning,
  ) {
    return Column(
      children: [
        // Timer display
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Text(
                timeText,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'remaining',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Progress bar
        LinearProgressIndicator(
          value: bookProvider.totalSeconds > 0
              ? (bookProvider.totalSeconds - bookProvider.remainingSeconds) /
                    bookProvider.totalSeconds
              : 0.0,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.outline.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),

        // Control buttons
        Row(
          children: [
            if (isRunning) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => bookProvider.pauseTimer(),
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    bookProvider.stopTimer();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.errorContainer,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onErrorContainer,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => bookProvider.resumeTimer(),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Resume'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    bookProvider.stopTimer();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.errorContainer,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onErrorContainer,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTimerSetupState(
    BuildContext context,
    BookProvider bookProvider,
  ) {
    return Column(
      children: [
        // Horizontal slider
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 16),
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
                  value: _selectedMinutes == 0
                      ? 5.0
                      : _selectedMinutes.toDouble(),
                  min: 5,
                  max: 120,
                  divisions:
                      23, // 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 70, 80, 90, 100, 110, 120
                  onChanged: (value) {
                    setState(() {
                      _selectedMinutes = value.round();
                      _wasSelectedByButton =
                          false; // Reset button selection when using slider
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '5m',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '120m',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Quick preset buttons
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Quick select:',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
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
                    _wasSelectedByButton = true; // Mark as selected by button
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

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  bookProvider.setTimer(widget.book.id!, _selectedMinutes);
                  bookProvider.startTimer(widget.book.id!); // Auto-start the timer
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.timer),
                label: const Text('Start Timer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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

  void _showProgressModal(BuildContext context, BookProvider bookProvider) {
    showDialog(
      context: context,
      builder: (context) => ProgressUpdateModal(
        book: widget.book,
        isFromTimerCompletion: true,
        onUpdateProgress: (currentPage) {
          bookProvider.updateProgress(widget.book.id!, currentPage);
          Navigator.of(context).pop();
        },
        onCompleteReading: () {
          bookProvider.completeReading(widget.book.id!);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
