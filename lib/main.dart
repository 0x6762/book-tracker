import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'presentation/providers/book_provider.dart';
import 'application/services/timer_service.dart';
import 'application/services/notification_service.dart';
import 'presentation/widgets/search_input.dart';
import 'presentation/widgets/book_card.dart';
import 'presentation/widgets/book_cover_carousel.dart';
import 'presentation/screens/search_screen.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Load environment variables from .env file
  // Make sure to copy .env.example to .env and add your API key
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Set default values if .env file is not available
    dotenv.testLoad(fileInput: 'GOOGLE_BOOKS_API_KEY=your_api_key_here');
  }

  runApp(const BookTrackerApp());
}

class BookTrackerApp extends StatelessWidget {
  const BookTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BookProvider()),
        ChangeNotifierProvider(create: (context) => TimerService()),
      ],
      child: MaterialApp(
        title: AppConstants.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark, // Force dark theme
        home: const BookTrackerHomePage(),
      ),
    );
  }
}

class BookTrackerHomePage extends StatefulWidget {
  const BookTrackerHomePage({super.key});

  @override
  State<BookTrackerHomePage> createState() => _BookTrackerHomePageState();
}

class _BookTrackerHomePageState extends State<BookTrackerHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize services
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeServices();
      }
    });
    // Delay book loading to let UI render first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Add a small delay to let the UI render first
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            context.read<BookProvider>().loadBooks();
          }
        });
      }
    });
  }

  Future<void> _initializeServices() async {
    // Initialize notification service
    await NotificationService().initialize();
  }

  void _handleTimerCompletion(
    BookProvider bookProvider,
    TimerService timerService,
  ) {
    // Mark completion as handled immediately to prevent multiple triggers
    timerService.markCompletionHandled();

    // Show page update modal (reading time will be added when user updates progress)
    if (timerService.currentBookId != null) {
      bookProvider.showPageUpdateModal(timerService.currentBookId!);
    }
  }

  void _scrollToNewBook(BookProvider bookProvider) {
    if (bookProvider.lastAddedBookId != null) {
      // Find the index of the newly added book
      final bookIndex = bookProvider.books.indexWhere(
        (book) => book.googleBooksId == bookProvider.lastAddedBookId,
      );

      if (bookIndex != -1) {
        // Calculate scroll position
        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = screenWidth * 0.90;
        final spacing = 16.0;
        final scrollPosition = bookIndex * (cardWidth + spacing);

        // Scroll to the new book
        _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        // Clear the last added book ID after scrolling
        bookProvider.clearLastAddedBookId();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToSearch() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SearchScreen(
          searchController: _searchController,
          onBack: () {
            Navigator.of(context).pop();
            _searchController.clear();
            context.read<BookProvider>().searchBooks('');
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookProvider, TimerService>(
      builder: (context, bookProvider, timerService, child) {
        // Check if we need to scroll to a newly added book
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scrollToNewBook(bookProvider);
          }
        });

        // Handle timer completion (both automatic and manual stop)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              (timerService.isTimerCompleted ||
                  timerService.wasManuallyStopped)) {
            _handleTimerCompletion(bookProvider, timerService);
          }
        });

        // Show app bar only when there are books or when searching
        final showAppBar =
            bookProvider.books.isNotEmpty || bookProvider.isSearching;

        return Scaffold(
          appBar: showAppBar
              ? AppBar(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icon/ic_readr.svg',
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          body: showAppBar
              ? Column(
                  children: [
                    // Search Bar with Hero Animation
                    Hero(
                      tag: 'search_bar',
                      child: SearchInput(
                        controller: _searchController,
                        onTap: _navigateToSearch,
                        isSearchMode: false,
                      ),
                    ),
                    // Content
                    Expanded(child: _buildBookList(bookProvider)),
                  ],
                )
              : _buildEmptyStateWithSearch(bookProvider),
        );
      },
    );
  }

  Widget _buildEmptyStateWithSearch(BookProvider bookProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 30% from top spacing
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          // Book cover carousel at the top
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
                controller: _searchController,
                onTap: _navigateToSearch,
                isSearchMode: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(BookProvider bookProvider) {
    if (bookProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookProvider.error != null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${bookProvider.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => bookProvider.loadBooks(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: bookProvider.books.asMap().entries.map((entry) {
                final index = entry.key;
                final book = entry.value;

                // Calculate dynamic width based on screen width
                final screenWidth = MediaQuery.of(context).size.width;
                final cardWidth = screenWidth * 0.90; // 85% of screen width

                return Row(
                  children: [
                    Container(
                      width: cardWidth,
                      height:
                          cardWidth *
                          1.6, // Realistic book aspect ratio (like 6" x 9")
                      child: BookCard(
                        book: book,
                        margin: EdgeInsets.zero, // Remove internal card margins
                      ),
                    ),
                    // Add spacing only between cards, not after the last one
                    if (index < bookProvider.books.length - 1)
                      const SizedBox(width: 16),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
