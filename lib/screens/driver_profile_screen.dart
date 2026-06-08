import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'vehicle_info_screen.dart';
import 'trip_history_screen.dart';
import 'earnings_screen.dart';
import 'login_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _avatarFile;
  bool _isEditing = false;
  bool _isLoading = true;
  int _totalTrips = 47;
  double _totalEarnings = 385500;
  double _rating = 4.8;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('driver_name') ?? 'Driver Name';
      _licenseController.text =
          prefs.getString('driver_license') ?? 'DL-123456';
      _phoneController.text =
          prefs.getString('driver_phone') ?? '09-123456789';
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_name', _nameController.text);
    await prefs.setString('driver_license', _licenseController.text);
    await prefs.setString('driver_phone', _phoneController.text);

    setState(() {
      _isEditing = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile updated!',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _avatarFile = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
          ),
        ),
      );
    }

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
          'My Profile',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Text(
              _isEditing ? 'Cancel' : 'Edit',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: _isEditing ? _pickAvatar : null,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: const Color(0xFFFFD700),
                    backgroundImage:
                        _avatarFile != null ? FileImage(_avatarFile!) : null,
                    child: _avatarFile == null
                        ? const Icon(Icons.person, color: Colors.black, size: 50)
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.orange, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_rating',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '  (128 reviews)',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: 'Total Trips',
                    value: '$_totalTrips',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    label: 'Total Earnings',
                    value: 'Ks ${_totalEarnings.toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet,
                    color: const Color(0xFFFFD700),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Profile form
            if (_isEditing) ...[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _licenseController,
                      label: 'Driver License No.',
                      icon: Icons.badge,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // View mode
              _buildInfoRow('Name', _nameController.text, Icons.person),
              const Divider(color: Colors.white10, height: 32),
              _buildInfoRow('Phone', _phoneController.text, Icons.phone),
              const Divider(color: Colors.white10, height: 32),
              _buildInfoRow(
                'License',
                _licenseController.text,
                Icons.badge,
              ),
              const Divider(color: Colors.white10, height: 32),
              _buildInfoRow(
                'Vehicle',
                'CNG CAR · YGN-1234',
                Icons.directions_car,
              ),
            ],

            const SizedBox(height: 40),

            // Menu items
            _buildMenuItem(
              icon: Icons.directions_car,
              label: 'Vehicle Info',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VehicleInfoScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.history,
              label: 'Trip History',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TripHistoryScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.bar_chart,
              label: 'Earnings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EarningsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Help center coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip,
              label: 'Privacy Policy',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy policy coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Logout
            _buildMenuItem(
              icon: Icons.logout,
              label: 'Logout',
              color: Colors.redAccent,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF2A2A3E),
                    title: Text(
                      'Logout?',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      'You will be logged out from the app.',
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: Colors.white54),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Logout',
                          style: GoogleFonts.poppins(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFFFFD700), size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 11),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color ?? Colors.white70, size: 22),
          title: Text(
            label,
            style: GoogleFonts.poppins(
              color: color ?? Colors.white70,
              fontSize: 14,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.white38,
            size: 18,
          ),
          onTap: onTap,
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 0,
        ),
        const Divider(color: Colors.white10, height: 1),
      ],
    );
  }
}
