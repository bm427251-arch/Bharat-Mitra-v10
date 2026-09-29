import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';

class BecomeSebakScreen extends StatefulWidget {
  const BecomeSebakScreen({super.key});

  @override
  State<BecomeSebakScreen> createState() => _BecomeSebakScreenState();
}

class _BecomeSebakScreenState extends State<BecomeSebakScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _areaController = TextEditingController();
  final _priceController = TextEditingController(text: '249');
  final _customProfessionController = TextEditingController();

  String _selectedSkill = 'AC Technician';
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  bool _hasPhoto = false;

  final List<String> _skillsList = [
    'AC Technician',
    'Advocate / Legal Consultant',
    'Appliance Repair',
    'Astrologer / Pandit',
    'Babysitter / Nanny',
    'Barber / Hair Stylist',
    'Bicycle Mechanic',
    'CCTV & Security Installer',
    'Carpenter',
    'Chartered Accountant (CA)',
    'Chimney & Hob Repair',
    'Cleaner / Deep Cleaning',
    'Cook / Chef (Home / Event)',
    'Curtain & Blind Installer',
    'DJ / Sound System Specialist',
    'Decorator / Event Planner',
    'Delivery / Errand Runner',
    'Dentist / Oral Hygienist',
    'Dietitian / Nutritionist',
    'Doctor (Home Visit)',
    'Driver (Personal / Commercial)',
    'Electrician',
    'Elderly Care Assistant',
    'Fabricator / Welder',
    'Flooring & Tile Layer',
    'Gardener / Plant Specialist',
    'Glass & Window Glazier',
    'Home Automation Specialist',
    'Home Nurse / Caregiver',
    'Interior Designer',
    'Laundry & Dry Cleaner',
    'Laptop Repair Specialist',
    'Locksmith / Key Maker',
    'Makeup Artist (Bridal / Party)',
    'Mason / Civil Contractor',
    'Massage Therapist',
    'Mechanic (2 Wheeler / 4 Wheeler)',
    'Mehndi Artist',
    'Mobile & Tablet Repair',
    'Movers & Packers Helper',
    'Painter (Wall / Texture / Waterproof)',
    'Pest Control Specialist',
    'Pet Groomer / Vet Assistant',
    'Photographer / Videographer',
    'Physiotherapist',
    'Plumber',
    'RO Water Purifier Service',
    'Roofing & Waterproofing',
    'Security Guard / Bouncer',
    'Shoe & Bag Restorer',
    'Solar Panel Installer',
    'Sofa & Carpet Cleaner',
    'Tailor / Dressmaker',
    'Tattoo Artist',
    'Tutor (Academic / Music / Dance)',
    'Water Tank Cleaner',
    'Yoga & Fitness Trainer',
    'Others ➕',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _customProfessionController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    final isCustom = _selectedSkill == 'Others ➕';
    final customName = _customProfessionController.text.trim();
    if (isCustom && customName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please type your custom profession!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final sebakData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'skill': isCustom ? (customName.isNotEmpty ? customName : 'Others') : _selectedSkill,
      'profession': isCustom ? 'Others' : _selectedSkill,
      'customProfession': isCustom ? customName : '',
      'isCustom': isCustom,
      'experienceYears': int.tryParse(_experienceController.text.trim()) ?? 3,
      'area': _areaController.text.trim(),
      'pricePerHour': int.tryParse(_priceController.text.trim()) ?? 249,
      'hasPhoto': _hasPhoto,
      'rating': 5.0,
      'reviewsCount': 0,
      'isAvailable': true,
    };

    await FirestoreService().registerSebak(sebakData);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Become a Verified Sebak'),
        backgroundColor: AppColors.secondary,
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
            // Banner card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33FF7A00),
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
                      Icons.handyman_rounded,
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
                          'Join Bharat Sebak Network',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Direct customer calls with zero commission cut.',
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
              'Professional Information',
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
              hint: 'e.g. Subhash Ghosh',
              icon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your full name' : null,
            ),
            const SizedBox(height: 14),

            // Phone
            _buildField(
              controller: _phoneController,
              label: 'Mobile Number',
              hint: '9830000000',
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().length < 10) ? 'Enter valid 10-digit number' : null,
            ),
            const SizedBox(height: 14),

            // Skill Dropdown
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
                  value: _selectedSkill,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondary),
                  items: _skillsList.map((skill) {
                    return DropdownMenuItem<String>(
                      value: skill,
                      child: Row(
                        children: [
                          const Icon(Icons.home_repair_service_rounded, size: 20, color: AppColors.secondary),
                          const SizedBox(width: 10),
                          Text(
                            skill,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSkill = val);
                  },
                ),
              ),
            ),
            if (_selectedSkill == 'Others ➕') ...[
              const SizedBox(height: 12),
              _buildField(
                controller: _customProfessionController,
                label: 'Type Your Profession',
                hint: 'e.g. Lawyer, Photographer, Mehndi Artist',
                icon: Icons.edit_note_rounded,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please specify your profession'
                    : null,
              ),
            ],
            const SizedBox(height: 14),

            // Experience & Hourly rate in Row
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _experienceController,
                    label: 'Years Exp',
                    hint: '5',
                    icon: Icons.workspace_premium_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _priceController,
                    label: 'Rate/Hour (₹)',
                    hint: '249',
                    icon: Icons.currency_rupee_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Service Area
            _buildField(
              controller: _areaController,
              label: 'Serving Areas / Locality',
              hint: 'e.g. Salt Lake, New Town, Baguiati',
              icon: Icons.location_on_outlined,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please specify your service area' : null,
            ),
            const SizedBox(height: 20),

            // Photo picker
            InkWell(
              onTap: () => setState(() => _hasPhoto = !_hasPhoto),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: _hasPhoto ? const Color(0xFFFFF4EB) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _hasPhoto ? AppColors.secondary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _hasPhoto ? Icons.check_circle_rounded : Icons.camera_alt_outlined,
                        color: _hasPhoto ? AppColors.secondary : AppColors.textSecondary,
                        size: 30,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _hasPhoto ? 'Profile Photo Selected' : 'Upload Profile Photo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _hasPhoto ? AppColors.secondary : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33FF7A00),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isSubmitting ? null : _submitApplication,
                  child: Center(
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit Sebak Registration',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
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
          prefixIcon: Icon(icon, color: AppColors.secondary, size: 22),
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
            borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
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
                color: Color(0xFFFFF4EB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.secondary,
                size: 54,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            const Text(
              'Registration Successful!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Welcome, ${_nameController.text}! Your registration for $_selectedSkill has been saved. Your profile will be visible to nearby customers upon KYC verification.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            AppTheme.primaryGradientButton(
              text: 'Done',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
