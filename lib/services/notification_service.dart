import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  /// Initialize awesome_notifications
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // default app icon
      [
        NotificationChannel(
          channelKey: 'new_order',
          channelName: 'New Order',
          channelDescription: 'Notify when a new order arrives',
          defaultColor: const Color(0xFFFFD700),
          ledColor: const Color(0xFFFFD700),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
        ),
        NotificationChannel(
          channelKey: 'order_status',
          channelName: 'Order Status',
          channelDescription: 'Order acceptance/completion updates',
          defaultColor: const Color(0xFF4CAF50),
          ledColor: const Color(0xFF4CAF50),
          importance: NotificationImportance.Default,
        ),
      ],
    );
  }

  /// Request notification permissions (Android 13+)
  static Future<bool> requestPermissions() async {
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return await AwesomeNotifications().isNotificationAllowed();
  }

  /// Show notification when a new order arrives
  static Future<void> showNewOrderNotification({
    required String orderId,
    required String passengerName,
    required String pickupAddress,
  }) async {
    await AwesomeNotifications().createNotification(
      NotificationContent(
        id: orderId.hashCode & 0x7FFFFFFF,
        channelKey: 'new_order',
        title: 'New Order Received!',
        body: '$passengerName - $pickupAddress',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
      ),
    );
  }

  /// Show notification when order is accepted
  static Future<void> showOrderAcceptedNotification({
    required String orderId,
    required String passengerName,
  }) async {
    await AwesomeNotifications().createNotification(
      NotificationContent(
        id: orderId.hashCode & 0x7FFFFFFF,
        channelKey: 'order_status',
        title: 'Order Accepted',
        body: 'You accepted $passengerName\'s order',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  /// Show a simple notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String channelKey = 'order_status',
  }) async {
    await AwesomeNotifications().createNotification(
      NotificationContent(
        id: title.hashCode & 0x7FFFFFFF,
        channelKey: channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  /// Set up action stream listener for notification taps
  static Stream<ReceivedAction> get actionStream =>
      AwesomeNotifications().actionStream;

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}
