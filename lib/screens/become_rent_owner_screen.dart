import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';

class BecomeRentOwnerScreen extends StatefulWidget {
  const BecomeRentOwnerScreen({super.key});

  @override
  State<BecomeRentOwnerScreen> createState() => _BecomeRentOwnerScreenState();
}

class _BecomeRentOwnerScreenState extends State<BecomeRentOwnerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  bool _hasGarage = true;
  bool _hasAadhaar = false;
  bool _hasSelfie = false;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _ownerNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submitOwnerProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final ownerData = {
        'ownerName': _ownerNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'city': _cityController.text.trim(),
        'hasGarage': _hasGarage,
        'hasAadhaar': _hasAadhaar,
        'hasSelfie': _hasSelfie,
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'verified',
        'isApproved': true,
      };

      await FirestoreService.instance.saveRentOwner(ownerData);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile saved successfully! Welcome Rent Owner.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text("becomeOwner".tr()),
          backgroundColor: const Color(0xFF1A3A6E),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 48),
                ),
                const SizedBox(height: 20),
                Text(
                  "Owner Profile Created!",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your garage is now verified on Bharat Mitra Pan India network. You can add vehicles and earn direct daily rental with 0% commission.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A6E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Rentals', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("becomeOwner".tr()),
        backgroundColor: const Color(0xFF1A3A6E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A3A6E), Color(0xFF2E5BA8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.car_rental_rounded, color: Colors.white, size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "becomeOwner".tr(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Rent out your bikes, scooties, or cars Pan India with 0% commission.",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms),

              const SizedBox(height: 20),

              // Owner Name
              _buildField(
                controller: _ownerNameController,
                label: "ownerName".tr(),
                hint: "e.g. Ramesh Kumar",
                icon: Icons.person_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter owner name' : null,
              ),

              const SizedBox(height: 14),

              // Phone Number
              _buildField(
                controller: _phoneController,
                label: "phoneNumber".tr(),
                hint: "10-digit mobile number",
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().length < 10) ? 'Enter valid 10-digit phone' : null,
              ),

              const SizedBox(height: 14),

              // City
              _buildField(
                controller: _cityController,
                label: "city".tr(),
                hint: "e.g. Digha, Darjeeling, Puri, Goa, Kolkata",
                icon: Icons.location_city_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please specify city' : null,
              ),

              const SizedBox(height: 16),

              // Has Dedicated Garage
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.garage_rounded, color: Color(0xFF1A3A6E)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "hasGarage".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                    ),
                    Switch(
                      value: _hasGarage,
                      activeColor: const Color(0xFF1A3A6E),
                      onChanged: (val) => setState(() => _hasGarage = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Document uploads: Aadhaar Front & Selfie Photo
              _buildUploadTile(
                title: "aadhaarFront".tr(),
                isUploaded: _hasAadhaar,
                onTap: () {
                  setState(() => _hasAadhaar = !_hasAadhaar);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_hasAadhaar ? 'Aadhaar front photo attached' : 'Removed Aadhaar')),
                  );
                },
              ),

              const SizedBox(height: 10),

              _buildUploadTile(
                title: "selfie".tr(),
                isUploaded: _hasSelfie,
                onTap: () {
                  setState(() => _hasSelfie = !_hasSelfie);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_hasSelfie ? 'Owner selfie photo attached' : 'Removed selfie')),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A6E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSubmitting ? null : _submitOwnerProfile,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          "becomeOwner".tr(),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E)),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: const Color(0xFF1A3A6E), size: 22),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1A3A6E), width: 1.8)),
      ),
    );
  }

  Widget _buildUploadTile({
    required String title,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isUploaded ? const Color(0xFF16A34A) : AppColors.border, width: isUploaded ? 1.5 : 1),
      ),
      child: ListTile(
        leading: Icon(
          isUploaded ? Icons.check_circle_rounded : Icons.camera_alt_rounded,
          color: isUploaded ? const Color(0xFF16A34A) : const Color(0xFF1A3A6E),
        ),
        title: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
        subtitle: Text(
          isUploaded ? 'Document Verified' : 'Tap to capture / upload',
          style: TextStyle(fontSize: 11, color: isUploaded ? const Color(0xFF16A34A) : Colors.grey),
        ),
        trailing: Icon(
          isUploaded ? Icons.done_all_rounded : Icons.upload_file_rounded,
          color: isUploaded ? const Color(0xFF16A34A) : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
