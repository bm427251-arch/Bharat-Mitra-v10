import 'package:flutter/material.dart';
import 'home_ride_page.dart';
import 'screens/my_trips_screen.dart';
import 'screens/admin_earnings_screen.dart';
import 'screens/my_profiles_overview_screen.dart';

/// Bharat Mitra V10 - Main Navigation Shell
/// 
/// Point 3 & 4: Clean 4-tab bottom navigation (Home, Rides, Earnings, Profile)
/// - Home tab displays strictly the sovereign map and ride booking UI
/// - All service menus and provider profile tools are centralized in the Profile tab
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
    _pages = const [
      HomeRidePage(),
      MyTripsScreen(),
      AdminEarningsScreen(),
      MyProfilesOverviewScreen(),
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
    // Filter items to ensure no item has an empty or blank label
    final List<BottomNavigationBarItem> navItems = const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.two_wheeler), label: 'Rides'),
      BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Earnings'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ].where((e) => e.label != null && e.label!.isNotEmpty).toList();

    return Scaffold(
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
        currentIndex: _index % navItems.length,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFFFF9933),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        onTap: (i) => _navigateToTab(i),
        items: navItems,
      ),
    );
  }
}

/// HomeDashboard compatibility wrapper
/// Directs immediately to Map & Ride Booking UI
class HomeDashboard extends StatelessWidget {
  final Function(int)? onSelectTab;

  const HomeDashboard({super.key, this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    return const HomeRidePage();
  }
}
