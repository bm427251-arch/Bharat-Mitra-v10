import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController(text: 'Kolkata');

  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _needsRoleSelection = false;

  String _selectedRole = 'customer'; // customer, driver, sevak, rent_owner

  final List<Map<String, dynamic>> _roleOptions = [
    {
      'id': 'customer',
      'title': 'Customer (Rider & Service Seeker)',
      'subtitle': 'Book 0% commission rides, rentals and home repairs',
      'icon': Icons.person_rounded,
      'color': Color(0xFF1A3A6E),
    },
    {
      'id': 'driver',
      'title': 'Driver Partner',
      'subtitle': 'Drive Bike, Toto, Auto, Sedan with 100% direct fares',
      'icon': Icons.directions_car_filled_rounded,
      'color': Color(0xFF1D4ED8),
    },
    {
      'id': 'sevak',
      'title': 'Sevak Specialist',
      'subtitle': 'Verified electrician, plumber, AC specialist',
      'icon': Icons.handyman_rounded,
      'color': Color(0xFF0F766E),
    },
    {
      'id': 'rent_owner',
      'title': 'Rent Vehicle Owner',
      'subtitle': 'Earn daily rent on self-drive cars, bikes and scooties',
      'icon': Icons.car_rental_rounded,
      'color': Color(0xFFC2410C),
    },
  ];

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      _isLoading = false;
      _isOtpSent = true;
      _otpCtrl.text = '123456'; // Pre-filled default test OTP
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to +91 mobile! (Use demo code 123456)'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    }
  }

  void _verifyOtp() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 6-digit OTP code')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));

    final phone = _phoneCtrl.text.trim();
    final existingUser = await FirestoreService().getUserByPhone(phone);

    if (mounted) {
      setState(() => _isLoading = false);

      if (existingUser != null) {
        // User exists -> Route directly based on currentMode or role
        final mode = existingUser['currentMode'] ?? 'customer';
        final userType = existingUser['userType'] ?? 'customer';

        if (mode == 'provider') {
          if (userType == 'driver') {
            Navigator.pushReplacementNamed(context, '/driver-home');
          } else if (userType == 'sevak') {
            Navigator.pushReplacementNamed(context, '/sevak-home');
          } else if (userType == 'rent_owner') {
            Navigator.pushReplacementNamed(context, '/rent-owner-home');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // User not registered -> Show Role selection and registration form
        setState(() {
          _needsRoleSelection = true;
        });
      }
    }
  }

  void _completeRegistration() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final phone = _phoneCtrl.text.trim();

    await FirestoreService().registerUser(
      phone: phone,
      name: name,
      userType: _selectedRole,
      city: _cityCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Welcome to Bharat Mitra.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );

      // Route based on role
      if (_selectedRole == 'driver') {
        Navigator.pushReplacementNamed(context, '/driver-home');
      } else if (_selectedRole == 'sevak') {
        Navigator.pushReplacementNamed(context, '/sevak-home');
      } else if (_selectedRole == 'rent_owner') {
        Navigator.pushReplacementNamed(context, '/rent-owner-home');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // App Brand Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A3A6E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.handshake_rounded, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'BHARAT MITRA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Color(0xFF1A3A6E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '0% Commission Rides, Rentals & Home Services',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              if (!_needsRoleSelection) ...[
                // PHONE & OTP CARD
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0C000000), blurRadius: 16, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isOtpSent ? 'Verify OTP Code' : 'Login / Register with Mobile',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isOtpSent
                            ? 'Enter the 6-digit OTP code sent to +91 ${_phoneCtrl.text}'
                            : 'Enter your 10-digit phone number to get instant OTP code:',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),

                      if (!_isOtpSent) ...[
                        TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.phone_iphone_rounded, color: Color(0xFF1A3A6E)),
                            prefixText: '+91  ',
                            labelText: 'Mobile Number',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A3A6E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _isLoading ? null : _sendOtp,
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Send Verification OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ),
                      ] else ...[
                        TextField(
                          controller: _otpCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
                          decoration: InputDecoration(
                            labelText: '6-Digit OTP',
                            hintText: '123456',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _isLoading ? null : _verifyOtp,
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Verify & Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: () => setState(() => _isOtpSent = false),
                            child: const Text('Change Mobile Number', style: TextStyle(color: Color(0xFF1A3A6E))),
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate().slideY(begin: 0.1, end: 0, duration: 350.ms),
              ] else ...[
                // ROLE SELECTION & REGISTRATION FORM
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0C000000), blurRadius: 16, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Who Are You?',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select your role on Bharat Mitra to personalize your experience:',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),

                      // Role Options
                      ..._roleOptions.map((opt) {
                        final isSelected = _selectedRole == opt['id'];
                        final Color color = opt['color'];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withOpacity(0.08) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? color : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? color : Colors.grey.shade200,
                              child: Icon(opt['icon'], color: isSelected ? Colors.white : Colors.grey.shade700, size: 20),
                            ),
                            title: Text(opt['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? color : Colors.black87)),
                            subtitle: Text(opt['subtitle'], style: const TextStyle(fontSize: 11.5)),
                            trailing: isSelected ? Icon(Icons.check_circle_rounded, color: color) : null,
                            onTap: () => setState(() => _selectedRole = opt['id']),
                          ),
                        );
                      }),

                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 10),

                      // Profile Info
                      TextField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline),
                          labelText: 'Your Full Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _cityCtrl,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_city_rounded),
                          labelText: 'City (e.g. Kolkata, Goa, Digha, Delhi)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3A6E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _isLoading ? null : _completeRegistration,
                          child: _isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Complete & Start', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 0.1, end: 0, duration: 350.ms),
              ],

              const SizedBox(height: 24),
              // Direct skip to Customer Home
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Continue as Guest Customer', style: TextStyle(color: Color(0xFF1A3A6E), fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
