import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'book_cover_carousel.dart';
import 'search_input.dart';
import '../../core/constants/app_constants.dart';

class WelcomeView extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchTap;
  final VoidCallback onScanTap;

  const WelcomeView({
    super.key,
    required this.searchController,
    required this.onSearchTap,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo centered at the top
              Center(
                child: SvgPicture.asset(
                  'assets/icon/ic_readr.svg',
                  height: 48,
                  width: 48,
                ),
              ),
              const SizedBox(height: 64),
              // Book cover carousel
              const BookCoverCarousel(
                height: 250,
                width: 180,
                scrollSpeed: 20.0,
                opacity: 0.6,
              ),

              const SizedBox(height: 56),

              // Title and subtitle
              Text(
                'Welcome to Readr',
                style: TextStyle(
                  fontSize: AppConstants.emptyStateTitleSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.mediumSpacing),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Add books to your reading list and start tracking your reading progress.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppConstants.emptyStateBodySize,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),

              // Search bar positioned below text
              const SizedBox(height: 32),
              Hero(
                tag: 'search_bar',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchInput(
                    controller: searchController,
                    onTap: onSearchTap,
                    isSearchMode: false,
                    onScan: onScanTap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
