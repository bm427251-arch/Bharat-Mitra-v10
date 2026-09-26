import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const BharatMitraApp());
}

class BharatMitraApp extends StatelessWidget {
  const BharatMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bharat Mitra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Deep Bharat Navy Blue
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFFFF9933), // Saffron
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ---------------------------------------------------------
// 1. SPLASH SCREEN (Has "BHARAT MITRA" text + Handshake Icon)
// ---------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainShellScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // India Map Handshake Emblem without text
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'public/assets/app_icon_adaptive.png',
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => const Icon(
                    Icons.handshake_rounded,
                    size: 72,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Brand text strictly on Splash Screen
              const Text(
                'BHARAT MITRA',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Gari Booking • A to Z Sebak',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9933)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 2. MAIN SHELL (Facebook-like navigation, Back button fix)
// ---------------------------------------------------------
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedTab = 0;
  DateTime? _lastBackPressTime;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void _onTabSelected(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  // Double-press back logic like Facebook
  void _handleBackAttempt(bool didPop) {
    if (didPop) return;

    // If on sub-tabs (Sebak, My Bookings, Profile) -> return to Gari Booking (Home)
    if (_selectedTab != 0) {
      setState(() {
        _selectedTab = 0;
      });
      return;
    }

    // If on Home tab: Check double press within 2000ms
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Press again to exit',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Exit app cleanly or minimize to background
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onNavigateToSebak: () => _onTabSelected(1)),
      const SebakScreen(),
      const MyBookingsScreen(),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: _handleBackAttempt,
      child: Scaffold(
        body: screens[_selectedTab],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _selectedTab,
            onDestinationSelected: _onTabSelected,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFDBEAFE),
            elevation: 0,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.local_taxi_outlined),
                selectedIcon: Icon(Icons.local_taxi, color: Color(0xFF1E3A8A)),
                label: 'Gari Booking',
              ),
              NavigationDestination(
                icon: Icon(Icons.handyman_outlined),
                selectedIcon: Icon(Icons.handyman, color: Color(0xFF1E3A8A)),
                label: 'Sebak',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long, color: Color(0xFF1E3A8A)),
                label: 'My Bookings',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: Color(0xFF1E3A8A)),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. HOME SCREEN: 2 BIG CARDS (Gari Book Karun & A to Z Sebak)
