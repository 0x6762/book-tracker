import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'presentation/providers/book_list_provider.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/ui_state_provider.dart';
import 'presentation/providers/book_details_provider.dart';
import 'core/di/service_locator.dart';
import 'application/services/timer_service.dart';
import 'presentation/widgets/search_input.dart';
import 'presentation/widgets/book_card.dart';
import 'presentation/widgets/book_cover_carousel.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/screens/barcode_scanner_screen.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data with proper setup
  tz.initializeTimeZones();

  // Set the local timezone for proper scheduling
  if (tz.local.name.isEmpty) {
    tz.setLocalLocation(tz.getLocation('UTC'));
  }

  // Load environment variables from .env file
  // Make sure to copy .env.example to .env and add your API key
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Set default values if .env file is not available
    dotenv.testLoad(fileInput: 'GOOGLE_BOOKS_API_KEY=your_api_key_here');
  }

  // Initialize service locator
  await ServiceLocator().initialize();

  runApp(const BookTrackerApp());
}

class BookTrackerApp extends StatelessWidget {
  const BookTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BookListProvider()),
        ChangeNotifierProvider(create: (context) => SearchProvider()),
        ChangeNotifierProvider(create: (context) => UIStateProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final bookDetailsProvider = BookDetailsProvider();
            final bookListProvider = context.read<BookListProvider>();
            bookDetailsProvider.setBookListProvider(bookListProvider);
            return bookDetailsProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) => ServiceLocator().timerService,
        ),
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

class _BookTrackerHomePageState extends State<BookTrackerHomePage>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.92);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Timer state is automatically restored by native service
    // Delay book loading to let UI render first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Add a small delay to let the UI render first
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            context.read<BookListProvider>().loadBooks();
          }
        });
      }
    });
  }

  void _handleTimerCompletion(
    UIStateProvider uiStateProvider,
    TimerService timerService,
  ) {
    // Show page update modal (reading time will be added when user updates progress)
    if (timerService.currentBookId != null) {
      uiStateProvider.showPageUpdateModal(timerService.currentBookId!);
      // Clear the just completed state to prevent multiple triggers
      timerService.clearJustCompletedState();
    }
  }

  void _scrollToNewBook(BookListProvider bookListProvider) {
    if (bookListProvider.lastAddedBookId != null) {
      // Find the index of the newly added book
      final bookIndex = bookListProvider.books.indexWhere(
        (book) => book.googleBooksId == bookListProvider.lastAddedBookId,
      );

      if (bookIndex != -1) {
        // Snap to the page for the new book
        _pageController.animateToPage(
          bookIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        // Clear the last added book ID after scrolling
        bookListProvider.clearLastAddedBookId();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Timer state is automatically managed by native service
    super.didChangeAppLifecycleState(state);
  }

  void _navigateToSearch() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SearchScreen(
          searchController: _searchController,
          onBack: () {
            Navigator.of(context).pop();
            _searchController.clear();
            context.read<SearchProvider>().searchBooks('');
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

  Future<void> _navigateToScannerAndSearch() async {
    final isbn = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (isbn != null && isbn.trim().isNotEmpty) {
      _searchController.text = isbn;
      context.read<SearchProvider>().searchBooks(isbn);
      _navigateToSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookListProvider, TimerService>(
      builder: (context, bookListProvider, timerService, child) {
        // Check if we need to scroll to a newly added book
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scrollToNewBook(bookListProvider);
          }
        });

        // Handle timer completion (both automatic and manual stop)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && timerService.hasTimerJustCompleted) {
            final uiStateProvider = context.read<UIStateProvider>();
            _handleTimerCompletion(uiStateProvider, timerService);
          }
        });

        // Show app bar only when there are books or when searching
        final searchProvider = context.read<SearchProvider>();
        final showAppBar =
            bookListProvider.isInitialized &&
            (bookListProvider.books.isNotEmpty || searchProvider.isSearching);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: showAppBar
              ? AppBar(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  scrolledUnderElevation: 0,
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
          body: !bookListProvider.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : showAppBar
              ? Column(
                  children: [
                    // Search Bar with Hero Animation
                    Hero(
                      tag: 'search_bar',
                      child: SearchInput(
                        controller: _searchController,
                        onTap: _navigateToSearch,
                        isSearchMode: false,
                        onScan: _navigateToScannerAndSearch,
                      ),
                    ),
                    // Content
                    Expanded(child: _buildBookList(bookListProvider)),
                  ],
                )
              : _buildEmptyStateWithSearch(bookListProvider),
        );
      },
    );
  }

  Widget _buildEmptyStateWithSearch(BookListProvider bookListProvider) {
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
                onScan: _navigateToScannerAndSearch,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(BookListProvider bookListProvider) {
    if (bookListProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookListProvider.error != null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${bookListProvider.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => bookListProvider.loadBooks(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      physics: const PageScrollPhysics(),
      itemCount: bookListProvider.books.length,
      padEnds: true,
      itemBuilder: (context, index) {
        final book = bookListProvider.books[index];

        // Width is controlled by PageView's viewportFraction; height derives from aspect ratio

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Align(
            alignment: Alignment.topCenter,
            child: AspectRatio(
              aspectRatio: 1 / 1.6,
              child: BookCard(book: book, margin: EdgeInsets.zero),
            ),
          ),
        );
      },
    );
  }
}
