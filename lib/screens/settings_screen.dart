import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _autoAccept = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          _buildSectionHeader('Language', Icons.language),
          const SizedBox(height: 8),
          _buildLanguageCard(),
          const SizedBox(height: 24),

          // Notification Settings
          _buildSectionHeader('Notifications', Icons.notifications_outlined),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSwitchTile(
              icon: Icons.notifications_active,
              title: 'Push Notifications',
              subtitle: 'Receive new order alerts',
              value: _pushNotifications,
              onChanged: (v) => setState(() => _pushNotifications = v),
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.volume_up,
              title: 'Sound',
              subtitle: 'Play sound for new orders',
              value: _soundEnabled,
              onChanged: (v) => setState(() => _soundEnabled = v),
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.vibration,
              title: 'Vibration',
              subtitle: 'Vibrate on new order alerts',
              value: _vibrationEnabled,
              onChanged: (v) => setState(() => _vibrationEnabled = v),
            ),
          ]),
          const SizedBox(height: 24),

          // Ride Preferences
          _buildSectionHeader('Ride Preferences', Icons.local_taxi),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSwitchTile(
              icon: Icons.autorenew,
              title: 'Auto-Accept Orders',
              subtitle: 'Automatically accept nearby orders',
              value: _autoAccept,
              onChanged: (v) => setState(() => _autoAccept = v),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.tune,
              title: 'Maximum Ride Distance',
              subtitle: '50 km',
              onTap: () {
                _showDistancePicker();
              },
            ),
          ]),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About', Icons.info_outline),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildInfoTile(
              icon: Icons.info,
              title: 'App Version',
              subtitle: '1.0.0 (Build 44)',
            ),
            _buildDivider(),
            _buildInfoTile(
              icon: Icons.code,
              title: 'Built With',
              subtitle: 'Flutter 3.x',
            ),
          ]),
          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: Text(
                'Log Out',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _buildLanguageOption('English', 'English (Default)', isSelected: true),
          _buildDivider(),
          _buildLanguageOption('Myanmar', 'italian', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String lang, String desc, {bool isSelected = false}) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700).withOpacity(0.2)
              : Colors.white10,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            lang == 'English' ? 'EN' : 'MM',
            style: GoogleFonts.poppins(
              color: isSelected ? const Color(0xFFFFD700) : Colors.white54,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
      title: Text(
        lang,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.white54,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        desc,
        style: GoogleFonts.poppins(
          color: Colors.white38,
          fontSize: 12,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFFFFD700), size: 20)
          : null,
      onTap: () {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language: '),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFFFFD700), size: 22),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFFFD700),
      inactiveThumbColor: Colors.white24,
      inactiveTrackColor: Colors.white10,
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFFD700), size: 22),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFFD700), size: 22),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.white10,
      indent: 56,
    );
  }

  void _showDistancePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Max Ride Distance',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Set the maximum distance you are willing to travel for a single ride. This feature will be available in a future update.',
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: const Color(0xFFFFD700)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Log Out',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
