import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';

class BookCoverWidget extends StatelessWidget {
  final String? thumbnailUrl;
  final double height;
  final double? width;
  final double iconSize;
  final bool showShadow;

  const BookCoverWidget({
    super.key,
    this.thumbnailUrl,
    required this.height,
    this.width,
    required this.iconSize,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: thumbnailUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              child: CachedNetworkImage(
                imageUrl: thumbnailUrl!,
                height: height,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildErrorWidget(),
              ),
            )
          : _buildErrorWidget(),
    );

    return container;
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width ?? height * 0.75, // Default 3:4 aspect ratio
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: height,
      width: width ?? height * 0.75, // Default 3:4 aspect ratio
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Icon(Icons.book, size: iconSize, color: Colors.grey),
    );
  }
}
