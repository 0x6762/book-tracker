import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../constants/app_constants.dart';

class SharedSearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onTap;
  final bool isSearchMode;
  final bool showBackButton;
  final VoidCallback? onBack;

  const SharedSearchBarWidget({
    super.key,
    required this.controller,
    this.onTap,
    this.isSearchMode = false,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  State<SharedSearchBarWidget> createState() => _SharedSearchBarWidgetState();
}

class _SharedSearchBarWidgetState extends State<SharedSearchBarWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _animationController.reverse();
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.searchBarPadding),
              child: widget.isSearchMode ? _buildSearchMode() : _buildTapMode(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTapMode() {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[600], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search for books...',
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchMode() {
    return Material(
      color: Colors.transparent,
      child: TextField(
        controller: widget.controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search for books...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          prefixIcon: widget.showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                  color: Colors.grey[600],
                )
              : Icon(Icons.search, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
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
