import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bharat_mitra_home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BharatMitraHome()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // YOUR NEW IMAGE
          Image.asset(
            'assets/images/836896661_2152254228974377_7609738211549746421_n.webp',
            fit: BoxFit.cover,
          ),

          // Dark Overlay for Text Visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Logo Text
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'BHARAT MITRA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
                const SizedBox(height: 8),
                const Text(
                  '0% Commission Platform',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 30),
                const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    .animate().fadeIn(delay: 1000.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
