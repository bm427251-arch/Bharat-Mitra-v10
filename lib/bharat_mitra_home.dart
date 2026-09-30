import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common_widgets.dart';
import 'home_ride_page.dart';
import 'technician_page.dart';
import 'professional_page.dart';
import 'outstation_page.dart';
import 'elite_sos_page.dart';
import 'screens/become_driver_screen.dart';
import 'screens/become_sebak_screen.dart';
import 'screens/service_provider_profile_screen.dart';
import 'screens/owner_add_vehicle_screen.dart';
import 'screens/company_post_job_screen.dart';
import 'screens/my_profiles_overview_screen.dart';
import 'widgets/admin_login_dialog.dart';
import 'job_dashboard_page.dart';
import 'isro_map_page.dart';

class BharatMitraHome extends StatefulWidget {
  const BharatMitraHome({super.key});

  @override
  _BharatMitraHomeState createState() => _BharatMitraHomeState();
}

class _BharatMitraHomeState extends State<BharatMitraHome> {
  int _index = 0;
  late final PageController _pageController;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _index);
    _pages = [
      HomeDashboard(onSelectTab: (i) => _navigateToTab(i)),
      const HomeRidePage(),
      const TechnicianPage(),
      const ProfessionalPage(),
      const OutstationPage(),
      const EliteSOSPage(),
      const JobDashboardPage(),
      const MyProfilesOverviewScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToTab(int i) {
    final targetIndex = (i % _pages.length);
    setState(() => _index = targetIndex);
    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Point 7: Sequential Left-Right Swipe with PageView
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (i) {
          setState(() => _index = i % _pages.length);
        },
        itemBuilder: (context, index) {
          return _pages[index % _pages.length];
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index % _pages.length,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFFFF9933),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        onTap: (i) => _navigateToTab(i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.two_wheeler), label: 'Ride'),
          BottomNavigationBarItem(icon: Icon(Icons.handyman), label: 'Tech'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Pro'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Outstation'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Elite'),
          BottomNavigationBarItem(icon: Icon(Icons.business_center), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  final Function(int)? onSelectTab;

  const HomeDashboard({super.key, this.onSelectTab});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  Timer? _silentAdminTimer;

  @override
  void dispose() {
    _silentAdminTimer?.cancel();
    super.dispose();
  }

  void _startSilentAdminTimer() {
    _silentAdminTimer?.cancel();
    // Point 8: Silent Admin: Top logo long press 7 seconds = Admin entry (SILENT, no visual clue)
    _silentAdminTimer = Timer(const Duration(seconds: 7), () {
      HapticFeedback.heavyImpact();
      AdminLoginDialog.show(context);
    });
  }

  void _cancelSilentAdminTimer() {
    _silentAdminTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          const CustomPaint(size: Size.infinite, painter: TricolorWatermarkPainter()),
          const BharatMitraWatermark(),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(15, 50, 15, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP LOGO ROW WITH 7-SECOND SILENT ADMIN TRIGGER
                GestureDetector(
                  onTapDown: (_) => _startSilentAdminTimer(),
                  onTapUp: (_) => _cancelSilentAdminTimer(),
                  onTapCancel: () => _cancelSilentAdminTimer(),
                  onLongPressStart: (_) => _startSilentAdminTimer(),
                  onLongPressEnd: (_) => _cancelSilentAdminTimer(),
                  onLongPressCancel: () => _cancelSilentAdminTimer(),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 38,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.handshake,
                          color: Color(0xFFFF9933),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BHARAT MITRA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Apno Ka Saath • ISRO NavIC Connected',
                            style: TextStyle(
                              color: Color(0xFFFF9933),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // SEARCH BAR
                TextField(
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search Ride, Plumber, Advocate, Toto, SOS...',
                    hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFFF9933)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ALL SERVICES DASHBOARD
                const Text(
                  'All Services Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),

                // SERVICES GRID (PRICE POLICY GLOBAL: NO PRICE ON CARDS)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.3,
                  children: [
                    _card(
                      'Ride Booking',
                      '5% Cheaper than Other Apps',
                      Icons.two_wheeler,
                      Colors.orange,
                      onTap: () => widget.onSelectTab?.call(1),
                    ),
                    _card(
                      'Technicians',
                      'Verified Home Experts',
                      Icons.handyman,
                      Colors.blue,
                      onTap: () => widget.onSelectTab?.call(2),
                    ),
                    _card(
                      'Professionals',
                      'Advocate, CA, Doctor, Beautician',
                      Icons.work,
                      Colors.purple,
                      onTap: () => widget.onSelectTab?.call(3),
                    ),
                    _card(
                      'Outstation + Rural',
                      'Bike, Car, Auto, Toto',
                      Icons.directions_car,
                      Colors.green,
                      onTap: () => widget.onSelectTab?.call(4),
                    ),
                    _card(
                      'Elite SOS Group',
                      '24H Live NavIC Tracking',
                      Icons.shield,
                      Colors.red,
                      onTap: () => widget.onSelectTab?.call(5),
                    ),
                    _card(
                      'Job Dashboard',
                      'Double Wall • Candidate & Company',
                      Icons.business_center,
                      Colors.teal,
                      onTap: () => widget.onSelectTab?.call(6),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // PROVIDER PROFILE SHORTCUTS
                const Text(
                  'Provider? Create Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('Become Driver'),
                      avatar: const Icon(Icons.drive_eta, size: 16),
                      backgroundColor: Colors.white10,
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                      side: const BorderSide(color: Colors.white24),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BecomeDriverScreen()),
                        );
                      },
                    ),
                    ActionChip(
                      label: const Text('Become Technician'),
                      avatar: const Icon(Icons.build, size: 16),
                      backgroundColor: Colors.white10,
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                      side: const BorderSide(color: Colors.white24),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BecomeSebakScreen()),
                        );
                      },
                    ),
                    ActionChip(
                      label: const Text('Add Pro Profile'),
                      avatar: const Icon(Icons.badge, size: 16),
                      backgroundColor: Colors.white10,
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                      side: const BorderSide(color: Colors.white24),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ServiceProviderProfileScreen(),
                          ),
                        );
                      },
                    ),
                    ActionChip(
                      label: const Text('Add Vehicle - Toto/Auto/Bike/Car'),
                      avatar: const Icon(Icons.local_taxi, size: 16),
                      backgroundColor: Colors.white10,
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                      side: const BorderSide(color: Colors.white24),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OwnerAddVehicleScreen(),
                          ),
                        );
                      },
                    ),
                    ActionChip(
                      label: const Text('+ Post Job - FREE'),
                      avatar: const Icon(Icons.business_center, size: 16, color: Color(0xFFFF9933)),
                      backgroundColor: const Color(0xFFFF9933).withOpacity(0.18),
                      labelStyle: const TextStyle(
                        color: Color(0xFFFF9933),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      side: const BorderSide(color: Color(0xFFFF9933)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CompanyPostJobScreen(),
                          ),
                        );
                      },
                    ),
                    ActionChip(
                      label: const Text('Job Alerts System'),
                      avatar: const Icon(Icons.notifications_active, size: 16, color: Colors.redAccent),
                      backgroundColor: Colors.red.withOpacity(0.15),
                      labelStyle: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      side: const BorderSide(color: Colors.redAccent),
                      onPressed: () => widget.onSelectTab?.call(6),
                    ),
                    ActionChip(
                      label: const Text('ISRO Mappls + NavIC'),
                      avatar: const Icon(Icons.satellite_alt, size: 16, color: Color(0xFF138808)),
                      backgroundColor: const Color(0xFF138808).withOpacity(0.15),
                      labelStyle: const TextStyle(
                        color: Color(0xFF138808),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      side: const BorderSide(color: Color(0xFF138808)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ISROMapPage(),
                          ),
                        );
                      },
                    ),
                    ActionChip(
                      label: const Text('My Profiles'),
                      avatar: const Icon(Icons.account_circle, size: 16, color: Colors.cyanAccent),
                      backgroundColor: Colors.cyan.withOpacity(0.15),
                      labelStyle: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      side: const BorderSide(color: Colors.cyanAccent),
                      onPressed: () => widget.onSelectTab?.call(7),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String t, String s, IconData i, Color c, {VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.withOpacity(0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(i, color: c, size: 28),
              const SizedBox(height: 6),
              Text(
                t,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
}
