import 'package:flutter/material.dart';
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
import 'screens/my_trips_screen.dart';
import 'screens/company_post_job_screen.dart';
import 'job_dashboard_page.dart';
import 'isro_map_page.dart';

class BharatMitraHome extends StatefulWidget {
  const BharatMitraHome({super.key});

  @override
  _BharatMitraHomeState createState() => _BharatMitraHomeState();
}

class _BharatMitraHomeState extends State<BharatMitraHome> {
  int _index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeDashboard(onSelectTab: (i) => setState(() => _index = i)),
      const HomeRidePage(),
      const TechnicianPage(),
      const ProfessionalPage(),
      const OutstationPage(),
      const EliteSOSPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFFFF9933),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.two_wheeler), label: 'Ride'),
          BottomNavigationBarItem(icon: Icon(Icons.handyman), label: 'Technician'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Pro'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Outstation'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Elite'),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  final Function(int)? onSelectTab;

  const HomeDashboard({super.key, this.onSelectTab});

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
                const Row(
                  children: [
                    Icon(Icons.handshake, color: Color(0xFFFF9933)),
                    SizedBox(width: 8),
                    Text(
                      'BHARAT MITRA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
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
                const Text(
                  'All Services Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _card(
                      'Ride Booking',
                      'Bike/Auto/Car - 15% Comm',
                      Icons.two_wheeler,
                      const Color(0xFFFF9933),
                      onTap: () => onSelectTab?.call(1),
                    ),
                    _card(
                      'Technicians',
                      'Plumber etc - 20% Comm',
                      Icons.handyman,
                      Colors.blue,
                      onTap: () => onSelectTab?.call(2),
                    ),
                    _card(
                      'Professionals',
                      'Advocate/CA/Doctor/Photographer - Sub 499',
                      Icons.work,
                      Colors.purple,
                      onTap: () => onSelectTab?.call(3),
                    ),
                    _card(
                      'Outstation + Rural',
                      'Bike/Car/Auto/Toto - Tourist+Gram - Sub',
                      Icons.local_taxi,
                      Colors.green,
                      onTap: () => onSelectTab?.call(4),
                    ),
                    _card(
                      'Elite SOS Group',
                      '29/Member/24H - Live Tracking',
                      Icons.shield,
                      Colors.red,
                      onTap: () => onSelectTab?.call(5),
                    ),
                    _card(
                      'My Dashboard',
                      'My Bookings, Earnings, Groups',
                      Icons.dashboard,
                      Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyTripsScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const JobDashboardPage(),
                          ),
                        );
                      },
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: c, width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(i, color: c),
              const SizedBox(height: 6),
              Text(
                t,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
}
