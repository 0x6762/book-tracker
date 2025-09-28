import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../simple_book_provider.dart';
import '../widgets/search_result_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/search_input.dart';

class SearchScreen extends StatefulWidget {
  final TextEditingController searchController;
  final VoidCallback onBack;

  const SearchScreen({
    super.key,
    required this.searchController,
    required this.onBack,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start animation when screen loads
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Search Bar with Hero Animation
                Hero(
                  tag: 'search_bar',
                  child: SearchInput(
                    controller: widget.searchController,
                    isSearchMode: true,
                    showBackButton: true,
                    onBack: widget.onBack,
                  ),
                ),
                // Search Results
                Expanded(
                  child: Consumer<SimpleBookProvider>(
                    builder: (context, bookProvider, child) {
                      if (bookProvider.isSearching) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Searching for books...'),
                            ],
                          ),
                        );
                      }

                      // Only show empty state if user has searched but found no results
                      if (bookProvider.searchResults.isEmpty &&
                          widget.searchController.text.isNotEmpty) {
                        return const EmptyState(
                          title: 'No books found',
                          subtitle: 'Try a different search term',
                          icon: Icons.search_off,
                        );
                      }

                      // Show blank screen when no search has been performed
                      if (bookProvider.searchResults.isEmpty &&
                          widget.searchController.text.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return ListView.builder(
                        itemCount: bookProvider.searchResults.length,
                        itemBuilder: (context, index) {
                          final book = bookProvider.searchResults[index];
                          return SearchResultCard(
                            book: book,
                            onAdd: () async {
                              final bookProvider = context
                                  .read<SimpleBookProvider>();
                              await bookProvider.addBook(book);

                              if (bookProvider.error != null) {
                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(bookProvider.error!),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                // Clear the error after showing it
                                bookProvider.clearError();
                              } else {
                                // Navigate back to main screen after adding book
                                widget.onBack();
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
