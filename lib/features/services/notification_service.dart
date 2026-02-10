import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📱 Background message received: ${message.messageId}');
  // Handle background message here
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) {
      print('📱 NotificationService already initialized');
      return;
    }

    try {
      // Request notification permissions
      await _requestPermissions();

      // Initialize local notifications (with error handling)
      try {
        await _initializeLocalNotifications();
      } catch (e) {
        print('⚠️ Warning: Local notifications initialization failed: $e');
        print('💡 This usually means you need to rebuild the app after adding the plugin.');
        print('💡 Run: flutter clean && flutter pub get && flutter run');
        // Continue with FCM setup even if local notifications fail
      }

      // Configure Firebase Cloud Messaging
      await _configureFCM();

      // Get FCM token
      await _getFCMToken();

      _initialized = true;
      print('✅ NotificationService initialized successfully');
    } catch (e, stackTrace) {
      print('❌ Error initializing NotificationService: $e');
      print('Stack trace: $stackTrace');
      // Don't throw - allow app to continue without notifications
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      // Request permission for iOS
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('📱 iOS notification permission: ${settings.authorizationStatus}');
    } else {
      // Request permission for Android 13+
      final status = await Permission.notification.status;
      if (status.isDenied) {
        final result = await Permission.notification.request();
        print('📱 Android notification permission: $result');
      } else {
        print('📱 Android notification permission: $status');
      }
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    try {
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized != true) {
        throw Exception('Failed to initialize local notifications plugin');
      }

      // Create notification channels for Android
      if (Platform.isAndroid) {
        await _createAndroidChannels();
      }

    } catch (e) {
      print('❌ Error initializing local notifications: $e');
      rethrow; // Re-throw to be caught by outer try-catch
    }
  }

  /// Create Android notification channels
  Future<void> _createAndroidChannels() async {
    // Default channel for general notifications
    const defaultChannel = AndroidNotificationChannel(
      'loyalty_default',
      'Loyalty Notifications',
      description: 'General notifications about your loyalty rewards',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Rewards channel
    const rewardsChannel = AndroidNotificationChannel(
      'loyalty_rewards',
      'Rewards & Offers',
      description: 'Notifications about new rewards and special offers',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Stamps channel
    const stampsChannel = AndroidNotificationChannel(
      'loyalty_stamps',
      'Stamp Updates',
      description: 'Notifications about your stamp collection progress',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: false,
    );

    // Create channels
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(defaultChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(rewardsChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(stampsChannel);

    print('✅ Android notification channels created');
  }

  /// Configure Firebase Cloud Messaging
  Future<void> _configureFCM() async {
    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📱 Foreground message received: ${message.messageId}');

    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('📱 Notification tapped: ${message.messageId}');
    // Handle navigation or action based on notification data
    final data = message.data;
    if (data.containsKey('type')) {
      // Handle different notification types
      switch (data['type']) {
        case 'reward':
          // Navigate to rewards screen
          break;
        case 'stamp':
          // Navigate to stamps screen
          break;
        default:
          // Navigate to home
          break;
      }
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification == null) return;

      // Determine channel based on notification data
      String channelId = 'loyalty_default';
      if (message.data.containsKey('channel')) {
        channelId = message.data['channel'] as String;
      }

      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        details,
        payload: message.data.toString(),
      );
    } catch (e) {
      print('❌ Error showing local notification: $e');
      // Don't throw - fail silently
    }
  }

  /// Get channel name by ID
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'loyalty_rewards':
        return 'Rewards & Offers';
      case 'loyalty_stamps':
        return 'Stamp Updates';
      default:
        return 'Loyalty Notifications';
    }
  }

  /// Get channel description by ID
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'loyalty_rewards':
        return 'Notifications about new rewards and special offers';
      case 'loyalty_stamps':
        return 'Notifications about your stamp collection progress';
      default:
        return 'General notifications about your loyalty rewards';
    }
  }

  /// Handle notification tap from local notifications
  void _onNotificationTapped(NotificationResponse response) {
    print('📱 Local notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('📱 FCM Token: $_fcmToken');

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        print('📱 FCM Token refreshed: $newToken');
        // Send token to your backend
      });
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic $topic: $e');
    }
  }

  /// Show a local notification manually
  Future<void> showNotification({
    required String title,
    required String body,
    String channelId = 'loyalty_default',
    Map<String, dynamic>? data,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: data?.toString(),
      );
    } catch (e) {
      print('❌ Error showing notification: $e');
      // Don't throw - fail silently
    }
  }
}
