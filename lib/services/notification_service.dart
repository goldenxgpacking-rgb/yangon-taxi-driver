import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification service using flutter_local_notifications.
/// Simple, reliable, no complex setup required.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize the notification plugin
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    _initialized = true;
  }

  /// Request notification permissions (Android 13+)
  static Future<bool> requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      return await androidPlugin.requestNotificationsPermission() ?? false;
    }
    return true;
  }

  /// Show notification when a new order arrives
  static Future<void> showNewOrderNotification({
    required String orderId,
    required String passengerName,
    required String pickupAddress,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'new_order',
      'New Order',
      channelDescription: 'Notify when a new order arrives',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFFFD700),
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      orderId.hashCode & 0x7FFFFFFF,
      'New Order Received!',
      '$passengerName - $pickupAddress',
      notificationDetails,
      payload: orderId,
    );
  }

  /// Show notification when order is accepted
  static Future<void> showOrderAcceptedNotification({
    required String orderId,
    required String passengerName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'order_status',
      'Order Status',
      channelDescription: 'Order acceptance/completion updates',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      orderId.hashCode & 0x7FFFFFFF,
      'Order Accepted',
      'You accepted $passengerName\'s order',
      notificationDetails,
      payload: orderId,
    );
  }

  /// Show a simple notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String channelKey = 'order_status',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelKey,
      channelKey == 'new_order' ? 'New Order' : 'Order Status',
      channelDescription: 'App notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      title.hashCode & 0x7FFFFFFF,
      title,
      body,
      notificationDetails,
    );
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
