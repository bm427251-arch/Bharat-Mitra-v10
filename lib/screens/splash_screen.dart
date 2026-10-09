import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bharat_mitra_home.dart';
import '../widgets/admin_login_dialog.dart';
import '../widgets/active_radar_pulse.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _adminUnlocked = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation for logo
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    // Auto navigate after 3.5 seconds directly to BharatMitraHome without black loading pause
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted && !_adminUnlocked) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BharatMitraHome()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Silent 7-second Admin Unlock fallback
      onLongPressStart: (_) async {
        await Future.delayed(const Duration(seconds: 7));
        if (mounted) {
          setState(() => _adminUnlocked = true);
          HapticFeedback.heavyImpact();
          AdminLoginDialog.show(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with smooth pulse animation
              ActiveRadarPulse(
                ringColor: const Color(0xFFFF9933),
                maxRadius: 85,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9933).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.handshake,
                          color: Color(0xFFFF9933),
                          size: 70,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Title
              const Text(
                'BHARAT MITRA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 8),

              // Tagline (Point 10)
              const Text(
                'Bharat Mitra - Apno Ka Saath',
                style: TextStyle(
                  color: Color(0xFFFF9933),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              // ISRO NavIC connected badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF138808).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF138808)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.satellite_alt, size: 13, color: Color(0xFF138808)),
                    SizedBox(width: 6),
                    Text(
                      'ISRO Mappls + NavIC Sovereign Connected',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Retain AdminLoginPage compatibility
class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLoginDialog();
  }
}
