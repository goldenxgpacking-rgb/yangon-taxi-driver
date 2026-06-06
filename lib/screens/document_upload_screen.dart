import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart'; // TODO: fix permission_handler
import 'home_screen.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({Key? key}) : super(key: key);

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  
  File? _idCardFront;
  File? _idCardBack;
  File? _driverLicense;
  File? _vehicleFront;
  File? _vehicleBack;
  File? _vehicleLicense;

  Future<void> _requestPermissions() async {
    // TODO: Re-enable permission_handler after fixing CI
    // Mock permission for now
  }

  Future<void> _pickImage(ImageSource source, Function(File) onImagePicked) async {
    await _requestPermissions();
    
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          onImagePicked(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '选择图片失败：$e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog(Function(File) onImagePicked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: Text(
          '选择图片来源',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFFFD700)),
              title: Text(
                '拍照',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, onImagePicked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFFFD700)),
              title: Text(
                '从相册选择',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, onImagePicked);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadItem({
    required String title,
    required File? image,
    required Function(File) onImagePicked,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showImageSourceDialog(onImagePicked),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                ),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        image,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 48,
                          color: const Color(0xFFFFD700).withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '点击上传',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitDocuments() {
    // TODO: Upload documents to server
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '证件上传成功！等待审核...',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );

    // Navigate to home screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '证件上传',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            const LinearProgressIndicator(
              value: 1.0, // 3/3 = 100%
              backgroundColor: Color(0xFF2A2A3E),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
            const SizedBox(height: 16),
            Text(
              '第 3 步 / 共 3 步',
              style: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // ID Card Front
            _buildUploadItem(
              title: '身份证正面',
              image: _idCardFront,
              onImagePicked: (file) => _idCardFront = file,
              description: '请上传身份证正面照片',
            ),

            // ID Card Back
            _buildUploadItem(
              title: '身份证反面',
              image: _idCardBack,
              onImagePicked: (file) => _idCardBack = file,
              description: '请上传身份证反面照片',
            ),

            // Driver's License
            _buildUploadItem(
              title: '驾驶证',
              image: _driverLicense,
              onImagePicked: (file) => _driverLicense = file,
              description: '请上传驾驶证照片',
            ),

            // Vehicle Front
            _buildUploadItem(
              title: '车辆正面照',
              image: _vehicleFront,
              onImagePicked: (file) => _vehicleFront = file,
              description: '请上传车辆正面照片',
            ),

            // Vehicle Back
            _buildUploadItem(
              title: '车辆反面照',
              image: _vehicleBack,
              onImagePicked: (file) => _vehicleBack = file,
              description: '请上传车辆反面照片',
            ),

            // Vehicle License
            _buildUploadItem(
              title: '车辆行驶证',
              image: _vehicleLicense,
              onImagePicked: (file) => _vehicleLicense = file,
              description: '请上传车辆行驶证照片',
            ),

            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitDocuments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF1A1A2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '提交审核',
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
    );
  }
}
