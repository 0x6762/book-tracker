import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../data/simple_database.dart';
import '../../data/datasources/google_books_api_service.dart';
import '../../domain/entities/book.dart';

class BookProvider with ChangeNotifier {
  final SimpleDatabase _database = SimpleDatabase();
  final GoogleBooksApiService _apiService = GoogleBooksApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  List<BookEntity> _books = [];
  List<BookEntity> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  // Timer state
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isTimerRunning = false;
  int? _currentBookId;

  // Notification state
  Timer? _notificationTimer;
  int _notificationId = 1;

  List<BookEntity> get books => _books;
  List<BookEntity> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;

  // Timer getters
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  bool get isTimerRunning => _isTimerRunning;
  int? get currentBookId => _currentBookId;
  bool get isTimerCompleted => _remainingSeconds <= 0 && _totalSeconds > 0;

  String get formattedTime {
    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Future<void> loadBooks() async {
    _setLoading(true);
    try {
      print('🔄 Loading books...');
      final stopwatch = Stopwatch()..start();

      final dbBooks = await _database.getAllBooks();
      _books = dbBooks.map((book) => book.toEntity()).toList();

      stopwatch.stop();
      print(
        '📚 Loaded ${_books.length} books in ${stopwatch.elapsedMilliseconds}ms',
      );
      _error = null;
    } catch (e) {
      print('❌ Error loading books: $e');
      _error = 'Failed to load books: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addBook(BookEntity book) async {
    try {
      // Check if book already exists
      final exists = await _database.bookExists(book.googleBooksId);
      if (exists) {
        _error = 'Book already exists in your library';
        notifyListeners();
        return;
      }

      // Upgrade image quality for user's collection
      final upgradedBook = await _upgradeBookImageQuality(book);
      await _database.insertBook(upgradedBook.toCompanion());
      await loadBooks(); // Refresh list
    } catch (e) {
      _error = 'Failed to add book: $e';
      notifyListeners();
    }
  }

  Future<BookEntity> _upgradeBookImageQuality(BookEntity book) async {
    try {
      // Upgrade image quality without additional API call
      return _apiService.upgradeBookImageQuality(book);
    } catch (e) {
      // If upgrade fails, return original book
      print('⚠️ Failed to upgrade image quality: $e');
      return book;
    }
  }

  Future<void> deleteBook(int id) async {
    try {
      await _database.deleteBook(id);
      await loadBooks(); // Refresh list
    } catch (e) {
      _error = 'Failed to delete book: $e';
      notifyListeners();
    }
  }

  Future<void> updateProgress(int bookId, int currentPage) async {
    try {
      // Check if book has reading progress
      final book = _books.firstWhere((b) => b.id == bookId);

      if (book.readingProgress == null) {
        // Start reading
        await _database.startReading(bookId, currentPage);
      } else {
        // Update progress
        await _database.updateProgress(bookId, currentPage);
      }

      await loadBooks(); // Refresh list
    } catch (e) {
      _error = 'Failed to update progress: $e';
      notifyListeners();
    }
  }

  Future<void> completeReading(int bookId) async {
    try {
      await _database.completeReading(bookId);
      await loadBooks(); // Refresh list
    } catch (e) {
      _error = 'Failed to complete reading: $e';
      notifyListeners();
    }
  }

  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    if (query.trim().length < 3) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _setSearching(true);
    try {
      _searchResults = await _apiService.searchBooks(query);
      _error = null;
    } catch (e) {
      _error = 'Failed to search books: $e';
    } finally {
      _setSearching(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Timer methods
  void setTimer(int bookId, int minutes) {
    stopTimer(); // Stop any existing timer

    _currentBookId = bookId;
    // Special case: 0 minutes = 5 seconds for testing
    _totalSeconds = minutes == 0 ? 5 : minutes * 60;
    _remainingSeconds = _totalSeconds;
    _isTimerRunning = false;
    notifyListeners();
  }

  void startTimer(int bookId) async {
    if (_isTimerRunning && _currentBookId == bookId) {
      return; // Already running for this book
    }

    if (_remainingSeconds <= 0) {
      return; // No time left
    }

    // Ensure permissions are granted before starting timer
    await _ensureNotificationPermissions();

    _isTimerRunning = true;
    _currentBookId = bookId;

    // Schedule notification for timer completion
    _scheduleTimerNotification(_totalSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        // Timer completed
        _timer?.cancel();
        _timer = null;
        _isTimerRunning = false;
        notifyListeners();
        _showTimerCompletedNotification();
      }
    });

    notifyListeners();
  }

  void stopTimer() {
    // Prevent multiple calls
    if (_currentBookId == null && _totalSeconds == 0) {
      return;
    }

    // Cancel notification
    _cancelTimerNotification();

    // Add elapsed time to book before stopping
    if (_currentBookId != null && _totalSeconds > 0) {
      final elapsedSeconds = _totalSeconds - _remainingSeconds;
      final elapsedMinutes = elapsedSeconds ~/ 60;
      if (elapsedMinutes > 0) {
        _database.addReadingTime(_currentBookId!, elapsedMinutes);
        print(
          '📚 Added $elapsedMinutes minutes to book $_currentBookId (stopped early)',
        );
      }
      // Always trigger page update modal for stopped timer (even if 0 minutes)
      _shouldShowPageUpdateModal = true;
    }

    _timer?.cancel();
    _timer = null;
    _isTimerRunning = false;
    // Keep timer values until modal is dismissed
    notifyListeners();
  }

  void pauseTimer() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
      _isTimerRunning = false;
      notifyListeners();
    }
  }

