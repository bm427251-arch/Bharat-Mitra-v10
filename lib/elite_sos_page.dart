import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'job_dashboard_page.dart';
import 'screens/wallet_screen.dart';
import 'screens/parcel_screen.dart';
import 'screens/profile_screen.dart';
// import 'elite_sos_page.dart'; // Elite file class name mismatch - temporary disabled

class BharatMitraHome extends StatefulWidget {
  const BharatMitraHome({super.key});

  @override
  State<BharatMitraHome> createState() => _BharatMitraHomeState();
}

class _BharatMitraHomeState extends State<BharatMitraHome> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    JobDashboardPage(),
    WalletScreen(),
    ParcelScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work_rounded), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_rounded), label: 'Parcel'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
