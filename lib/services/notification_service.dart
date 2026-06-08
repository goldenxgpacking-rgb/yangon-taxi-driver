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
        title: '🚕 New Order Received!',
        body: '$passengerName · $pickupAddress',
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

  /// Listen for notification tap events
  static void setNotificationTapListener(
    void Function(ReceivedNotification notification) onTap,
  ) {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (receivedNotification) async {
        onTap(receivedNotification as ReceivedNotification);
      },
    );
  }
}
