import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/providers/book_provider.dart';
import 'presentation/widgets/search_bar_widget.dart';
import 'presentation/widgets/book_card_widget.dart';
import 'presentation/widgets/search_result_card_widget.dart';
import 'presentation/widgets/empty_state_widget.dart';
import 'presentation/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  // Make sure to copy .env.example to .env and add your API key
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: Could not load .env file. Using default values.');
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryBlue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
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
    // Load books when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: GestureDetector(
        onTap: () {
          // Unfocus search field when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            // Search Bar
            SearchBarWidget(controller: _searchController),
            // Content
            Expanded(
              child: Consumer<BookProvider>(
                builder: (context, bookProvider, child) {
                  // Show search results if searching
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

                  if (bookProvider.searchResults.isNotEmpty) {
                    return _buildSearchResults(bookProvider);
                  }

                  // Show regular book list
                  return _buildBookList(bookProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BookProvider bookProvider) {
    if (bookProvider.searchResults.isEmpty) {
      return const EmptyStateWidget(
        title: 'No books found',
        subtitle: 'Try a different search term',
        icon: Icons.search_off,
      );
    }

    return ListView.builder(
      itemCount: bookProvider.searchResults.length,
      itemBuilder: (context, index) {
        final book = bookProvider.searchResults[index];
        return SearchResultCardWidget(
          book: book,
          onAdd: () {
            context.read<BookProvider>().addBook(book);
            // Clear search input and results after adding
            _searchController.clear();
            context.read<BookProvider>().searchBooks('');
          },
        );
      },
    );
  }

  Widget _buildBookList(BookProvider bookProvider) {
    if (bookProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${bookProvider.error}'),
            ElevatedButton(
              onPressed: () => bookProvider.loadBooks(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (bookProvider.books.isEmpty) {
      return const EmptyStateWidget(
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
        return BookCardWidget(
          book: book,
          onDelete: () {
            context.read<BookProvider>().deleteBook(book.id!);
          },
        );
      },
    );
  }
}
