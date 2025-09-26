import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/book_provider.dart';
import 'domain/entities/book.dart';

void main() {
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
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
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
        },
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
}
