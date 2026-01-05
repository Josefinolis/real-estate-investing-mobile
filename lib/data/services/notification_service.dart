import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  FirebaseMessaging? _messaging;
  bool _initialized = false;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  bool get isAvailable => _initialized;

  Future<void> initialize() async {
    try {
      _messaging = FirebaseMessaging.instance;
    } catch (e) {
      debugPrint('🔔 [NOTIFICATION] Firebase Messaging not available: $e');
      return;
    }

    // Request permission
    final settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('🔔 [NOTIFICATION] User granted notification permission');

      // Get FCM token
      _fcmToken = await _messaging!.getToken();
      debugPrint('🔔 [NOTIFICATION] FCM Token: $_fcmToken');

      // Listen for token refresh
      _messaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('🔔 [NOTIFICATION] FCM Token refreshed: $newToken');
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Check if app was opened from notification
      final initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      _initialized = true;
      debugPrint('🔔 [NOTIFICATION] Service initialized successfully');
    } else {
      debugPrint('🔔 [NOTIFICATION] User declined notification permission');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // You can show a local notification here or update the UI
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.messageId}');
    debugPrint('Data: ${message.data}');

    // Handle navigation based on message data
    final type = message.data['type'];
    final propertyId = message.data['propertyId'];

    if (type == 'new_property' && propertyId != null) {
      // Navigate to property detail
      debugPrint('Should navigate to property: $propertyId');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    if (_messaging != null) {
      await _messaging!.subscribeToTopic(topic);
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (_messaging != null) {
      await _messaging!.unsubscribeFromTopic(topic);
    }
  }
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Received background message: ${message.messageId}');
}
