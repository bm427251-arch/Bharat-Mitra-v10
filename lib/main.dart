import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'l10n/app_translations.dart';
import 'screens/home_ride_screen.dart';
import 'screens/sebak_list_screen.dart';
import 'screens/my_trips_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Safe Firebase initialization
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const BharatMitraApp());
}

class BharatMitraApp extends StatefulWidget {
  const BharatMitraApp({super.key});

  @override
  State<BharatMitraApp> createState() => _BharatMitraAppState();
}

class _BharatMitraAppState extends State<BharatMitraApp> {
  @override
  void initState() {
    super.initState();
    AppTranslations.languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    AppTranslations.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bharat Mitra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeRideScreen(),
    SebakListScreen(),
    MyTripsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildPremiumFloatingBottomNav(),
    );
  }

  Widget _buildPremiumFloatingBottomNav() {
    final navItems = [
      {'title': 'Ride', 'icon': Icons.directions_car_filled_rounded},
      {'title': 'Services', 'icon': Icons.home_repair_service_rounded},
      {'title': 'My Trips', 'icon': Icons.route_rounded},
      {'title': 'Profile', 'icon': Icons.person_rounded},
    ];

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260B2E6E),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final isSelected = _currentIndex == index;
                final item = navItems[index];

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 16 : 12,
                      vertical: 10,
                    ),
                    decoration: isSelected
                        ? BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x330B2E6E),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          )
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 22,
                          color: isSelected ? Colors.white : AppColors.textMuted,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
