import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../theme/app_theme.dart';
import '../models/ride_model.dart';
import '../config/fare_config.dart';
import '../services/location_service.dart';
import 'map_picker_screen.dart';
import 'active_drivers_screen.dart';
import 'sebak_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _pickupAddress = 'Detecting current GPS location...';
  String _dropAddress = 'Salt Lake Sector V, Bidhannagar, Kolkata';
  double _pickupLat = LocationService.defaultLat;
  double _pickupLng = LocationService.defaultLng;
  double _dropLat = LocationService.defaultDropLat;
  double _dropLng = LocationService.defaultDropLng;
  double _distanceKm = 4.2;

  RideOption _selectedRide = RideOption.availableRides.first;
  bool _isLocating = false;
  bool _isSatelliteMap = false;
  int _selectedServiceCard = 0; // 0: Book a Ride, 1: Home Services, 2: Hire a Driver
  Timer? _adminTimer;

  @override
  void dispose() {
    _adminTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _recalculateDistanceAndFare();
    _fetchCurrentLocation();
  }

  /// Calculates dynamic geodesic distance via Geolocator.distanceBetween
  void _recalculateDistanceAndFare() {
    try {
      final double distanceInMeters = Geolocator.distanceBetween(
        _pickupLat,
        _pickupLng,
        _dropLat,
        _dropLng,
      );
      double km = distanceInMeters / 1000.0;
      if (km < 0.1) {
        km = 4.2; // Default realistic city route distance
      }
      setState(() {
        _distanceKm = km;
      });
    } catch (e) {
      debugPrint('Distance calculation error: $e');
      setState(() {
        _distanceKm = 4.2;
      });
    }
  }

  /// Current dynamically computed fare based on distance and selected vehicle
  double get _currentFare => FareConfig.getFareForVehicle(_selectedRide.id, _distanceKm);

  /// Live Route & Fare String e.g. "Distance: 4.2 KM | Fare ₹138"
  String get _liveDistanceFareText =>
      'Distance: ${_distanceKm.toStringAsFixed(1)} KM | Fare ₹${_currentFare.round()}';

  /// Get real GPS via Geolocator.getCurrentPosition() and live address via placemarkFromCoordinates
  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final res = await LocationService.getCurrentLocation();
        if (mounted) {
          setState(() {
            _isLocating = false;
            _pickupAddress = res.formattedAddress;
            _pickupLat = res.latitude;
            _pickupLng = res.longitude;
            _recalculateDistanceAndFare();
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        final res = await LocationService.getCurrentLocation();
        if (mounted) {
          setState(() {
            _isLocating = false;
            _pickupAddress = res.formattedAddress;
            _pickupLat = res.latitude;
            _pickupLng = res.longitude;
            _recalculateDistanceAndFare();
          });
        }
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      String formattedAddr =
          'Live GPS (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = <String>[];
          if (p.street != null && p.street!.isNotEmpty) parts.add(p.street!);
          if (p.subLocality != null && p.subLocality!.isNotEmpty) parts.add(p.subLocality!);
          if (p.locality != null && p.locality!.isNotEmpty) parts.add(p.locality!);
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) {
            parts.add(p.administrativeArea!);
          }
          if (parts.isNotEmpty) {
            formattedAddr = parts.join(', ');
          }
        }
      } catch (geocodeErr) {
        debugPrint('Geocoding error: $geocodeErr');
      }

      if (mounted) {
        setState(() {
          _isLocating = false;
          _pickupLat = position.latitude;
          _pickupLng = position.longitude;
          _pickupAddress = formattedAddr;
          _recalculateDistanceAndFare();
        });
      }
    } catch (e) {
      debugPrint('Geolocator fetch error: $e');
      final res = await LocationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _isLocating = false;
          _pickupAddress = res.formattedAddress;
          _pickupLat = res.latitude;
          _pickupLng = res.longitude;
          _recalculateDistanceAndFare();
        });
      }
    }
  }

  /// Open full-screen interactive Map Picker for Pickup
  void _openPickupMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          title: 'pickup_location'.tr(),
          initialLat: _pickupLat,
          initialLng: _pickupLng,
          initialAddress: _pickupAddress,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _pickupAddress = result['address'] ?? _pickupAddress;
        _pickupLat = (result['lat'] as num?)?.toDouble() ?? _pickupLat;
        _pickupLng = (result['lng'] as num?)?.toDouble() ?? _pickupLng;
        _recalculateDistanceAndFare();
      });
    }
  }

  /// Open full-screen interactive Map Picker for Drop
  void _openDropMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          title: 'drop_location'.tr(),
          initialLat: _dropLat,
          initialLng: _dropLng,
          initialAddress: _dropAddress,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _dropAddress = result['address'] ?? _dropAddress;
        _dropLat = (result['lat'] as num?)?.toDouble() ?? _dropLat;
        _dropLng = (result['lng'] as num?)?.toDouble() ?? _dropLng;
        _recalculateDistanceAndFare();
      });
    }
  }

  void _onBookRideNow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveDriversScreen(
          rideOption: _selectedRide,
          pickupAddress: _pickupAddress,
          dropAddress: _dropAddress,
        ),
      ),
    );
  }

  void _showHireDriverDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.airline_seat_recline_normal_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'hire_driver'.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '₹700 / 8 Hours (Fixed Rate)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'hire_driver_desc'.tr(),
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                    ),
                    const Divider(height: 18),
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                        SizedBox(width: 6),
                        Text('RTO police verified drivers', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                        SizedBox(width: 6),
                        Text('Manual & Automatic transmission expertise', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                        SizedBox(width: 6),
                        Text('0% Commission: Direct cash/UPI to driver', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppTheme.primaryGradientButton(
                text: 'Hire Personal Driver (₹700)',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Personal driver request posted! Nearby verified drivers notified.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A6E),
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const SizedBox(width: 12),
            // LOGO - Left side with 7 sec admin
            GestureDetector(
              onLongPressStart: (_) {
                debugPrint("Admin hold started...");
                _adminTimer = Timer(const Duration(seconds: 7), () {
                  // Admin ID: bm427251@gmail.com
                  Navigator.pushNamed(context, '/admin-login', arguments: {
                    'admin_email': 'bm427251@gmail.com'
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Admin Mode Unlocked 🔓 bm427251@gmail.com"))
                  );
                });
              },
              onLongPressEnd: (_) {
                _adminTimer?.cancel();
              },
              onLongPressCancel: () {
                _adminTimer?.cancel();
              },
              child: Image.asset(
                'assets/images/logo.png',
                width: 42,
                height: 42,
                errorBuilder: (c, e, s) => const Icon(Icons.handshake, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(width: 10),
            // CENTER BIG TEXT
            const Expanded(
              child: Text(
                'BHARAT MITRA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            GestureDetector(
              onTap: _fetchCurrentLocation,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "0% Commission" banner: Gradient light green to light blue with border & icon
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.commissionBannerGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.35),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000), // radius 20 shadow blur 20
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.percent_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '0% Commission Platform',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF065F46),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'commission_banner'.tr(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF059669),
                    size: 24,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.1, end: 0),

            // 3 SERVICE CARDS:
            // 1. "Book a Ride"
            // 2. "Home Services"
            // 3. "Hire a Driver ₹700/8Hrs"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Card 1: Book a Ride
                  Expanded(
                    child: _buildServiceCard(
                      index: 0,
                      title: 'book_ride'.tr(),
                      subtitle: 'Bike, Toto, Auto, Car',
                      icon: Icons.directions_car_filled_rounded,
                      gradient: AppColors.primaryGradient,
                      onTap: () {
                        setState(() => _selectedServiceCard = 0);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Card 2: Home Services
                  Expanded(
                    child: _buildServiceCard(
                      index: 1,
                      title: 'home_services'.tr(),
                      subtitle: 'Electrician, AC...',
                      icon: Icons.home_repair_service_rounded,
                      gradient: AppColors.orangeGradient,
                      onTap: () {
                        setState(() => _selectedServiceCard = 1);
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(1);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SebakListScreen()),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Card 3: Hire a Driver ₹700/8Hrs
                  Expanded(
                    child: _buildServiceCard(
                      index: 2,
                      title: 'hire_driver'.tr(),
                      badge: '₹700',
                      subtitle: '8 Hours Shift',
                      icon: Icons.airline_seat_recline_normal_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        setState(() => _selectedServiceCard = 2);
                        _showHireDriverDialog();
                      },
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 20),

            // Pickup / Drop Location Fields
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.premiumCardDecoration(radius: 20),
              child: Column(
                children: [
                  // Pickup Field
                  InkWell(
                    onTap: _openPickupMapPicker,
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F1FD),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'pickup_location'.tr().toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _pickupAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.map_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      ],
                    ),
                  ),

                  // Connecting divider
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                    child: Row(
                      children: [
                        Container(width: 2, height: 24, color: AppColors.border),
                        const SizedBox(width: 24),
                        const Expanded(child: Divider(height: 1)),
                      ],
                    ),
                  ),

                  // Drop Field
                  InkWell(
                    onTap: _openDropMapPicker,
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF4EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.secondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'drop_location'.tr().toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _dropAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _dropAddress.startsWith('Where to')
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.textMuted,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

            const SizedBox(height: 14),

            // LIVE MAP TRACKER CARD with Standard vs Satellite Toggle
            _buildLiveMapTrackerCard(),

            const SizedBox(height: 20),

            // Select Ride Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'select_ride'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'direct_pay'.tr(),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Horizontal Ride Selector: 5 options (Bike, Toto, Auto, Sedan, XL SUV)
            // Dynamically calculated per-km fare: base + (perKm * km)
            SizedBox(
              height: 125,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: RideOption.availableRides.length,
                itemBuilder: (context, index) {
                  final ride = RideOption.availableRides[index];
                  final isSelected = _selectedRide.id == ride.id;
                  final int dynamicFare = FareConfig.getFareForVehicle(ride.id, _distanceKm).round();

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRide = ride;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 120,
                      height: 110,
                      margin: const EdgeInsets.only(right: 12, top: 4, bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: isSelected
                          ? BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x330B2E6E),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            )
                          : BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                ride.icon,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                                size: 28,
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ride.title,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹$dynamicFare',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected ? AppColors.secondaryLight : AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    ride.eta,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: isSelected ? Colors.white70 : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            const SizedBox(height: 22),

            // Book Ride Now Gradient Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  AppTheme.primaryGradientButton(
                    text: '${'book_now'.tr()} (₹${_currentFare.round()})',
                    icon: Icon(_selectedRide.icon, color: Colors.white, size: 22),
                    onPressed: _onBookRideNow,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        '0% Surge • Direct Cash/UPI • Verified Partners',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }

  /// Live Map Tracker Card with Standard / Satellite style toggle button
  Widget _buildLiveMapTrackerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _isSatelliteMap ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isSatelliteMap
              ? AppColors.secondary.withOpacity(0.4)
              : AppColors.primary.withOpacity(0.18),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row with Live Status, Fare & Style Toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _isSatelliteMap
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE8F1FD),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.navigation_rounded,
                    color: _isSatelliteMap ? AppColors.secondaryLight : AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _isSatelliteMap ? 'SATELLITE LIVE TRACKER' : 'LIVE GPS ROUTE',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: _isSatelliteMap
                                  ? const Color(0xFF34D399)
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _liveDistanceFareText,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: _isSatelliteMap ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Map Style Toggle Button: Standard <-> Satellite
                InkWell(
                  onTap: () {
                    setState(() {
                      _isSatelliteMap = !_isSatelliteMap;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isSatelliteMap
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isSatelliteMap ? AppColors.secondary : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isSatelliteMap
                              ? Icons.satellite_alt_rounded
                              : Icons.map_rounded,
                          size: 15,
                          color: _isSatelliteMap
                              ? AppColors.secondaryLight
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _isSatelliteMap ? 'Satellite' : 'Standard',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: _isSatelliteMap ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Embedded Visual Live Route Map (Custom Canvas)
          GestureDetector(
            onTap: _openDropMapPicker,
            child: Container(
              height: 120,
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isSatelliteMap
                      ? Colors.white12
                      : AppColors.border,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RouteMiniMapPainter(
                        isSatellite: _isSatelliteMap,
                        vehicleIcon: _selectedRide.icon,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Tap to adjust pin',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 180.ms);
  }

  Widget _buildServiceCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    String? badge,
  }) {
    final isSelected = _selectedServiceCard == index;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : const Color(0xFF0F766E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF0F766E) : Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white.withOpacity(0.85)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteMiniMapPainter extends CustomPainter {
  final bool isSatellite;
  final IconData vehicleIcon;

  _RouteMiniMapPainter({
    required this.isSatellite,
    required this.vehicleIcon,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isSatellite) {
      // Dark aerial imagery tone
      final bg = Paint()..color = const Color(0xFF0F1E19);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

      // Satellite vegetation & terrain patches
      final patchPaint = Paint()
        ..color = const Color(0xFF1B382B).withOpacity(0.7)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.35), 60, patchPaint);
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.65), 75, patchPaint);
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.85), 50, patchPaint);

      // Road background in satellite mode
      final roadPaint = Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      final routePath = Path();
      routePath.moveTo(size.width * 0.15, size.height * 0.7);
      routePath.cubicTo(
        size.width * 0.4,
        size.height * 0.2,
        size.width * 0.6,
        size.height * 0.9,
        size.width * 0.85,
        size.height * 0.35,
      );
      canvas.drawPath(routePath, roadPaint);

      // Glowing neon cyan polyline
      final glowPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(routePath, glowPaint);
    } else {
      // Light modern vector map
      final bg = Paint()..color = const Color(0xFFF8FAFC);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

      // City grid lines
      final gridPaint = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..strokeWidth = 1.5;
      for (double x = 0; x < size.width; x += 35) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      for (double y = 0; y < size.height; y += 35) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }

      // Road background
      final roadPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 16
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final roadBorder = Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final routePath = Path();
      routePath.moveTo(size.width * 0.15, size.height * 0.7);
      routePath.cubicTo(
        size.width * 0.4,
        size.height * 0.2,
        size.width * 0.6,
        size.height * 0.9,
        size.width * 0.85,
        size.height * 0.35,
      );
      canvas.drawPath(routePath, roadBorder);
      canvas.drawPath(routePath, roadPaint);

      // Polyline route
      final linePaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(routePath, linePaint);
    }

    // Pickup pin (blue)
    final pickupOffset = Offset(size.width * 0.15, size.height * 0.7);
    canvas.drawCircle(pickupOffset, 8, Paint()..color = AppColors.primary);
    canvas.drawCircle(pickupOffset, 3.5, Paint()..color = Colors.white);

    // Drop pin (saffron orange)
    final dropOffset = Offset(size.width * 0.85, size.height * 0.35);
    canvas.drawCircle(dropOffset, 9, Paint()..color = AppColors.secondary);
    canvas.drawCircle(dropOffset, 4, Paint()..color = Colors.white);

    // Midpoint vehicle indicator
    final midOffset = Offset(size.width * 0.5, size.height * 0.55);
    canvas.drawCircle(
      midOffset,
      12,
      Paint()
        ..color = (isSatellite ? const Color(0xFF38BDF8) : AppColors.primary)
            .withOpacity(0.3),
    );
    canvas.drawCircle(midOffset, 8, Paint()..color = AppColors.primary);
    canvas.drawCircle(midOffset, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _RouteMiniMapPainter oldDelegate) {
    return oldDelegate.isSatellite != isSatellite || oldDelegate.vehicleIcon != vehicleIcon;
  }
}
