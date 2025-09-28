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
      title: widget.isFromTimerCompletion
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Reading Session Complete!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.book.readingProgress?.totalReadingTimeMinutes !=
                        null &&
                    widget.book.readingProgress!.totalReadingTimeMinutes >
                        0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Total reading time: ${widget.book.readingProgress!.getFormattedReadingTime()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            )
          : const Text('Update Progress'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isFromTimerCompletion) ...[
            Text(
              'Let\'s update your progress.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'What page did you stop reading at this session?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
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
          if (widget.book.pageCount != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                '$_currentPage of ${widget.book.pageCount} pages',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
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
      ],
    );
  }
}
