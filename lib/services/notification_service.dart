import 'package:flutter/material.dart';

/// Lightweight notification service using in-app overlay banners.
/// No platform plugin needed - works reliably on all Flutter versions.
class NotificationService {
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  static bool _initialized = false;

  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  /// Initialize the notification service
  static Future<void> initialize() async {
    _initialized = true;
  }

  /// Request notification permissions (no-op for in-app notifications)
  static Future<bool> requestPermissions() async {
    return true;
  }

  /// Show an in-app notification banner
  static void showInAppBanner({
    required String title,
    required String body,
    Color? color,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    final context = _navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: GestureDetector(
              onTap: () {
                overlayEntry.remove();
                onTap?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color ?? const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.black87, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            body,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.close, color: Colors.black38, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// Show notification when a new order arrives
  static void showNewOrderNotification({
    required String orderId,
    required String passengerName,
    required String pickupAddress,
  }) {
    showInAppBanner(
      title: '🚕 New Order!',
      body: '$passengerName - $pickupAddress',
      color: Colors.green,
      onTap: () {
        debugPrint('Tapped new order notification: $orderId');
      },
    );
  }

  /// Show notification when order is accepted
  static void showOrderAcceptedNotification({
    required String orderId,
    required String passengerName,
  }) {
    showInAppBanner(
      title: '✅ Order Accepted',
      body: "You accepted $passengerName's order",
      color: Colors.blue,
    );
  }

  /// Show a simple notification
  static void showNotification({
    required String title,
    required String body,
  }) {
    showInAppBanner(title: title, body: body);
  }

  /// Cancel all notifications (no-op for in-app)
  static void cancelAllNotifications() {
    // In-app banners auto-dismiss
  }
}
