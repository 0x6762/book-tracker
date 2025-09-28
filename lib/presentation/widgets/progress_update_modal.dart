import 'package:flutter/material.dart';
import '../../domain/entities/book.dart';

class ProgressUpdateModal extends StatefulWidget {
  final BookEntity book;
  final Function(int currentPage) onUpdateProgress;
  final VoidCallback? onCompleteReading;
  final bool isFromTimerCompletion;

  const ProgressUpdateModal({
    super.key,
    required this.book,
    required this.onUpdateProgress,
    this.onCompleteReading,
    this.isFromTimerCompletion = false,
  });

  @override
  State<ProgressUpdateModal> createState() => _ProgressUpdateModalState();
}

class _ProgressUpdateModalState extends State<ProgressUpdateModal> {
  late TextEditingController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.book.readingProgress?.currentPage ?? 1;
    _pageController = TextEditingController(text: _currentPage.toString());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final newPage = int.tryParse(_pageController.text);
    if (newPage != null && newPage > 0) {
      setState(() {
        _currentPage = newPage;
      });
      widget.onUpdateProgress(newPage);
    }
  }

  void _completeReading() {
    widget.onCompleteReading?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final progressPercentage =
        widget.book.pageCount != null && widget.book.pageCount! > 0
        ? (_currentPage / widget.book.pageCount! * 100).clamp(0.0, 100.0)
        : 0.0;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isFromTimerCompletion) ...[
            Row(
              children: [
                const Icon(Icons.timer, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Reading Session Complete!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Text(
            widget.book.title,
            style: widget.isFromTimerCompletion
                ? Theme.of(context).textTheme.bodyLarge
                : Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isFromTimerCompletion) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'How many pages did you read during this session?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Progress bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${progressPercentage.toStringAsFixed(1)}% complete',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (widget.book.pageCount != null) ...[
            const SizedBox(height: 4),
            Text(
              '$_currentPage of ${widget.book.pageCount} pages',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (widget.book.readingProgress?.totalReadingTimeMinutes != null &&
              widget.book.readingProgress!.totalReadingTimeMinutes > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Total reading time: ${widget.book.readingProgress!.getFormattedReadingTime()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Page input
          TextField(
            controller: _pageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Current Page',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final page = int.tryParse(value);
              if (page != null && page > 0) {
                setState(() {
                  _currentPage = page;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateProgress,
          child: Text(
            widget.book.hasReadingProgress ? 'Update' : 'Start Reading',
          ),
        ),
        if (widget.book.hasReadingProgress && !widget.book.isCompleted)
          ElevatedButton(
            onPressed: _completeReading,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Complete'),
          ),
      ],
    );
  }
}
