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
    // Try highest resolution images first, fallback to smaller ones
    String? originalUrl =
        imageLinks['extraLarge'] ??
        imageLinks['large'] ??
        imageLinks['medium'] ??
        imageLinks['thumbnail'] ??
        imageLinks['smallThumbnail'];

    // Optimize the image URL for better quality
    if (originalUrl != null) {
      String optimizedUrl = originalUrl;

      // Replace zoom=1 with zoom=0 for higher quality (undocumented but works)
      optimizedUrl = optimizedUrl.replaceAll('zoom=1', 'zoom=0');
      // Remove any size restrictions for maximum quality
      optimizedUrl = optimizedUrl.replaceAll(RegExp(r'&w=\d+'), '');
      optimizedUrl = optimizedUrl.replaceAll(RegExp(r'&h=\d+'), '');

      return optimizedUrl;
    }

    return originalUrl;
  }

  String? _getOptimizedImageUrl(
    Map<String, dynamic> imageLinks, {
    bool isForSearch = false,
  }) {
    // For search results, use smaller images for better performance
    if (isForSearch) {
      // Search results: prioritize medium (400px) for 67.5px display
      String? originalUrl =
          imageLinks['medium'] ??
          imageLinks['thumbnail'] ??
          imageLinks['smallThumbnail'] ??
          imageLinks['large'] ??
          imageLinks['extraLarge'];

      return originalUrl;
    } else {
      // Book details: use highest quality available
      return _getBestImageUrl(imageLinks);
    }
  }

  /// Upgrades a book's image quality from search quality to high quality
  BookEntity upgradeBookImageQuality(BookEntity book) {
    // This method assumes the book was created from search results
    // and we want to upgrade it to high quality for the user's collection
    return BookEntity(
      googleBooksId: book.googleBooksId,
      title: book.title,
      authors: book.authors,
      description: book.description,
      thumbnailUrl: _getBestImageUrl(
        _extractImageLinksFromUrl(book.thumbnailUrl),
      ),
      publishedDate: book.publishedDate,
      pageCount: book.pageCount,
      averageRating: book.averageRating,
      ratingsCount: book.ratingsCount,
    );
  }

  Map<String, dynamic> _extractImageLinksFromUrl(String? thumbnailUrl) {
    // Since we don't have the original imageLinks, we'll create a fallback
    // that prioritizes higher quality images
    if (thumbnailUrl == null) return {};

    // If the URL contains 'medium' or smaller, we know we can upgrade
    if (thumbnailUrl.contains('medium') ||
        thumbnailUrl.contains('thumbnail') ||
        thumbnailUrl.contains('smallThumbnail')) {
      // Return a map that will trigger the high-quality selection
      return {
        'extraLarge': thumbnailUrl.replaceAll(
          RegExp(r'(medium|thumbnail|smallThumbnail)'),
          'extraLarge',
        ),
        'large': thumbnailUrl.replaceAll(
          RegExp(r'(medium|thumbnail|smallThumbnail)'),
          'large',
        ),
        'medium': thumbnailUrl,
        'thumbnail': thumbnailUrl,
        'smallThumbnail': thumbnailUrl,
      };
    }

    // If it's already high quality, return as is
    return {'extraLarge': thumbnailUrl};
  }
}
