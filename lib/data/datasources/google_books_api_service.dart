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
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(
          'Google Books API key not found. Please check your .env file.',
        );
      }

      // Validate API key format (basic check)
      if (apiKey == 'your_api_key_here' || apiKey.length < 20) {
        throw Exception(
          'Invalid API key. Please set a valid Google Books API key in your .env file.',
        );
      }

      final response = await _dio.get(
        '/volumes',
        queryParameters: {'q': query, 'key': apiKey, 'maxResults': 20},
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['items'] ?? [];
        return items.map((item) => _mapToBookEntity(item)).toList();
      } else {
        throw Exception('Failed to search books: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('API key is invalid or quota exceeded');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid search query');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  BookEntity _mapToBookEntity(Map<String, dynamic> item) {
    final volumeInfo = item['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};

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
      thumbnailUrl: imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'],
      publishedDate: volumeInfo['publishedDate'] ?? '',
      pageCount: volumeInfo['pageCount']?.toInt(),
    );
  }
}
