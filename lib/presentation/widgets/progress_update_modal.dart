import 'package:flutter/material.dart';
import '../../domain/entities/book.dart';

class ProgressUpdateModal extends StatefulWidget {
  final BookEntity book;
  final Function(int currentPage) onUpdateProgress;
  final VoidCallback? onCompleteReading;

  const ProgressUpdateModal({
    super.key,
    required this.book,
    required this.onUpdateProgress,
    this.onCompleteReading,
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
      title: Text(widget.book.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ElevatedButton(onPressed: _updateProgress, child: const Text('Update')),
        if (widget.book.isCurrentlyReading)
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
