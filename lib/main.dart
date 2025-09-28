import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'domain/entities/book.dart';
import 'presentation/providers/book_provider.dart';
import 'presentation/widgets/search_input.dart';
import 'presentation/widgets/book_card.dart';
import 'presentation/widgets/empty_state.dart';
import 'presentation/widgets/progress_update_modal.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/constants/app_constants.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    return ChangeNotifierProvider(
      create: (context) => BookProvider(),
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

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _searchController.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
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
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, bookProvider, child) {
                return _buildBookList(bookProvider);
              },
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

    if (bookProvider.books.isEmpty) {
      return const EmptyState(
        title: 'Your Library is Empty',
        subtitle:
            'Search for books above and add them to your personal collection',
        actionText: 'Start by searching for a book',
        icon: Icons.menu_book,
      );
    }

    return ListView.builder(
      itemCount: bookProvider.books.length,
      itemBuilder: (context, index) {
        final book = bookProvider.books[index];
        return BookCard(
          book: book,
          onDelete: () {
            context.read<BookProvider>().deleteBook(book.id!);
          },
          onUpdateProgress: () {
            _showProgressModal(context, book, bookProvider);
          },
          onCompleteReading: () {
            context.read<BookProvider>().completeReading(book.id!);
          },
        );
      },
    );
  }

  void _showProgressModal(
    BuildContext context,
    BookEntity book,
    BookProvider bookProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => ProgressUpdateModal(
        book: book,
        onUpdateProgress: (currentPage) {
          bookProvider.updateProgress(book.id!, currentPage);
          Navigator.of(context).pop();
        },
        onCompleteReading: () {
          bookProvider.completeReading(book.id!);
        },
      ),
    );
  }
}
