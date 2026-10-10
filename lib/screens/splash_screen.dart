import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.85, end: 1.15).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glow = Tween<double>(begin: 10, end: 35).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.6), blurRadius: _glow.value, spreadRadius: 5)],
                  ),
                  child: Transform.scale(scale: _scale.value, child: child),
                );
              },
              child: ClipOval(
                child: Image.asset('assets/images/logo.png', width: 180, height: 180, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.handshake, size: 100, color: Colors.orange)),
              ),
            ),
            const SizedBox(height: 30),
            const Text('BHARAT MITRA', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 8),
            const Text('0% Commission Platform', style: TextStyle(color: Colors.orange, fontSize: 14, letterSpacing: 1)),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.orange, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
