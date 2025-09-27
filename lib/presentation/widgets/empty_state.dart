import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionText;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.icon = Icons.menu_book,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.emptyStatePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.extraLargeSpacing),
              decoration: BoxDecoration(
                color: AppConstants.emptyStateBlue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppConstants.largeBookIconSize,
                color: AppConstants.emptyStateBlue,
              ),
            ),
            const SizedBox(height: AppConstants.extraLargeSpacing),
            Text(
              title,
              style: const TextStyle(
                fontSize: AppConstants.emptyStateTitleSize,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppConstants.emptyStateBodySize,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            if (actionText != null) ...[
              const SizedBox(height: AppConstants.extraLargeSpacing),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.largeSpacing,
                  vertical: AppConstants.mediumSpacing,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.emptyStateBlue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search,
                      color: AppConstants.emptyStateBlue,
                      size: 20,
                    ),
                    const SizedBox(width: AppConstants.mediumSpacing),
                    Text(
                      actionText!,
                      style: TextStyle(
                        color: AppConstants.emptyStateBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
