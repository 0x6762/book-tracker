import '../../data/book_database.dart';
import '../../data/datasources/google_books_api_service.dart';
import '../../application/services/book_management_service.dart';
import '../../application/services/reading_progress_service.dart';
import '../../application/services/notification_service.dart';
import '../../application/services/timer_service.dart';
import '../../application/services/native_timer_service.dart';

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
  late final NotificationService _notificationService;
  late final TimerService _timerService;
  late final NativeTimerService _nativeTimerService;

  // Initialize all services
  Future<void> initialize() async {
    // Initialize core services
    _database = BookDatabase();
    _googleBooksApiService = GoogleBooksApiService();

    // Initialize application services
    _bookManagementService = BookManagementService(_database);
    _readingProgressService = ReadingProgressService(_database);
    _notificationService = NotificationService();
    _timerService = TimerService();
    _nativeTimerService = NativeTimerService();

    // Initialize notification service
    await _notificationService.initialize();
  }

  // Getters for services
  BookDatabase get database => _database;
  GoogleBooksApiService get googleBooksApiService => _googleBooksApiService;
  BookManagementService get bookManagementService => _bookManagementService;
  ReadingProgressService get readingProgressService => _readingProgressService;
  NotificationService get notificationService => _notificationService;
  TimerService get timerService => _timerService;
  NativeTimerService get nativeTimerService => _nativeTimerService;
}
