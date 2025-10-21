import 'package:flutter/material.dart';
import '../../domain/entities/book.dart';

class ProgressUpdateBottomSheet extends StatefulWidget {
  final BookEntity book;
  final Function(int currentPage) onUpdateProgress;
  final VoidCallback? onCompleteReading;
  final bool isFromTimerCompletion;

  const ProgressUpdateBottomSheet({
    super.key,
    required this.book,
    required this.onUpdateProgress,
    this.onCompleteReading,
    this.isFromTimerCompletion = false,
  });

  @override
  State<ProgressUpdateBottomSheet> createState() =>
      _ProgressUpdateBottomSheetState();
}

class _ProgressUpdateBottomSheetState extends State<ProgressUpdateBottomSheet> {
  late TextEditingController _pageController;
  late int _currentPage;
  bool _isInvalidInput = false;

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

  bool _isValidPageInput(int? page) {
    // If page is null (empty field), treat as 0 which is valid
    if (page == null) return true;
    if (page < 0) return false;
    if (widget.book.pageCount != null && page > widget.book.pageCount!)
      return false;
    return true;
  }

  void _updateProgress() {
    final newPage =
        int.tryParse(_pageController.text) ?? 0; // Default to 0 if empty
    if (newPage >= 0) {
      // Validate against total pages if available
      if (widget.book.pageCount != null && newPage > widget.book.pageCount!) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Page number cannot exceed total pages (${widget.book.pageCount})',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      setState(() {
        _currentPage = newPage;
      });
      widget.onUpdateProgress(newPage);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                ).colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title section
          if (widget.isFromTimerCompletion) ...[
            Text(
              'Update your progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.book.readingProgress?.totalReadingTimeMinutes != null &&
                widget.book.readingProgress!.totalReadingTimeMinutes > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Total reading time: ${widget.book.readingProgress!.getFormattedReadingTime()}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ] else ...[
            Text(
              'Update Progress',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],

          const SizedBox(height: 24),

          // Page input
          TextField(
            controller: _pageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Current Page',
              filled: true,
              fillColor: _isInvalidInput
                  ? Theme.of(
                      context,
                    ).colorScheme.errorContainer.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: _isInvalidInput
                    ? BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 1,
                      )
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _isInvalidInput
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              errorText: _isInvalidInput && widget.book.pageCount != null
                  ? 'Cannot exceed ${widget.book.pageCount} pages'
                  : null,
            ),
            onChanged: (value) {
              final page = int.tryParse(value);
              setState(() {
                _isInvalidInput = !_isValidPageInput(page);
                if (page != null) {
                  _currentPage = page;
                } else if (value.isEmpty) {
                  _currentPage = 0; // Default to 0 when empty
                }
              });
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

          const SizedBox(height: 32),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isInvalidInput ? null : _updateProgress,
              child: const Text('Update'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          // Add bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// Helper function to show the bottom sheet
void showProgressUpdateBottomSheet({
  required BuildContext context,
  required BookEntity book,
  required Function(int currentPage) onUpdateProgress,
  VoidCallback? onCompleteReading,
  bool isFromTimerCompletion = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ProgressUpdateBottomSheet(
      book: book,
      onUpdateProgress: onUpdateProgress,
      onCompleteReading: onCompleteReading,
      isFromTimerCompletion: isFromTimerCompletion,
    ),
  );
}