  void resumeTimer() {
    if (!_isTimerRunning && _currentBookId != null && _remainingSeconds > 0) {
      _isTimerRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          notifyListeners();
        } else {
          // Timer completed
          _timer?.cancel();
          _timer = null;
          _isTimerRunning = false;
          notifyListeners();
          _showTimerCompletedNotification();
        }
      });
      notifyListeners();
    }
  }

  void _showTimerCompletedNotification() {
    // This will be handled by the UI to show a notification
    print('⏰ Reading session completed!');
    // Play alarm sound
    _playAlarmSound();
    // Add reading time to the book's total
    _addReadingTimeToBook();
    // Trigger page update modal after timer completion
    _shouldShowPageUpdateModal = true;
    // Also show a completion notification
    _showCompletionNotification();
    notifyListeners();
  }

  void _playAlarmSound() async {
    // For now, we'll rely on the notification sound
    // The notification itself will play a sound when it appears
    print('🔔 Timer completed! Notification sound will play');
  }

  // Schedule notification for timer completion
  void _scheduleTimerNotification(int totalSeconds) async {
    try {
      final endTime = tz.TZDateTime.now(
        tz.local,
      ).add(Duration(seconds: totalSeconds));
      // Schedule the completion notification
      await _notifications.zonedSchedule(
        _notificationId,
        'Reading Session Complete!',
        'Your reading timer has finished. Tap to update your progress.',
        endTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reading_timer',
            'Reading Timer',
            channelDescription: 'Notifications for reading timer completion',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // Start updating notification every 5 minutes
      _startNotificationUpdates(totalSeconds);
    } catch (e) {
      print('⚠️ Could not schedule exact alarm notification: $e');
      print('📱 Notifications will work but may not be exact timing');
      // Fallback: Show immediate notification and schedule a simple one
      print('🔔 Showing fallback notification for timer start');
      try {
        await _notifications.show(
          _notificationId,
          'Reading Timer Started',
          'Timer is running. Check back when done!',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'reading_timer',
              'Reading Timer',
              channelDescription: 'Notifications for reading timer',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/launcher_icon',
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
            ),
          ),
        );
        print('🔔 Timer start notification sent successfully');
      } catch (e) {
        print('❌ Timer start notification failed: $e');
      }

      // Also schedule a simple notification for completion
      _scheduleSimpleNotification(totalSeconds);
    }
  }

  // Update notification every 5 minutes
  void _startNotificationUpdates(int totalSeconds) {
    _notificationTimer?.cancel();

    _notificationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      final remainingMinutes = _remainingSeconds ~/ 60;

      if (remainingMinutes > 0) {
        _updateTimerNotification(remainingMinutes);
      } else {
        timer.cancel();
      }
    });
  }

  // Update the notification with remaining time
  void _updateTimerNotification(int remainingMinutes) async {
    await _notifications.show(
      _notificationId,
      'Reading Timer',
      '$remainingMinutes minutes remaining',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reading_timer',
          'Reading Timer',
          channelDescription: 'Notifications for reading timer updates',
          importance: Importance.low,
          priority: Priority.low,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: false,
        ),
      ),
    );
  }

  // Cancel timer notification
  void _cancelTimerNotification() async {
    await _notifications.cancel(_notificationId);
    _notificationTimer?.cancel();
  }

  void _addReadingTimeToBook() {
    if (_currentBookId != null && _totalSeconds > 0) {
      final sessionMinutes = _totalSeconds ~/ 60;
      if (sessionMinutes > 0) {
        _database.addReadingTime(_currentBookId!, sessionMinutes);
        print('📚 Added $sessionMinutes minutes to book $_currentBookId');
      }
    }
  }

  // Flag to trigger page update modal
  bool _shouldShowPageUpdateModal = false;
  bool get shouldShowPageUpdateModal => _shouldShowPageUpdateModal;

  void clearPageUpdateModalFlag() {
    _shouldShowPageUpdateModal = false;
    notifyListeners();
  }

  void clearCurrentBook() {
    _currentBookId = null;
    _remainingSeconds = 0;
    _totalSeconds = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notificationTimer?.cancel();
    super.dispose();
  }

  // Initialize notifications
  Future<void> initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Request notification permissions
    await _requestNotificationPermissions();
  }

  // Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    try {
      // Request basic notification permissions
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        // Request notification permission
        final notificationPermission = await androidPlugin
            .requestNotificationsPermission();
        print('🔔 Notification permission granted: $notificationPermission');

        // Request exact alarm permission for Android 12+
        final exactAlarmPermission = await androidPlugin
            .requestExactAlarmsPermission();
        print('🔔 Exact alarm permission granted: $exactAlarmPermission');
      }
    } catch (e) {
      print('❌ Error requesting permissions: $e');
    }
  }

  // Ensure notification permissions are granted
  Future<void> _ensureNotificationPermissions() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        // Check if we have notification permission
        final hasPermission = await androidPlugin.areNotificationsEnabled();
        print('🔔 Notifications enabled: $hasPermission');

        if (hasPermission == false) {
          print('🔔 Requesting notification permission...');
          await androidPlugin.requestNotificationsPermission();
        }
      }
    } catch (e) {
      print('❌ Error checking/requesting permissions: $e');
    }
  }

  // Public method to manually request permissions (can be called from UI)
  Future<void> requestNotificationPermissions() async {
    await _requestNotificationPermissions();
  }

  // Test notification method (for debugging)
  Future<void> testNotification() async {
    try {
      await _notifications.show(
        999,
        'Test Notification',
        'If you see this, notifications are working!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Notifications',
            channelDescription: 'Test notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
          ),
        ),
      );
      print('🔔 Test notification sent successfully');
    } catch (e) {
      print('❌ Test notification failed: $e');
    }
  }

  // Schedule a simple notification for completion (fallback)
  void _scheduleSimpleNotification(int totalSeconds) {
    // Schedule notification to show when timer should complete
    Timer(Duration(seconds: totalSeconds), () {
      _showCompletionNotification();
    });
  }

  // Show timer start notification
  void _showTimerStartNotification() async {
    try {
      await _notifications.show(
        777, // Use a unique ID for start notifications
        'Reading Timer Started',
        'Timer is running. Check back when done!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reading_timer_start',
            'Reading Timer Start',
            channelDescription: 'Notifications for reading timer start',
            importance: Importance.low,
            priority: Priority.low,
            silent: true,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
            sound: null,
          ),
        ),
      );
    } catch (e) {
      print('❌ Timer start notification failed: $e');
    }
  }

  // Show completion notification
  void _showCompletionNotification() async {
    try {
      await _notifications.show(
        888, // Use a unique ID for completion notifications
        'Reading Session Complete!',
        'Your reading timer has finished. Tap to update your progress.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reading_timer_complete',
            'Reading Timer Complete',
            channelDescription: 'Notifications for reading timer completion',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
          ),
        ),
      );
    } catch (e) {
      print('❌ Completion notification failed: $e');
    }
  }
}
