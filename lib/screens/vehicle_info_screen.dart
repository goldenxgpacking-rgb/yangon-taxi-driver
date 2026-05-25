import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'document_upload_screen.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({Key? key}) : super(key: key);

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();

  // Car type options
  final List<String> _carTypes = ['CNG CAR', 'OIL CAR', 'EV CAR', '私家车'];
  String? _selectedCarType;

  @override
  void dispose() {
    _modelController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _submitVehicleInfo() {
    if (_formKey.currentState!.validate() && _selectedCarType != null) {
      // TODO: Save vehicle info data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '车辆信息提交成功！',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );

      // Navigate to document upload screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const DocumentUploadScreen(),
        ),
      );
    } else if (_selectedCarType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '请选择车型',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
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
          '车辆信息',
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
                value: 2 / 3,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              ),
              const SizedBox(height: 16),
              Text(
                '第 2 步 / 共 3 步',
                style: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Car type dropdown
              Text(
                '车型',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCarType,
                    hint: Text(
                      '请选择车型',
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                    isExpanded: true,
                    dropdownColor: const Color(0xFF2A2A3E),
                    style: GoogleFonts.poppins(color: Colors.white),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700)),
                    items: _carTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          type,
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCarType = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Car model field
              Text(
                '车辆型号',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _modelController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '例如：Toyota Camry',
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
                    return '请输入车辆型号';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // License plate field
              Text(
                '车牌号',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _plateController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '请输入车牌号',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.credit_score, color: Color(0xFFFFD700)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入车牌号';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Car color field
              Text(
                '车辆颜色',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _colorController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '例如：白色',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.color_lens, color: Color(0xFFFFD700)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入车辆颜色';
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
                  onPressed: _submitVehicleInfo,
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
