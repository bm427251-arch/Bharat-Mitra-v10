import 'dart:async';
import 'package:flutter/material.dart';
import '../bharat_mitra_home.dart';
import '../job_dashboard_page.dart';
import 'rent_drive_screen.dart';
import 'sebak_list_screen.dart';
import 'hire_driver_screen.dart';
import 'wallet_screen.dart';
import 'parcel_screen.dart';
import 'admin_screen.dart';
import 'become_driver_screen.dart';
import 'become_sebak_screen.dart';
import 'become_rent_owner_screen.dart';
import 'owner_add_vehicle_screen.dart';
import 'tracking_screen.dart';
import 'profile_screen.dart';
import 'splash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _adminTimer;
  int _currentIndex = 0;

  void _startAdmin() {
    _adminTimer = Timer(const Duration(seconds: 7), () {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen(adminEmail: 'bm427251@gmail.com')));
    });
  }
  void _cancelAdmin() => _adminTimer?.cancel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: GestureDetector(
          onTapDown: (_) => _startAdmin(),
          onTapUp: (_) => _cancelAdmin(),
          onTapCancel: _cancelAdmin,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ClipOval(child: Image.asset('assets/images/logo.png', errorBuilder: (_,__,___) => const Icon(Icons.handshake, color: Colors.orange, size: 24))),
          ),
        ),
        title: const Text('BHARAT MITRA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.35,
              children: [
                _mainCard(Icons.two_wheeler, Colors.orange, 'Ride Booking', '5% Cheaper than Other Apps', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen(serviceType: 'book_ride', partnerId: 'd1', partnerName: 'Rajesh Das', partnerPhone: '+91 98301 23456', vehicleInfo: 'Bike • WB 02 BB 1024', pickupAddress: 'Howrah', dropAddress: 'Park Street', fare: 45.0)));
                }),
                _mainCard(Icons.build, Colors.blue, 'Technicians', 'Verified Home Experts', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SebakListScreen()))),
                _mainCard(Icons.business_center, Colors.purple, 'Professionals', 'Advocate, CA, Doctor...', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SebakListScreen()))),
                _mainCard(Icons.directions_car, Colors.green, 'Outstation + Rural', 'Bike, Car, Auto, Toto', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HireDriverScreen()))),
                _mainCard(Icons.shield, Colors.red, 'Elite SOS Group', '24H Live NavIC Tracking', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
                _mainCard(Icons.work, Colors.teal, 'Job Dashboard', 'Double Wall • Candidate', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobDashboardPage()))),
                _mainCard(Icons.account_balance_wallet, Colors.greenAccent, 'Wallet', 'Balance & History', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()))),
                _mainCard(Icons.local_shipping, Colors.orangeAccent, 'Parcel', 'Courier Delivery', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParcelScreen()))),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Provider? Create Profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _whiteBtn(Icons.directions_car, 'Become Driver', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BecomeDriverScreen()))),
            _whiteBtn(Icons.build, 'Become Technician', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BecomeSebakScreen()))),
            _whiteBtn(Icons.badge, 'Add Pro Profile', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BecomeSebakScreen()))),
            _whiteBtn(Icons.car_rental, 'Add Vehicle - Toto/Auto/Bike/Car', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerAddVehicleScreen()))),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _colorBtn(Icons.work, '+ Post Job - FREE', const Color(0xFFFFE0B2), Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _colorBtn(Icons.notifications, 'Job Alerts System', const Color(0xFFFFCDD2), Colors.red)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _colorBtn(Icons.satellite_alt, 'ISRO Mappls + NavIC', const Color(0xFFC8E6C9), Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _colorBtn(Icons.person, 'My Profiles', const Color(0xFFB2EBF2), Colors.cyan)),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0A0A0A),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) return;
          if (i == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen(serviceType: 'book_ride', partnerId: 'd1', partnerName: 'Rajesh Das', partnerPhone: '+91 98301 23456', vehicleInfo: 'Bike', pickupAddress: 'Howrah', dropAddress: 'Park Street', fare: 45.0)));
          if (i == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const SebakListScreen()));
          if (i == 7) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.two_wheeler), label: 'Ride'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Tech'),
          BottomNavigationBarItem(icon: Icon(Icons.business_center), label: 'Pro'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Outstati...'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Elite'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _mainCard(IconData icon, Color color, String title, String sub, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.4))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }

  Widget _whiteBtn(IconData ic, String t, VoidCallback tap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(onTap: tap, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: Row(children: [Icon(ic, size: 18, color: Colors.black87), const SizedBox(width: 10), Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87))]))),
    );
  }

  Widget _colorBtn(IconData ic, String t, Color bg, Color txt) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Row(children: [Icon(ic, size: 16, color: txt), const SizedBox(width: 6), Expanded(child: Text(t, style: TextStyle(color: txt, fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))]));
  }
}
