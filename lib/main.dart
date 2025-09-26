import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
  @override
  void initState() {
    super.initState();
    // Load books when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search for books...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
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
                  return const Center(child: CircularProgressIndicator());
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // For now, just add a sample book
          final sampleBook = BookEntity(
            googleBooksId: 'sample_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Sample Book ${DateTime.now().millisecondsSinceEpoch}',
            authors: 'Sample Author',
            description: 'This is a sample book for testing',
          );
          context.read<BookProvider>().addBook(sampleBook);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchResults(BookProvider bookProvider) {
    return ListView.builder(
      itemCount: bookProvider.searchResults.length,
      itemBuilder: (context, index) {
        final book = bookProvider.searchResults[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: book.thumbnailUrl != null
                ? Image.network(
                    book.thumbnailUrl!,
                    width: 50,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.book, size: 50);
                    },
                  )
                : const Icon(Icons.book, size: 50),
            title: Text(book.title),
            subtitle: Text(book.authors),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.read<BookProvider>().addBook(book);
                // Clear search results after adding
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'No books yet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Add some books to get started',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: bookProvider.books.length,
      itemBuilder: (context, index) {
        final book = bookProvider.books[index];
        return ListTile(
          title: Text(book.title),
          subtitle: Text(book.authors),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => bookProvider.deleteBook(book.id!),
          ),
        );
      },
    );
  }
}
