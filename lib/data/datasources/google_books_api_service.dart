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
    // Try large resolution first for user's collection, fallback to smaller ones
    String? originalUrl =
        imageLinks['large'] ??
        imageLinks['medium'] ??
        imageLinks['thumbnail'] ??
        imageLinks['smallThumbnail'] ??
        imageLinks['extraLarge'];

    // Return the raw URL without optimization
    return originalUrl;
  }

  String? _getOptimizedImageUrl(
    Map<String, dynamic> imageLinks, {
    bool isForSearch = false,
  }) {
    // Both search and collection now use the same large priority
    return _getBestImageUrl(imageLinks);
  }

  /// Upgrades a book's image quality (now just returns the original since both use large)
  BookEntity upgradeBookImageQuality(BookEntity book) {
    // Since both search and collection now use the same large priority,
    // no upgrade is needed - just return the original book
    return book;
  }
}
