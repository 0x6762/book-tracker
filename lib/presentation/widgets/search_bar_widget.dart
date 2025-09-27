import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../constants/app_constants.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;

  const SearchBarWidget({super.key, required this.controller});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  void initState() {
    super.initState();
    // Listen to text changes to update the clear icon
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.searchBarPadding),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: 'Search for books...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(56), // Pill shape
            borderSide: BorderSide.none, // No border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(56),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(56),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          suffixIcon: Consumer<BookProvider>(
            builder: (context, bookProvider, child) {
              if (bookProvider.isSearching) {
                return const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              // Show clear icon if there's text in the field
              if (widget.controller.text.isNotEmpty) {
                return IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    widget.controller.clear();
                    context.read<BookProvider>().searchBooks('');
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        onSubmitted: (query) {
          context.read<BookProvider>().searchBooks(query);
        },
      ),
    );
  }
}
