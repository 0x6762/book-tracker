import '../../data/book_database.dart';
import '../../data/datasources/google_books_api_service.dart';
import '../../application/services/book_management_service.dart';
import '../../application/services/reading_progress_service.dart';
import '../../application/services/color_extraction_service.dart';
import '../../application/services/notification_service.dart';
import '../../application/services/timer_service.dart';
import '../../application/services/reading_timer_service.dart';

/// Simple service locator for dependency injection
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Core services
  late final BookDatabase _database;
  late final GoogleBooksApiService _googleBooksApiService;

  // Application services
  late final BookManagementService _bookManagementService;
  late final ReadingProgressService _readingProgressService;
  late final ColorExtractionService _colorExtractionService;
  late final NotificationService _notificationService;
  late final TimerService _timerService;
  late final ReadingTimerService _readingTimerService;

  // Initialize all services
  Future<void> initialize() async {
    // Initialize core services
    _database = BookDatabase();
    _googleBooksApiService = GoogleBooksApiService();

    // Initialize application services
    _bookManagementService = BookManagementService(_database);
    _readingProgressService = ReadingProgressService(_database);
    _colorExtractionService = ColorExtractionService(_database);
    _notificationService = NotificationService();
    _timerService = TimerService();
    _readingTimerService = ReadingTimerService();

    // Initialize notification service
    await _notificationService.initialize();
  }

  // Getters for services
  BookDatabase get database => _database;
  GoogleBooksApiService get googleBooksApiService => _googleBooksApiService;
  BookManagementService get bookManagementService => _bookManagementService;
  ReadingProgressService get readingProgressService => _readingProgressService;
  ColorExtractionService get colorExtractionService => _colorExtractionService;
  NotificationService get notificationService => _notificationService;
  TimerService get timerService => _timerService;
  ReadingTimerService get readingTimerService => _readingTimerService;
}
