import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/home_screen.dart';
import 'screens/order_center_screen.dart';
import 'screens/ride_in_progress_screen.dart';
import 'screens/trip_completed_screen.dart';
import 'screens/earnings_screen.dart';
import 'screens/trip_history_screen.dart';
import 'screens/driver_profile_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/withdraw_screen.dart';
import 'screens/settings_screen.dart';
import 'services/notification_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await NotificationService.requestPermissions();
  runApp(const YangonTaxiDriverApp());
}

/// Handle notification taps when app is in foreground
@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  // Navigate based on notification payload
  // This is a static callback for awesome_notifications
}

class YangonTaxiDriverApp extends StatelessWidget {
  const YangonTaxiDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yangon Taxi Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFFD700),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD700),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/otp': (context) => const OTPScreen(phoneNumber: '+95 9123456789'),
        '/home': (context) => const HomeScreen(),
        '/order-center': (context) => const OrderCenterScreen(),
        '/ride-in-progress': (context) => const RideInProgressScreen(
          passengerName: 'Aung Aung',
          pickupAddress: 'Sule Square, Yangon',
          destinationAddress: 'Yangon International Airport',
        ),
        '/trip-completed': (context) => const TripCompletedScreen(
          passengerName: 'Aung Aung',
          destinationAddress: 'Yangon International Airport',
        ),
        '/earnings': (context) => const EarningsScreen(),
        '/trip-history': (context) => const TripHistoryScreen(),
        '/profile': (context) => const DriverProfileScreen(),
        '/messages': (context) => const MessagesScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
