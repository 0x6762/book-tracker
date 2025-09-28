import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../../domain/entities/book.dart';

class SearchResultCard extends StatelessWidget {
  final BookEntity book;
  final VoidCallback? onAdd;

  const SearchResultCard({super.key, required this.book, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.cardMargin,
        vertical: AppConstants.mediumSpacing,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Book cover
            Container(
              height: AppConstants.searchBookHeight,
              width: AppConstants.searchBookWidth,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: book.thumbnailUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                      child: Image.network(
                        book.thumbnailUrl!,
                        height: AppConstants.searchBookHeight,
                        width: AppConstants.searchBookWidth,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildPlaceholder();
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            _buildErrorWidget(),
                      ),
                    )
                  : _buildErrorWidget(),
            ),
            const SizedBox(width: 12),
            // Book details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
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
                    book.authors,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Add button
            IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: AppConstants.searchBookHeight,
      width: AppConstants.searchBookWidth,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: AppConstants.searchBookHeight,
      width: AppConstants.searchBookWidth,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: const Icon(Icons.book, size: 60, color: Colors.grey),
    );
  }
}
