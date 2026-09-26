import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../l10n/app_translations.dart';
import '../services/firestore_service.dart';

class BecomeDriverScreen extends StatefulWidget {
  const BecomeDriverScreen({super.key});

  @override
  State<BecomeDriverScreen> createState() => _BecomeDriverScreenState();
}

class _BecomeDriverScreenState extends State<BecomeDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _vehicleNoController = TextEditingController();

  String _selectedVehicleType = 'bike';
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  bool _hasDriverPhoto = false;
  bool _hasRcPhoto = false;

  final List<Map<String, String>> _vehicleTypes = [
    {'id': 'bike', 'label': 'Bike (2-Wheeler)'},
    {'id': 'toto', 'label': 'Toto (E-Rickshaw)'},
    {'id': 'auto', 'label': 'Auto (3-Wheeler)'},
    {'id': 'sedan', 'label': 'Sedan (4-Wheeler AC)'},
    {'id': 'xl_suv', 'label': 'XL SUV (6-Seater)'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _vehicleNoController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final driverData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'licenseNo': _licenseController.text.trim(),
      'vehicleNo': _vehicleNoController.text.trim(),
      'vehicleType': _selectedVehicleType,
      'hasDriverPhoto': _hasDriverPhoto,
      'hasRcPhoto': _hasRcPhoto,
      'rating': 5.0,
      'totalRides': 0,
    };

    await FirestoreService().registerDriver(driverData);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });
    }
  }

  Widget _buildDashedPhotoPicker({
    required String title,
    required bool hasFile,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: hasFile ? const Color(0xFFE8FDF3) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile ? AppColors.success : AppColors.primaryLight.withOpacity(0.5),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasFile ? Icons.check_circle_rounded : Icons.add_a_photo_outlined,
                color: hasFile ? AppColors.success : AppColors.primary,
                size: 32,
              ),
              const SizedBox(height: 6),
              Text(
                hasFile ? '$title Uploaded' : 'Upload $title',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: hasFile ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              Text(
                'Tap to choose image',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Become a Driver Partner'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSubmitted ? _buildSuccessView() : _buildFormView(),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x330B2E6E),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_car_filled_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zero Commission Driving',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Keep 100% of your earnings. No middlemen cut.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),
            const Text(
              'Personal & Vehicle Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            // Full Name
            _buildField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'e.g. Rahul Sharma',
              icon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your full name' : null,
            ),
            const SizedBox(height: 14),

            // Phone Number
            _buildField(
              controller: _phoneController,
              label: 'Phone Number (10 digits)',
              hint: '9876543210',
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.trim().length < 10) {
                  return 'Please enter a valid 10-digit mobile number';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Vehicle Type Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedVehicleType,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                  items: _vehicleTypes.map((v) {
                    return DropdownMenuItem<String>(
                      value: v['id'],
                      child: Text(
                        v['label']!,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedVehicleType = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // License No
            _buildField(
              controller: _licenseController,
              label: 'Driving License Number',
              hint: 'e.g. DL-1420110012345',
              icon: Icons.badge_outlined,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your license number' : null,
            ),
            const SizedBox(height: 14),

            // Vehicle Registration Number
            _buildField(
              controller: _vehicleNoController,
              label: 'Vehicle Plate Number',
              hint: 'e.g. WB 02 AB 1234',
              icon: Icons.confirmation_number_outlined,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter vehicle registration number' : null,
            ),

            const SizedBox(height: 24),
            const Text(
              'Required Documents',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildDashedPhotoPicker(
                    title: 'Driver Photo',
                    hasFile: _hasDriverPhoto,
                    onTap: () => setState(() => _hasDriverPhoto = !_hasDriverPhoto),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildDashedPhotoPicker(
                    title: 'Vehicle RC',
                    hasFile: _hasRcPhoto,
                    onTap: () => setState(() => _hasRcPhoto = !_hasRcPhoto),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            AppTheme.primaryGradientButton(
              text: 'Submit Driver Application',
              isLoading: _isSubmitting,
              onPressed: _submitApplication,
            ),
            const SizedBox(height: 20),
          ],
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.successBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: AppColors.success,
                size: 54,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            const Text(
              'Application Received!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Thank you, ${_nameController.text}! Your driver profile has been stored with status "Pending Verification". Our team will verify your documents within 24 hours.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            AppTheme.primaryGradientButton(
              text: 'Back to Home',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
