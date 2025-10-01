import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

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
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.emptyStatePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60), // Add some top spacing
            Container(
              padding: const EdgeInsets.all(AppConstants.extraLargeSpacing),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppConstants.largeBookIconSize,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.extraLargeSpacing),
            Text(
              title,
              style: TextStyle(
                fontSize: AppConstants.emptyStateTitleSize,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.emptyStateBodySize,
                color: theme.colorScheme.onSurfaceVariant,
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
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppConstants.mediumSpacing),
                    Text(
                      actionText!,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
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
