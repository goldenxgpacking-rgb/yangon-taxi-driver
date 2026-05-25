import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YangonTaxiDriverApp());
}

class YangonTaxiDriverApp extends StatelessWidget {
  const YangonTaxiDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yangon Taxi Driver',
      debugShowCheckedModeBanner: false,
      
      // Theme Configuration (Yangon Gold + Deep Blue Black)
      theme: ThemeData(
        primaryColor: const Color(0xFFFFD700), // Yangon Gold
        scaffoldBackgroundColor: const Color(0xFF1A1A2E), // Deep Blue Black
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD700),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        useMaterial3: true,
      ),
      
      // Routes
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