// ---------------------------------------------------------
class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToSebak;
  const HomeScreen({super.key, required this.onNavigateToSebak});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _pickupController =
      TextEditingController(text: 'Current Location (GPS Locked)');
  final TextEditingController _dropController =
      TextEditingController(text: 'Railway Station, Main Gate');

  String _selectedVehicle = 'sedan';
  bool _rideBooked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'public/assets/app_icon_adaptive.png',
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.handshake, color: Color(0xFF1E3A8A), size: 20),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bharat Mitra',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '0% Commission on Rides',
                  style: TextStyle(fontSize: 11, color: Color(0xFFFFD166)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 0% Commission Announcement Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: Color(0xFF15803D), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '0% Commission - Driver keeps 100% fare directly',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF14532D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Two Big Cards
            const Text(
              'Select Service',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Card 1: Gari Book Karun
                Expanded(
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E3A8A).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.local_taxi, color: Colors.white, size: 36),
                          SizedBox(height: 12),
                          Text(
                            'Gari Book\nKarun',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Ola/Uber Style',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Card 2: A to Z Sebak
                Expanded(
                  child: InkWell(
                    onTap: widget.onNavigateToSebak,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE65100), Color(0xFFFF9933)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE65100).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.home_repair_service, color: Colors.white, size: 36),
                          SizedBox(height: 12),
                          Text(
                            'A to Z\nSebak',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Electrician, Plumber...',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Car Booking Flow
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Car Booking Flow',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pickupController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.my_location, color: Colors.green),
                      labelText: 'Pickup Location',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dropController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                      labelText: 'Drop Location',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Options
                  const Text('Select Ride:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildVehicleCard('auto', 'Auto', '₹120', Icons.electric_rickshaw),
                      const SizedBox(width: 8),
                      _buildVehicleCard('sedan', 'Sedan', '₹280', Icons.directions_car),
                      const SizedBox(width: 8),
                      _buildVehicleCard('suv', 'XL SUV', '₹450', Icons.airport_shuttle),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _rideBooked = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 Ride Confirmed! Tracking driver on live map.'),
                            backgroundColor: Color(0xFF15803D),
                          ),
                        );
                      },
                      child: const Text(
                        'Book Ride Now',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_rideBooked) ...[
              const SizedBox(height: 16),
              SimulatedLiveMapTracker(
                pickup: _pickupController.text,
                drop: _dropController.text,
                vehicleType: _selectedVehicle,
                onCancel: () {
                  setState(() {
                    _rideBooked = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Ride cancelled')),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(String id, String label, String price, IconData icon) {
    final bool isSelected = _selectedVehicle == id;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedVehicle = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey, size: 28),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(
                price,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// SIMULATED LIVE MAP TRACKER WIDGET
// ---------------------------------------------------------
class SimulatedLiveMapTracker extends StatefulWidget {
  final String pickup;
  final String drop;
  final String vehicleType;
  final VoidCallback onCancel;

  const SimulatedLiveMapTracker({
    super.key,
    required this.pickup,
    required this.drop,
    required this.vehicleType,
    required this.onCancel,
  });

  @override
  State<SimulatedLiveMapTracker> createState() => _SimulatedLiveMapTrackerState();
}

class _SimulatedLiveMapTrackerState extends State<SimulatedLiveMapTracker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _tripStarted = false;
  bool _tripCompleted = false;
  int _selectedRating = 5;
  bool _isRatingSubmitted = false;
  final Set<String> _selectedCompliments = {'Safe Driving', 'Clean Car'};
  int _selectedTip = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    )..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _animation.value;
    final double remainingKm = math.max(0.0, (1.0 - progress) * 1.8);
    final int etaSec = math.max(0, ((1.0 - progress) * 16).ceil());
    final bool hasArrived = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A8A), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Simulation Pill & OTP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Live GPS Tracker',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFFCD34D)),
                    ),
                    child: const Text(
                      'SIMULATION',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Text(
                  'OTP: 4921',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Custom Paint Canvas Map
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 220,
              width: double.infinity,
              color: const Color(0xFFEEF2F6),
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(double.infinity, 220),
                    painter: LiveMapPainter(progress: progress),
                  ),
                  // Top overlay: Driver Info
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xDE0F172A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🚘 Vikram Singh (4.9 ★)',
                            style: TextStyle(
                              color: Color(0xFF93C5FD),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Prime Sedan • DL 01 AB 8492',
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom overlay: ETA & Distance
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                hasArrived ? 'Driver Arrived!' : '${math.max(1, etaSec)}s away',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: hasArrived ? const Color(0xFF15803D) : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '${remainingKm.toStringAsFixed(1)} km to pickup',
                                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                          const SizedBox(width: 6),
                          const Text('🚖', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Trip addresses
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.green, size: 10),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.pickup,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: hasArrived ? const Color(0xFFDCFCE7) : const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        hasArrived ? 'At Pickup' : 'En Route',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: hasArrived ? const Color(0xFF15803D) : const Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.red, size: 10),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.drop,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Arrived & In-Trip Controls
          if (hasArrived && !_tripCompleted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _tripStarted ? const Color(0xFFEFF6FF) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _tripStarted ? const Color(0xFFBFDBFE) : const Color(0xFFA7F3D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _tripStarted ? '🚩 Trip in Progress' : '🟢 Driver Arrived at Pickup!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _tripStarted ? const Color(0xFF1E3A8A) : const Color(0xFF065F46),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: const Text('OTP: 4921', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _tripStarted
                        ? 'Navigating smoothly to drop point. Enjoy the AC ride.'
                        : 'Board car and share OTP with Vikram Singh to start.',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (!_tripStarted)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF15803D), foregroundColor: Colors.white),
                            onPressed: () {
                              setState(() {
                                _tripStarted = true;
                              });
                            },
                            child: const Text('Start Trip'),
                          ),
                        ),
                      if (!_tripStarted) const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
                          onPressed: () {
                            setState(() {
                              _tripCompleted = true;
                            });
                          },
                          child: const Text('Complete Trip & Rate'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // POST-RIDE 5-STAR RATING SYSTEM
          if (_tripCompleted && !_isRatingSubmitted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
                boxShadow: const [BoxShadow(color: Color(0x1AF59E0B), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  const Text(
                    'Trip Completed! How was your ride?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const Text(
                    'Rate Driver Vikram Singh (DL 01 AB 8492)',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 10),

                  // 5 Interactive Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNum = index + 1;
                      return IconButton(
                        iconSize: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        icon: Icon(
                          Icons.star,
                          color: starNum <= _selectedRating ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedRating = starNum;
                          });
                        },
                      );
                    }),
                  ),
                  Text(
                    _selectedRating == 5
                        ? '5.0 ★ Outstanding Experience! 🌟'
                        : (_selectedRating == 4 ? '4.0 ★ Very Good Ride! 😊' : '$_selectedRating.0 ★ Ride Completed'),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A), fontSize: 12),
                  ),
                  const SizedBox(height: 10),

                  // Compliment Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: ['Safe Driving', 'Clean Car', 'Polite Driver', 'On Time', 'AC Cooling'].map((c) {
                      final isSel = _selectedCompliments.contains(c);
                      return ChoiceChip(
                        label: Text(c, style: TextStyle(fontSize: 11, color: isSel ? const Color(0xFF1E3A8A) : Colors.black87)),
                        selected: isSel,
                        selectedColor: const Color(0xFFEFF6FF),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCompliments.add(c);
                            } else {
                              _selectedCompliments.remove(c);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),

                  // Tip Driver
                  const Text('Add Driver Tip', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [0, 10, 20, 50].map((t) {
                      final isSel = _selectedTip == t;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isSel ? const Color(0xFF1E3A8A) : Colors.white,
                            foregroundColor: isSel ? Colors.white : Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedTip = t;
                            });
                          },
                          child: Text(t == 0 ? 'No Tip' : '₹$t', style: const TextStyle(fontSize: 11)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Submit Rating
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.star, size: 18),
                      label: const Text('Submit Rating & Review'),
                      onPressed: () {
                        setState(() {
                          _isRatingSubmitted = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('⭐ Rated Vikram Singh $_selectedRating Stars! Thank you.')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

          // POST-RIDE CONFIRMATION RECEIPT
          if (_isRatingSubmitted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 36),
                  const SizedBox(height: 4),
                  const Text('Rating Submitted!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                    'You rated Vikram Singh $_selectedRating.0 ★',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ride Fare (0% Commission)', style: TextStyle(fontSize: 12)),
                      const Text('₹120', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (_selectedTip > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Driver Tip', style: TextStyle(fontSize: 12)),
                        Text('₹$_selectedTip', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
                      onPressed: widget.onCancel,
                      child: const Text('Book Another Ride'),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Actions
          if (!_tripCompleted) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Call Driver'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('📞 Calling Vikram Singh (+91 98765 12340)...')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: widget.onCancel,
                    child: const Text('Cancel Ride'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Replay Simulation',
                  onPressed: () {
                    setState(() {
                      _tripStarted = false;
                      _tripCompleted = false;
                      _isRatingSubmitted = false;
                    });
                    _controller.reset();
                    _controller.forward();
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// LIVE MAP PAINTER: Renders City Grid, Roads, Pin & Car
// ---------------------------------------------------------
class LiveMapPainter extends CustomPainter {
  final double progress;

  LiveMapPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. City Blocks & Greenery
    final Paint blockPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    final Paint parkPaint = Paint()
      ..color = const Color(0xFFDCFCE7)
      ..style = PaintingStyle.fill;

    // Park
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(80, 50, 70, 40), const Radius.circular(6)),
      parkPaint,
    );

    // Commercial block
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(180, 50, 70, 40), const Radius.circular(6)),
      blockPaint,
    );

    // 2. Road Network Grid
    final Paint roadAsphaltPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint roadCenterLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final List<List<Offset>> roads = [
      [Offset(0, 40), Offset(w, 40)],
      [Offset(0, 110), Offset(w, 110)],
      [Offset(0, 180), Offset(w, 180)],
      [const Offset(60, 0), Offset(60, h)],
      [const Offset(160, 0), Offset(160, h)],
      [const Offset(260, 0), Offset(260, h)],
      [Offset(w - 50, 0), Offset(w - 50, h)],
    ];

    for (final r in roads) {
      canvas.drawLine(r[0], r[1], roadAsphaltPaint);
      canvas.drawLine(r[0], r[1], roadCenterLinePaint);
    }

    // 3. Navigation Waypoints from Driver Start to Pickup
    final List<Offset> waypoints = [
      const Offset(60, 40),
      const Offset(160, 40),
      const Offset(160, 110),
      const Offset(260, 110),
      Offset(w - 50, 110),
    ];

    // Route Polyline (Vibrant Blue)
    final Paint routePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path routePath = Path()..moveTo(waypoints[0].dx, waypoints[0].dy);
    for (int i = 1; i < waypoints.length; i++) {
      routePath.lineTo(waypoints[i].dx, waypoints[i].dy);
    }
    canvas.drawPath(routePath, routePaint);

    // 4. Pickup Pin (Green concentric pulse at Pickup destination)
    final Offset pickupPoint = Offset(w - 50, 110);

    final Paint pulseRing = Paint()
      ..color = const Color(0x6622C55E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(pickupPoint, 16, pulseRing);

    final Paint pickupPin = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pickupPoint, 8, pickupPin);

    final Paint pinCenter = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pickupPoint, 3.5, pinCenter);

    // 5. Driver Vehicle Position & Rotation along Polyline
    final CarTelemetry telemetry = _calculatePositionAlongPolyline(waypoints, progress);

    canvas.save();
    canvas.translate(telemetry.position.dx, telemetry.position.dy);

    // Vehicle Shadow
    final Paint shadowPaint = Paint()..color = const Color(0x33000000);
    canvas.drawOval(const Rect.fromLTWH(-10, 2, 20, 10), shadowPaint);

    // Rotate towards movement direction
    canvas.rotate(telemetry.angle);

    // Cab Body
    final Paint carBody = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-10, -6, 20, 12), const Radius.circular(3)),
      carBody,
    );

    // Roof / Windshield
    final Paint windshield = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-3, -4, 8, 8), const Radius.circular(1.5)),
      windshield,
    );

    canvas.restore();
  }

  CarTelemetry _calculatePositionAlongPolyline(List<Offset> points, double t) {
    double totalLen = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalLen += (points[i + 1] - points[i]).distance;
    }

    final double targetDist = t.clamp(0.0, 1.0) * totalLen;
    double accum = 0;

    for (int i = 0; i < points.length - 1; i++) {
      final double segDist = (points[i + 1] - points[i]).distance;
      if (accum + segDist >= targetDist || i == points.length - 2) {
        final double segProgress = segDist == 0 ? 0 : (targetDist - accum) / segDist;
        final Offset pos = points[i] + (points[i + 1] - points[i]) * segProgress;
        final double angle = math.atan2(
          points[i + 1].dy - points[i].dy,
          points[i + 1].dx - points[i].dx,
        );
        return CarTelemetry(pos, angle);
      }
      accum += segDist;
    }
    return CarTelemetry(points.last, 0.0);
  }

  @override
  bool shouldRepaint(covariant LiveMapPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class CarTelemetry {
  final Offset position;
  final double angle;
  CarTelemetry(this.position, this.angle);
}

// ---------------------------------------------------------
// 4. A TO Z SEBAK SCREEN (All Home Services)
// ---------------------------------------------------------
class SebakScreen extends StatelessWidget {
  const SebakScreen({super.key});

  final List<Map<String, dynamic>> services = const [
    {'name': 'Electrician', 'rate': '₹199 inspection', 'icon': Icons.bolt, 'color': Color(0xFFEAB308)},
    {'name': 'Plumber', 'rate': '₹199 inspection', 'icon': Icons.plumbing, 'color': Color(0xFF0284C7)},
    {'name': 'Carpenter', 'rate': '₹249 inspection', 'icon': Icons.handyman, 'color': Color(0xFFB45309)},
    {'name': 'Painter', 'rate': '₹299 estimate', 'icon': Icons.format_paint, 'color': Color(0xFF9333EA)},
    {'name': 'AC Repair', 'rate': '₹399 servicing', 'icon': Icons.ac_unit, 'color': Color(0xFF06B6D4)},
    {'name': 'Appliance Repair', 'rate': '₹249 visit', 'icon': Icons.tv, 'color': Color(0xFF475569)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('A to Z Sebak Services'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final s = services[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: (s['color'] as Color).withOpacity(0.12),
                  child: Icon(s['icon'] as IconData, color: s['color'] as Color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(s['rate'] as String,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9933),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✓ Booked ${s['name']} Sebak')),
                    );
                  },
                  child: const Text('Book'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------
// 5. MY BOOKINGS SCREEN
// ---------------------------------------------------------
class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBookingCard(
            title: 'Gari Prime Sedan',
            subtitle: 'City Mall → Airport Terminal 2',
            amount: '₹340',
            status: 'Completed',
            statusColor: Colors.green,
            icon: Icons.local_taxi,
          ),
          const SizedBox(height: 12),
          _buildBookingCard(
            title: 'AC Deep Servicing Sebak',
            subtitle: 'Doorstep Service • Sector 4',
            amount: '₹499',
            status: 'Confirmed',
            statusColor: Colors.blue,
            icon: Icons.ac_unit,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard({
    required String title,
    required String subtitle,
    required String amount,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFDBEAFE),
            child: Icon(icon, color: const Color(0xFF1E3A8A)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 6. PROFILE & DRIVER SUBSCRIPTION SCREEN
// ---------------------------------------------------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Subscription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF1E3A8A),
                    child: Text('BM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bharat Mitra User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('+91 98765 43210', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Driver Subscription Section
            const Text(
              'Driver Subscription Plans',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '0% Commission on rides • Unlimited bookings',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 12),

            _buildPlanCard(
              title: '1 Month Plan',
              price: '₹499',
              subtitle: 'Unlimited Rides • 0% Commission',
              isPopular: false,
            ),
            const SizedBox(height: 10),
            _buildPlanCard(
              title: '3 Months Plan',
              price: '₹1299',
              subtitle: 'Save ₹198 • Unlimited Rides',
              isPopular: true,
            ),
            const SizedBox(height: 10),
            _buildPlanCard(
              title: '1 Year Plan',
              price: '₹3999',
              subtitle: 'Best Value • Unlimited Rides',
              isPopular: false,
            ),
            const SizedBox(height: 16),

            // Razorpay Link
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Official Payment Gateway',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  SizedBox(height: 4),
                  Text('https://razorpay.me/@bharatmitrainfotech',
                      style: TextStyle(color: Color(0xFF2563EB), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String subtitle,
    required bool isPopular,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPopular ? const Color(0xFF1E3A8A) : const Color(0xFFE2E8F0),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if (isPopular) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('POPULAR',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ],
          ),
          Text(
            price,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E3A8A)),
          ),
        ],
      ),
    );
  }
}
