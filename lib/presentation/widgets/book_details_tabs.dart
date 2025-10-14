import 'package:flutter/material.dart';
import '../../domain/entities/book.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/text_styles.dart';

class BookDetailsTabs extends StatefulWidget {
  final BookEntity book;
  final Widget statisticsContent;
  final Widget bookDetailsContent;

  const BookDetailsTabs({
    super.key,
    required this.book,
    required this.statisticsContent,
    required this.bookDetailsContent,
  });

  @override
  State<BookDetailsTabs> createState() => _BookDetailsTabsState();
}

class _BookDetailsTabsState extends State<BookDetailsTabs>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.md),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Statistics'),
              Tab(text: 'Book Details'),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: AppTextStyles.titleMedium,
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [widget.statisticsContent, widget.bookDetailsContent],
          ),
        ),
      ],
    );
  }
}
