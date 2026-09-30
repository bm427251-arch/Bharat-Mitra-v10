import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../common_widgets.dart';

class CandidateProfileCreateScreen extends StatefulWidget {
  final VoidCallback? onProfileSaved;

  const CandidateProfileCreateScreen({super.key, this.onProfileSaved});

  @override
  State<CandidateProfileCreateScreen> createState() =>
      _CandidateProfileCreateScreenState();
}

class _CandidateProfileCreateScreenState
    extends State<CandidateProfileCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _locationCtrl = TextEditingController(text: 'Salt Lake Sector V, Kolkata');
  final _subCategoryCtrl = TextEditingController();
  final _expCtrl = TextEditingController(text: '3 Years');
  final _skillsCtrl = TextEditingController(text: 'Navigation, Customer Service, Punctual');
  final _salaryCtrl = TextEditingController(text: '₹22,000 / month');
  final _bioCtrl = TextEditingController(text: 'Hardworking professional with clean record and verified background.');

  String _selectedCategory = 'Driver';
  bool _hasResume = false;
  String _resumeFileName = 'Resume_CV.pdf';
  bool _isSaving = false;

  final List<String> _categories = [
    'Driver',
    'Technician',
    'Delivery Partner',
    'Teacher',
    'Doctor',
    'Artist',
    'Advocate',
    'Security Guard',
    'Sales Executive',
    'Electrician',
    'Plumber',
    'Other',
  ];

  final List<String> _landmarks = [
    'Howrah Station',
    'Salt Lake Sector V',
    'New Town Action Area',
    'Park Street Metro',
    'Barasat Court',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _locationCtrl.dispose();
    _subCategoryCtrl.dispose();
    _expCtrl.dispose();
    _skillsCtrl.dispose();
    _salaryCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_candidate_profile', true);
      await prefs.setString('candidate_name', _nameCtrl.text.trim());
      await prefs.setString('candidate_category', _selectedCategory);
      await prefs.setString('candidate_sub_category', _subCategoryCtrl.text.trim());
      await prefs.setString('candidate_location', _locationCtrl.text.trim());
      await prefs.setString('candidate_phone', _phoneCtrl.text.trim());
      await prefs.setString('candidate_salary', _salaryCtrl.text.trim());
      await prefs.setString('candidate_exp', _expCtrl.text.trim());
      await prefs.setString('candidate_subscription', '349/3 Months Active');

      // Also push to Firestore candidates collection
      try {
        await FirebaseFirestore.instance
            .collection('candidates')
            .doc('current_user_id')
            .set({
          'name': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'location': _locationCtrl.text.trim(),
          'category': _selectedCategory,
          'sub_category': _subCategoryCtrl.text.trim(),
          'experience': _expCtrl.text.trim(),
          'skills': _skillsCtrl.text.trim(),
          'expected_salary': _salaryCtrl.text.trim(),
          'has_resume': _hasResume,
          'bio': _bioCtrl.text.trim(),
          'subscription_active': true,
          'subscription_plan': '349/3 Months Active',
          'is_live': true,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore candidate save notice: $e');
      }

      setState(() => _isSaving = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF138808),
          content: Text('Profile saved! You are now LIVE on Candidate Wall with 349/3 Months Active.'),
        ),
      );

      widget.onProfileSaved?.call();
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final needsSubCategory = _selectedCategory == 'Teacher' ||
        _selectedCategory == 'Doctor' ||
        _selectedCategory == 'Artist' ||
        _selectedCategory == 'Advocate' ||
        _selectedCategory == 'Other';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          '+ Create Candidate Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          const CustomPaint(size: Size.infinite, painter: TricolorWatermarkPainter()),
          const BharatMitraWatermark(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PHOTO UPLOAD
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: const Color(0xFF222222),
                          child: const Icon(Icons.person, size: 54, color: Color(0xFFFF9933)),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xFF138808),
                                  content: Text('Profile photo selected!'),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF9933),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.black, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // FULL NAME
                  _buildLabel('Full Name *'),
                  TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Enter your full name', Icons.person_outline),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 14),

                  // PHONE & EMAIL
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Phone Number *'),
                            TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDeco('10-digit Phone', Icons.phone),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone required' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Email (Optional)'),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDeco('Email address', Icons.email_outlined),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // CATEGORY DROPDOWN
                  _buildLabel('Category *'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        dropdownColor: const Color(0xFF1F1F1F),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        isExpanded: true,
                        items: _categories.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedCategory = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // CONDITIONAL SUB-CATEGORY (Teacher / Doctor / Artist / Advocate / Type Your Category)
                  if (needsSubCategory) ...[
                    _buildLabel(_selectedCategory == 'Teacher'
                        ? 'What kind of Teacher? Type here - Dance/Music/Tuition *'
                        : 'Type Your Specific Category / Specialization *'),
                    TextFormField(
                      controller: _subCategoryCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco(
                        _selectedCategory == 'Teacher'
                            ? 'e.g. Dance, Classical Music, Math Tuition'
                            : 'Specify your specialization',
                        Icons.school_outlined,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Specialization required' : null,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // LOCATION & ISRO MAPPLS AUTOCOMPLETE / LANDMARK
                  _buildLabel('Location (ISRO Mappls / NavIC) *'),
                  TextFormField(
                    controller: _locationCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'City, Landmark or Area',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.location_on, color: Color(0xFF138808)),
                      filled: true,
                      fillColor: const Color(0xFF161616),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Location required' : null,
                  ),
                  const SizedBox(height: 8),
                  // Nearby landmark chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _landmarks.map((l) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            label: Text(l, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                            backgroundColor: Colors.white10,
                            side: const BorderSide(color: Colors.white24),
                            onPressed: () {
                              setState(() => _locationCtrl.text = '$l, Kolkata');
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // EXPERIENCE & EXPECTED SALARY
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Experience'),
                            TextFormField(
                              controller: _expCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDeco('e.g. 3 Years', Icons.history),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Expected Salary'),
                            TextFormField(
                              controller: _salaryCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDeco('₹20,000 / mo', Icons.currency_rupee),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // SKILLS TAGS
                  _buildLabel('Skills Tags'),
                  TextFormField(
                    controller: _skillsCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Comma separated skills', Icons.verified_outlined),
                  ),
                  const SizedBox(height: 14),

                  // RESUME PDF UPLOAD
                  _buildLabel('Resume / CV (PDF)'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _hasResume ? Colors.green : Colors.white24),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _hasResume ? Icons.check_circle : Icons.upload_file,
                          color: _hasResume ? Colors.green : const Color(0xFFFF9933),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _hasResume ? _resumeFileName : 'Upload Resume PDF',
                            style: TextStyle(
                              color: _hasResume ? Colors.white : Colors.white60,
                              fontSize: 13,
                              fontWeight: _hasResume ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _hasResume = true;
                              _resumeFileName = 'Candidate_Resume_${_selectedCategory}.pdf';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF138808),
                                content: Text('Attached: $_resumeFileName'),
                              ),
                            );
                          },
                          child: Text(_hasResume ? 'Change' : 'Browse'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // BIO
                  _buildLabel('Short Bio / About Me'),
                  TextFormField(
                    controller: _bioCtrl,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Briefly describe your background', Icons.notes),
                  ),
                  const SizedBox(height: 24),

                  // SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9933),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isSaving ? null : _handleSave,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Icon(Icons.check_circle_outline, color: Colors.black),
                      label: Text(
                        _isSaving ? 'Saving Profile...' : 'Save & Go LIVE on Candidate Wall',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
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

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      );

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: const Color(0xFFFF9933)),
        filled: true,
        fillColor: const Color(0xFF161616),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
      );
}
