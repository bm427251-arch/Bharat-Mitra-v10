import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'bharat_mitra_home.dart';
import 'admin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _adminUnlocked = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/splash_logo.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
        }
      }).catchError((error) {
        debugPrint('Splash video player notice: $error');
      });

    Future.delayed(const Duration(seconds: 10), () {
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) async {
        await Future.delayed(const Duration(seconds: 7)); // FINAL 7 SEC - NOT 5 SEC
        if (mounted) {
          setState(() => _adminUnlocked = true);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminLoginPage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFFF9933)),
                    SizedBox(height: 16),
                    Text(
                      'BHARAT MITRA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Zero Commission Platform',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Admin Login - 7 Sec Unlock'),
          backgroundColor: const Color(0xFF1A3A6E),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 64,
                  color: Color(0xFF1A3A6E),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hidden Admin Panel',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A3A6E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Superuser access unlocked via 7-second splash gesture',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3A6E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.dashboard_rounded),
                label: const Text(
                  'Open Full Admin Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminLoginScreen(adminEmail: 'bm427251@gmail.com'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
}
