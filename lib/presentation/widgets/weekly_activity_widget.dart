import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../data/book_database.dart';

class WeeklyActivityWidget extends StatelessWidget {
  final int bookId;
  final Color? accentColor;

  const WeeklyActivityWidget({
    super.key,
    required this.bookId,
    this.accentColor,
  });

  Future<List<DailyReadingActivityData>> _getWeeklyActivity() async {
    final now = DateTime.now();
    // Get start of current week (Monday)
    // weekday: 1=Mon, 7=Sun
    final currentWeekday = now.weekday;
    final startOfWeek = now.subtract(Duration(days: currentWeekday - 1));
    // Normalize to midnight
    final start = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    // End of week (Sunday)
    final end = start.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    final database = ServiceLocator().database;
    return await database.getDailyActivity(
      bookId: bookId,
      fromDate: start,
      toDate: end,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DailyReadingActivityData>>(
      future: _getWeeklyActivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final activities = snapshot.data ?? [];
        final now = DateTime.now();
        // Monday of current week
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final weekStart = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );

        // Create a map of date -> minutes read
        final activityMap = <DateTime, int>{};
        for (final activity in activities) {
          // Normalize date to midnight
          final date = DateTime(
            activity.activityDate.year,
            activity.activityDate.month,
            activity.activityDate.day,
          );
          activityMap[date] = activity.minutesRead;
        }

        final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This Week\'s Activity',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final date = weekStart.add(Duration(days: index));
                  final minutes = activityMap[date] ?? 0;
                  final isToday =
                      date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;

                  return _buildDayItem(
                    context,
                    weekDays[index],
                    minutes,
                    isToday,
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayItem(
    BuildContext context,
    String dayLabel,
    int minutes,
    bool isToday,
  ) {
    final hasRead = minutes > 0;

    // Simple binary state: Read vs Not Read
    // Use accent color if available, otherwise fallback to theme primary
    final activeColor = accentColor ?? Theme.of(context).colorScheme.primary;

    final backgroundColor = hasRead
        ? activeColor.withOpacity(0.2) // Light tinted background
        : Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.2);

    final iconColor = activeColor;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: hasRead ? Icon(Icons.check, size: 20, color: iconColor) : null,
        ),
        const SizedBox(height: 4),
        Text(
          dayLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
