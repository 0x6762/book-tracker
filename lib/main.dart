import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'presentation/providers/book_provider.dart';
import 'domain/entities/book.dart';

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
        title: 'Book Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
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

    // Listen to text changes to update the clear icon
    _searchController.addListener(() {
      setState(() {});
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
      appBar: AppBar(title: const Text('Readr')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for books... (min 3 characters)',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
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
                    if (_searchController.text.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<BookProvider>().searchBooks('');
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              onChanged: (query) {
                context.read<BookProvider>().searchBooks(query);
              },
            ),
          ),
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
    );
  }

  Widget _buildSearchResults(BookProvider bookProvider) {
    if (bookProvider.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No books found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: bookProvider.searchResults.length,
      itemBuilder: (context, index) {
        final book = bookProvider.searchResults[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: book.thumbnailUrl != null
                ? CachedNetworkImage(
                    imageUrl: book.thumbnailUrl!,
                    width: 50,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 50,
                      height: 70,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.book, size: 50),
                  )
                : const Icon(Icons.book, size: 50),
            title: Text(book.title),
            subtitle: Text(book.authors),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.read<BookProvider>().addBook(book);
                // Clear search input and results after adding
                _searchController.clear();
                context.read<BookProvider>().searchBooks('');
              },
            ),
          ),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue[900]?.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.menu_book, size: 64, color: Colors.blue[300]),
              ),
              const SizedBox(height: 24),
              Text(
                'Your Library is Empty',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Search for books above and add them to your personal collection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[800]?.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, color: Colors.blue[300], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Start by searching for a book',
                      style: TextStyle(
                        color: Colors.blue[200],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: bookProvider.books.length,
      itemBuilder: (context, index) {
        final book = bookProvider.books[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: book.thumbnailUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: book.thumbnailUrl!,
                      width: 60,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.book,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.book, size: 30, color: Colors.grey),
                  ),
            title: Text(
              book.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  book.authors,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (book.publishedDate != null &&
                    book.publishedDate!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Published: ${book.publishedDate}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
                if (book.pageCount != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${book.pageCount} pages',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => bookProvider.deleteBook(book.id!),
            ),
          ),
        );
      },
    );
  }
}
