import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SPLASH LOGO - White Full Logo
            Image.asset(
              'assets/images/logo.png',
              width: 250,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => Image.asset(
                'assets/images/app_icon.png',
                width: 150,
                errorBuilder: (c2, e2, s2) => const Icon(Icons.handshake, size: 100, color: Color(0xFFFF8C42)),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'BHARAT MITRA',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '0% Commission Platform',
              style: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Color(0xFFFF8C42)),
          ],
        ),
      ),
    );
  }
}
