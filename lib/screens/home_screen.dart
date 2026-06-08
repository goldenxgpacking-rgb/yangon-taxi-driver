import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'login_screen.dart';
import 'order_center_screen.dart';
import 'earnings_screen.dart';
import 'trip_history_screen.dart';
import 'driver_profile_screen.dart';
import '../services/earnings_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnline = false;
  String _currentAddress = 'Getting location...';
  double _todayEarnings = 0.0;
  int _todayOrders = 0;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _currentAddress = 'Yangon, Myanmar (16.8661, 96.1951)';
      _isLoadingLocation = false;
    });
  }

  void _toggleOnlineStatus() async {
    if (!_isOnline) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OrderCenterScreen(),
        ),
      );
      setState(() {
        _isOnline = true;
      });
    } else {
      setState(() {
        _isOnline = false;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isOnline ? 'You are now ONLINE' : 'You are now OFFLINE',
        ),
        backgroundColor: _isOnline ? Colors.green : Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFFFD700)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Yangon Taxi Driver',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFFFFD700)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _toggleOnlineStatus,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isOnline
                          ? [
                              Colors.green.withOpacity(0.3),
                              Colors.green.withOpacity(0.1),
                            ]
                          : [
                              Colors.grey[800]!.withOpacity(0.3),
                              Colors.grey[900]!.withOpacity(0.1),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isOnline ? Colors.green : Colors.grey[700]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isOnline ? Icons.wifi_tethering : Icons.wifi_off,
                        size: 60,
                        color: _isOnline ? Colors.green : Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isOnline ? 'ONLINE' : 'OFFLINE',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _isOnline ? Colors.green : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isOnline ? 'You are receiving orders' : 'Tap to go online',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.account_balance_wallet,
                      title: "Today's Earnings",
                      value: 'Ks ${_todayEarnings.toStringAsFixed(0)}',
                      color: const Color(0xFFFFD700),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EarningsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.list_alt,
                      title: 'Orders',
                      value: '$_todayOrders',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderCenterScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickButton(
                    icon: Icons.list_alt,
                    label: 'Order Center',
                    color: const Color(0xFFFFD700),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderCenterScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickButton(
                    icon: Icons.bar_chart,
                    label: 'Earnings',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EarningsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Drive safely. Stay online to receive orders.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white38,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2A2A3E),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFFFD700),
                  child: Icon(Icons.person, color: Colors.black, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  'Driver Name',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '09-123456789',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            label: 'Home',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.list_alt,
            label: 'Order Center',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderCenterScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.history,
            label: 'Trip History',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TripHistoryScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.bar_chart,
            label: 'Earnings',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EarningsScreen(),
                ),
              );
            },
          ),
          const Divider(color: Colors.white10),
          _buildDrawerItem(
            context,
            icon: Icons.person_outline,
            label: 'Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DriverProfileScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.chat_bubble,
            label: 'Messages',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/messages');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.account_balance_wallet,
            label: 'Wallet',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/wallet');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            label: 'Settings',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const Divider(color: Colors.white10),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            label: 'Logout',
            color: Colors.redAccent,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white70, size: 22),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: color ?? Colors.white70,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      minLeadingWidth: 0,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 4,
      ),
    );
  }

  Widget _buildQuickButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(height: 4),
              Text(
                'Tap to view',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white24,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
