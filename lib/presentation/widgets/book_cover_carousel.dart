import 'package:flutter/material.dart';
import 'dart:math';

class BookCoverCarousel extends StatefulWidget {
  final double height;
  final double width;
  final double spacing;
  final double scrollSpeed; // pixels per second
  final double opacity; // opacity for the carousel

  const BookCoverCarousel({
    super.key,
    required this.height,
    required this.width,
    this.spacing = 16.0,
    this.scrollSpeed = 50.0, // 50 pixels per second
    this.opacity = 1.0,
  });

  @override
  State<BookCoverCarousel> createState() => _BookCoverCarouselState();
}

class _BookCoverCarouselState extends State<BookCoverCarousel>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  List<String> _bookCovers = [];
  final Random _random = Random();
  static const int _repetitions =
      5; // Reduced from 10 to 5 for better memory usage

  @override
  void initState() {
    super.initState();
    _initializeBookCovers();
    _setupAnimation();
  }

  void _initializeBookCovers() {
    // Initialize the list of book cover assets
    _bookCovers = [
      'assets/images/carousel/01.jpg',
      'assets/images/carousel/02.jpg',
      'assets/images/carousel/03.jpg',
      'assets/images/carousel/04.jpg',
      'assets/images/carousel/05.jpg',
      'assets/images/carousel/06.jpg',
    ];

    // Shuffle the list for random order
    _bookCovers.shuffle(_random);
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1), // This will be overridden
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _startContinuousAnimation();
  }

  void _startContinuousAnimation() {
    // Calculate the total width of one complete cycle
    final totalWidth = (_bookCovers.length * (widget.width + widget.spacing));

    // Calculate duration based on scroll speed
    final duration = Duration(
      milliseconds: (totalWidth / widget.scrollSpeed * 1000).round(),
    );

    _animationController.duration = duration;
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.opacity,
      child: SizedBox(
        height: widget.height,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics:
                  const NeverScrollableScrollPhysics(), // Disable user scrolling
              child: Row(children: _buildInfiniteBookCovers()),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildInfiniteBookCovers() {
    final widgets = <Widget>[];

    // Calculate the total width of one complete cycle
    final totalWidth = (_bookCovers.length * (widget.width + widget.spacing));

    // Calculate the current offset based on animation
    final offset = _animation.value * totalWidth;

    // Create multiple repetitions to ensure seamless looping
    for (int repetition = 0; repetition < _repetitions; repetition++) {
      for (int i = 0; i < _bookCovers.length; i++) {
        widgets.add(
          Container(
            margin: EdgeInsets.only(
              right: widget.spacing, // Always add spacing after each book
            ),
            child: _buildBookCover(_bookCovers[i]),
          ),
        );
      }
    }

    return [
      Transform.translate(
        offset: Offset(-offset, 0),
        child: Row(children: widgets),
      ),
    ];
  }

  Widget _buildBookCover(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28.0),
      child: Image.asset(
        imagePath,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        // Add caching for better performance
        cacheWidth: (widget.width * MediaQuery.of(context).devicePixelRatio)
            .round(),
        cacheHeight: (widget.height * MediaQuery.of(context).devicePixelRatio)
            .round(),
        errorBuilder: (context, error, stackTrace) {
          // Fallback widget if image fails to load
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              Icons.book,
              size: widget.width * 0.3,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }
}
