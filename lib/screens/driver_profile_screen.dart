import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vehicle_info_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({Key? key}) : super(key: key);

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idCardController = TextEditingController();
  final _licenseController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _idCardController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void _submitProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save driver profile data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '资料提交成功！',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );

      // Navigate to vehicle info screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const VehicleInfoScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '司机资料',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: 1 / 3,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              ),
              const SizedBox(height: 16),
              Text(
                '第 1 步 / 共 3 步',
                style: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Name field
              Text(
                '姓名',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '请输入真实姓名',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person, color: Color(0xFFFFD700)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入姓名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ID Card field
              Text(
                '身份证号',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _idCardController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '请输入身份证号码',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.credit_card, color: Color(0xFFFFD700)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入身份证号';
                  }
                  if (value.length != 18 && value.length != 15) {
                    return '身份证号格式不正确';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Driver's License field
              Text(
                '驾驶证号',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _licenseController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '请输入驾驶证号',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.directions_car, color: Color(0xFFFFD700)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入驾驶证号';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 48),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF1A1A2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '下一步',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
