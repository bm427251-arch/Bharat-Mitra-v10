import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class DriverDocumentUploadScreen extends StatefulWidget {
  final String? driverId;
  const DriverDocumentUploadScreen({super.key, this.driverId});

  @override
  State<DriverDocumentUploadScreen> createState() => _DriverDocumentUploadScreenState();
}

class _DriverDocumentUploadScreenState extends State<DriverDocumentUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  File? _licenceFront;
  File? _licenceBack;
  File? _aadhaarCard;
  File? _profilePhoto;

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  Future<void> _pickDocument(String type) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        final f = File(picked.path);
        switch (type) {
          case 'licence_front':
            _licenceFront = f;
            break;
          case 'licence_back':
            _licenceBack = f;
            break;
          case 'aadhaar':
            _aadhaarCard = f;
            break;
          case 'profile':
            _profilePhoto = f;
            break;
        }
      });
    }
  }

  Future<void> _uploadAllDocuments() async {
    if (_licenceFront == null && _licenceBack == null && _aadhaarCard == null && _profilePhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one document to upload')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Compressing and uploading documents...';
    });

    final uid = widget.driverId ?? FirebaseAuth.instance.currentUser?.uid ?? 'driver_${DateTime.now().millisecondsSinceEpoch}';
    final Map<String, dynamic> docUrls = {};

    try {
      int totalToUpload = 0;
      if (_licenceFront != null) totalToUpload++;
      if (_licenceBack != null) totalToUpload++;
      if (_aadhaarCard != null) totalToUpload++;
      if (_profilePhoto != null) totalToUpload++;

      int completed = 0;

      if (_licenceFront != null) {
        setState(() => _uploadStatus = 'Uploading Driving Licence Front (70% compressed)...');
        final url = await StorageService().uploadImage(
          _licenceFront!,
          'drivers/$uid/documents',
          onProgress: (p) => setState(() => _uploadProgress = (completed + p) / totalToUpload),
        );
        docUrls['licenceFrontUrl'] = url;
        completed++;
      }

      if (_licenceBack != null) {
        setState(() => _uploadStatus = 'Uploading Driving Licence Back...');
        final url = await StorageService().uploadImage(
          _licenceBack!,
          'drivers/$uid/documents',
          onProgress: (p) => setState(() => _uploadProgress = (completed + p) / totalToUpload),
        );
        docUrls['licenceBackUrl'] = url;
        completed++;
      }

      if (_aadhaarCard != null) {
        setState(() => _uploadStatus = 'Uploading Aadhaar Card...');
        final url = await StorageService().uploadImage(
          _aadhaarCard!,
          'drivers/$uid/documents',
          onProgress: (p) => setState(() => _uploadProgress = (completed + p) / totalToUpload),
        );
        docUrls['aadhaarUrl'] = url;
        completed++;
      }

      if (_profilePhoto != null) {
        setState(() => _uploadStatus = 'Uploading Profile Picture...');
        final url = await StorageService().uploadImage(
          _profilePhoto!,
          'drivers/$uid/profile',
          onProgress: (p) => setState(() => _uploadProgress = (completed + p) / totalToUpload),
        );
        docUrls['photoUrl'] = url;
        completed++;
      }

      docUrls['documentsUploadedAt'] = FieldValue.serverTimestamp();
      docUrls['verificationStatus'] = 'pending_review';

      await FirebaseFirestore.instance.collection('drivers').doc(uid).set(docUrls, SetOptions(merge: true));

      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All documents compressed & uploaded successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload saved: $e'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Driver KYC & Documents'),
        backgroundColor: const Color(0xFF1A3A6E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Driver Documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Compressed automatically to save mobile data before uploading to Mumbai storage bucket.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),

            if (_isUploading) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _uploadStatus,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(_uploadProgress * 100).toInt()}%',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _uploadProgress > 0 ? _uploadProgress : null,
                      backgroundColor: const Color(0xFFDBEAFE),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            _buildUploadCard(
              title: 'Driver Profile Photo',
              subtitle: 'Clear front face photo with cap/glasses off',
              icon: Icons.account_circle_rounded,
              file: _profilePhoto,
              onTap: () => _pickDocument('profile'),
            ),
            const SizedBox(height: 12),

            _buildUploadCard(
              title: 'Driving Licence (Front)',
              subtitle: 'Commercial / LMV valid licence front side',
              icon: Icons.badge_rounded,
              file: _licenceFront,
              onTap: () => _pickDocument('licence_front'),
            ),
            const SizedBox(height: 12),

            _buildUploadCard(
              title: 'Driving Licence (Back)',
              subtitle: 'Valid licence reverse address side',
              icon: Icons.flip_to_back_rounded,
              file: _licenceBack,
              onTap: () => _pickDocument('licence_back'),
            ),
            const SizedBox(height: 12),

            _buildUploadCard(
              title: 'Aadhaar Card (Govt ID)',
              subtitle: 'Address & identity proof verification',
              icon: Icons.credit_card_rounded,
              file: _aadhaarCard,
              onTap: () => _pickDocument('aadhaar'),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isUploading ? null : _uploadAllDocuments,
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Compress & Upload All Documents', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required File? file,
    required VoidCallback onTap,
  }) {
    final bool isSelected = file != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF86EFAC) : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.check_circle_rounded : icon,
                color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF166534) : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isSelected ? 'Document file ready (${(file.lengthSync() / 1024).toStringAsFixed(1)} KB)' : subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? const Color(0xFF15803D) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.replay_rounded : Icons.upload_file_rounded,
              color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF0F766E),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
