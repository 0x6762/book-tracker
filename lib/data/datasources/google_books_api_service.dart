import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/book.dart';

class GoogleBooksApiService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1';
  late final Dio _dio;

  GoogleBooksApiService() {
    _dio = Dio();
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<BookEntity?> getBookDetails(String googleBooksId) async {
    try {
      final apiKey = dotenv.env['GOOGLE_BOOKS_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Google Books API key not found');
      }

      final response = await _dio.get(
        '/volumes/$googleBooksId',
        queryParameters: {'key': apiKey},
      );

      if (response.statusCode == 200 && response.data != null) {
        return _mapToBookEntity(response.data);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching book details: $e');
      return null;
    }
  }

  Future<List<BookEntity>> searchBooks(String query) async {
    try {
      final apiKey = dotenv.env['GOOGLE_BOOKS_API_KEY'];
      print(
        '🔑 API Key loaded: ${apiKey != null ? 'Yes (${apiKey.length} chars)' : 'No'}',
      );

      if (apiKey == null || apiKey.isEmpty) {
        print('❌ API key is null or empty');
        throw Exception(
          'Google Books API key not found. Please check your .env file.',
        );
      }

      // Validate API key format (basic check)
      if (apiKey == 'your_api_key_here' || apiKey.length < 20) {
        print('❌ API key is invalid: $apiKey');
        throw Exception(
          'Invalid API key. Please set a valid Google Books API key in your .env file.',
        );
      }

      print('🔍 Searching for: $query');

      final response = await _dio.get(
        '/volumes',
        queryParameters: {'q': query, 'key': apiKey, 'maxResults': 20},
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['items'] ?? [];
        print('✅ Found ${items.length} books');
        return items
            .map((item) => _mapToBookEntity(item, isForSearch: true))
            .toList();
      } else {
        print('❌ API Error: ${response.statusCode}');
        throw Exception('Failed to search books: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🌐 Network Error: ${e.type} - ${e.message}');
      if (e.response?.statusCode == 403) {
        throw Exception('API key is invalid or quota exceeded');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid search query');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('💥 Unexpected Error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  BookEntity _mapToBookEntity(
    Map<String, dynamic> item, {
    bool isForSearch = false,
  }) {
    final volumeInfo = item['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>? ?? {};

    // Extract authors
    final authors = volumeInfo['authors'] as List<dynamic>?;
    final authorsString = authors?.join(', ') ?? 'Unknown Author';

    // Extract categories (for future use)
    // final categories = volumeInfo['categories'] as List<dynamic>?;
    // final categoriesString = categories?.join(', ') ?? '';

    return BookEntity(
      googleBooksId: item['id'] ?? '',
      title: volumeInfo['title'] ?? 'Unknown Title',
      authors: authorsString,
      description: volumeInfo['description'] ?? '',
      thumbnailUrl: _getOptimizedImageUrl(imageLinks, isForSearch: isForSearch),
      publishedDate: volumeInfo['publishedDate'] ?? '',
      pageCount: volumeInfo['pageCount']?.toInt(),
      averageRating: volumeInfo['averageRating']?.toDouble(),
      ratingsCount: volumeInfo['ratingsCount']?.toInt(),
    );
  }

  String? _getBestImageUrl(Map<String, dynamic> imageLinks) {
    // Official Google Books API image sizes (in pixels):
    // extraLarge: ~1280px, large: ~800px, medium: ~575px, small: ~300px
    // thumbnail: ~128px, smallThumbnail: ~80px

    String? originalUrl =
        imageLinks['extraLarge'] ??
        imageLinks['large'] ??
        imageLinks['medium'] ??
        imageLinks['small'] ??
        imageLinks['thumbnail'] ??
        imageLinks['smallThumbnail'];

    if (originalUrl != null) {
      // Optimize the URL to get the biggest possible image
      String optimizedUrl = _optimizeImageUrl(originalUrl);
      return optimizedUrl;
    }

    return originalUrl;
  }

  String _optimizeImageUrl(String url) {
    // Based on Google Books API documentation and community best practices
    String optimizedUrl = url;

    // Remove width and height parameters that limit image size
    optimizedUrl = optimizedUrl.replaceAll(RegExp(r'&w=\d+'), '');
    optimizedUrl = optimizedUrl.replaceAll(RegExp(r'&h=\d+'), '');

    // Set zoom to 0 for maximum resolution (not 5!)
    // According to docs: zoom=0 gives highest resolution, zoom=1 is default
    if (optimizedUrl.contains('zoom=')) {
      optimizedUrl = optimizedUrl.replaceAll(RegExp(r'zoom=\d+'), 'zoom=0');
    } else {
      // Add zoom=0 if not present
      optimizedUrl += optimizedUrl.contains('?') ? '&zoom=0' : '?zoom=0';
    }

    // Remove edge=curl for cleaner images
    optimizedUrl = optimizedUrl.replaceAll('&edge=curl', '');

    // Add fife parameter to request larger image width
    // This is a documented way to get higher resolution images
    if (!optimizedUrl.contains('&fife=')) {
      optimizedUrl += '&fife=w800'; // Request 800px width for high quality
    }

    return optimizedUrl;
  }

  String? _getOptimizedImageUrl(
    Map<String, dynamic> imageLinks, {
    bool isForSearch = false,
  }) {
    if (isForSearch) {
      // For search results, use medium size for performance
      // Search results are smaller and don't need high resolution
      return _getSearchImageUrl(imageLinks);
    } else {
      // For user collection, use highest quality available
      return _getBestImageUrl(imageLinks);
    }
  }

  String? _getSearchImageUrl(Map<String, dynamic> imageLinks) {
    // For search results, prioritize medium size for performance
    // Official Google Books API image sizes: medium ~575px
    String? originalUrl =
        imageLinks['medium'] ??
        imageLinks['small'] ??
        imageLinks['thumbnail'] ??
        imageLinks['smallThumbnail'];

    if (originalUrl != null) {
      // Light optimization for search results
      return _optimizeSearchImageUrl(originalUrl);
    }

    return originalUrl;
  }

  String _optimizeSearchImageUrl(String url) {
    // Light optimization for search results
    String optimizedUrl = url;
    
    // Set zoom to 0 for better quality
    if (optimizedUrl.contains('zoom=')) {
      optimizedUrl = optimizedUrl.replaceAll(RegExp(r'zoom=\d+'), 'zoom=0');
    } else {
      optimizedUrl += optimizedUrl.contains('?') ? '&zoom=0' : '?zoom=0';
    }
    
    // Remove edge=curl for cleaner images
    optimizedUrl = optimizedUrl.replaceAll('&edge=curl', '');
    
    return optimizedUrl;
  }

  /// Upgrades a book's image quality using URL optimization
  BookEntity upgradeBookImageQuality(BookEntity book) {
    // Apply URL optimization to get the highest quality image
    if (book.thumbnailUrl != null) {
      final optimizedUrl = _optimizeImageUrl(book.thumbnailUrl!);
      return BookEntity(
        id: book.id,
        googleBooksId: book.googleBooksId,
        title: book.title,
        authors: book.authors,
        description: book.description,
        thumbnailUrl: optimizedUrl,
        publishedDate: book.publishedDate,
        pageCount: book.pageCount,
        readingProgress: book.readingProgress,
        averageRating: book.averageRating,
        ratingsCount: book.ratingsCount,
      );
    }
    return book;
  }
}
