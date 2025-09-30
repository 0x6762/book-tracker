import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import '../theme/color_schemes.dart';

class SearchInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onTap;
  final bool isSearchMode;
  final bool showBackButton;
  final VoidCallback? onBack;

  const SearchInput({
    super.key,
    required this.controller,
    this.onTap,
    this.isSearchMode = false,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput>
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
              padding: const EdgeInsets.only(
                top: 8.0, // Reduced top padding
                left: AppConstants.searchBarPadding,
                right: AppConstants.searchBarPadding,
                bottom: AppConstants.searchBarPadding,
              ),
              child: widget.isSearchMode ? _buildSearchMode() : _buildTapMode(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTapMode() {
    final theme = Theme.of(context);
    final customTheme = AppTheme.bookTrackerTheme(context);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Material(
        color: Colors.transparent,
        child: TextField(
          enabled: false, // Disable interaction
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Search for books...',
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            filled: true,
            fillColor: theme.colorScheme.brightness == Brightness.light
                ? AppColorSchemes.searchBarBackground
                : AppColorSchemes.searchBarBackgroundDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                customTheme.borderRadius * 4.5,
              ), // 12 * 4.5 = 54
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                customTheme.borderRadius * 4.5,
              ),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                customTheme.borderRadius * 4.5,
              ),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchMode() {
    final theme = Theme.of(context);
    final customTheme = AppTheme.bookTrackerTheme(context);

    return Material(
      color: Colors.transparent,
      child: TextField(
        controller: widget.controller,
        autofocus: true,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search for books...',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          prefixIcon: widget.showBackButton
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: widget.onBack,
                )
              : Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
          filled: true,
          fillColor: theme.colorScheme.brightness == Brightness.light
              ? AppColorSchemes.searchBarBackground
              : AppColorSchemes.searchBarBackgroundDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(customTheme.borderRadius * 4.5),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(customTheme.borderRadius * 4.5),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(customTheme.borderRadius * 4.5),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          suffixIcon: Consumer<BookProvider>(
            builder: (context, bookProvider, child) {
              if (widget.controller.text.isNotEmpty) {
                return IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
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
