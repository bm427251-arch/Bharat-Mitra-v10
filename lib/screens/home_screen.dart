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
import 'my_trips_screen.dart';
import 'tracking_screen.dart';
import 'rent_drive_screen.dart';
import 'profile_screen.dart';
import 'driver_home_screen.dart';
import 'sevak_home_screen.dart';
import 'rent_owner_home_screen.dart';
import '../services/rating_service.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/admin_login_dialog.dart';

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
  int _selectedServiceCard = 0; // 0: Book Ride, 1: Rent & Drive, 2: Home Service, 3: Hire Driver
  int _bottomNavIndex = 0;
  final TextEditingController _citySearchCtrl = TextEditingController();
  Timer? _adminTimer;
  int _holdCount = 0;
  String adminEmail = "bm427251@gmail.com";
  StreamSubscription? _ratingSubscription;
  bool _isPartnerLiveActive = false;

  void _openAdmin() {
    AdminLoginDialog.show(context);
  }

  @override
  void dispose() {
    _citySearchCtrl.dispose();
    _ratingSubscription?.cancel();
    _adminTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _recalculateDistanceAndFare();
    _fetchCurrentLocation();

    // Listen for driver payment confirmation to show rating popup automatically
    _ratingSubscription = RatingService().onPendingRating.listen((booking) {
      if (mounted) {
        RatingDialog.show(
          context,
          booking: booking,
        );
      }
    });

    // Check if any existing booking is awaiting customer rating
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = RatingService().getPendingRatingForCustomer('user_current');
      if (pending != null && mounted) {
        RatingDialog.show(
          context,
          booking: pending,
        );
      }
    });
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
        title: Row(children: [
          const SizedBox(width: 12),
          GestureDetector(
            onLongPressDown: (_) {
              _holdCount = 0;
              _adminTimer?.cancel();
              _adminTimer = Timer.periodic(const Duration(seconds: 1), (t) {
                _holdCount++;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Admin: $_holdCount/7 sec..."), duration: const Duration(seconds: 1)),
                );
                if (_holdCount >= 7) {
                  t.cancel();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _openAdmin();
                }
              });
            },
            onLongPressUp: () {
              if (_holdCount < 7) _adminTimer?.cancel();
            },
            child: Image.asset(
              'assets/images/logo.png',
              width: 42,
              height: 42,
              errorBuilder: (c, e, s) => const Icon(Icons.handshake, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'BHARAT MITRA',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          GestureDetector(
            onTap: _fetchCurrentLocation,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
            tooltip: 'My Bookings / Trips',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyTripsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ]),
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

            // MY PROFILE - RESTORED ✅
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1A3A6E).withOpacity(0.3), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "MY PROFILE",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A3A6E)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text("Join as Driver", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3A6E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/driver-register'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.handyman, size: 18),
                          label: const Text("Join as Sevak", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/sevak-register'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text("Create profile to start receiving booking requests", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 12),

                  // BIG SWITCH: Active - ON/OFF (Requirement 2 & 6)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isPartnerLiveActive ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isPartnerLiveActive ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isPartnerLiveActive ? Icons.wifi_tethering_rounded : Icons.wifi_tethering_off_rounded,
                          color: _isPartnerLiveActive ? const Color(0xFF16A34A) : Colors.grey,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isPartnerLiveActive ? "You are Live - Party can see you 🟢" : "You are Offline ⚪",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _isPartnerLiveActive ? const Color(0xFF15803D) : Colors.grey.shade800,
                                ),
                              ),
                              const Text(
                                "Customers can see your live location when Active",
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isPartnerLiveActive,
                          activeColor: const Color(0xFF16A34A),
                          onChanged: (val) async {
                            setState(() => _isPartnerLiveActive = val);
                            if (val) {
                              await LocationService.instance.startLiveLocationUpdates(
                                userId: 'driver_current',
                                userName: 'Bharat Partner (Me)',
                                userType: 'driver',
                                serviceType: 'book_ride',
                                vehicleNumber: 'WB 02 CZ 9012',
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('You are Live - Party can see you 🟢 (Live location sharing started)'),
                                    backgroundColor: Color(0xFF16A34A),
                                  ),
                                );
                              }
                            } else {
                              await LocationService.instance.stopLiveLocationUpdates('driver_current');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('You are Offline ⚪'),
                                    backgroundColor: Colors.grey,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  // Short actions row: My Bookings & Party Live Tracking Map
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MyTripsScreen()),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5FD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_rounded, size: 16, color: Color(0xFF1A3A6E)),
                                SizedBox(width: 6),
                                Text(
                                  'My Bookings',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TrackingScreen(
                                  serviceType: 'book_ride',
                                  partnerId: 'd1',
                                  partnerName: 'Rajesh Das',
                                  partnerPhone: '+91 98301 23456',
                                  vehicleInfo: 'Bike • WB 02 BB 1024',
                                  pickupAddress: 'Howrah Station, Kolkata',
                                  dropAddress: 'Park Street, Kolkata',
                                  fare: 45.0,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map_rounded, size: 16, color: Color(0xFF047857)),
                                SizedBox(width: 6),
                                Text(
                                  'Live Track 🗺️',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SEARCH BAR FOR CITY (Requirement 1)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Color(0xFF1A3A6E), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _citySearchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search City (e.g. Digha, Darjeeling, Puri, Goa...)',
                        hintStyle: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RentDriveScreen()),
                          );
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.explore_rounded, color: Color(0xFF1A3A6E), size: 20),
                    tooltip: 'Explore Pan-India Rentals & Rides',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RentDriveScreen()),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms),

            const SizedBox(height: 8),

            // Pan-India Popular City Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  'All India', 'Digha', 'Darjeeling', 'Puri', 'Goa', 'Manali', 'Jaipur', 'Kolkata', 'Delhi', 'Mumbai',
                ].map((city) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      label: Text(city, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      backgroundColor: const Color(0xFFF1F5F9),
                      side: BorderSide(color: Colors.grey.shade300, width: 0.8),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      onPressed: () {
                        setState(() {
                          _citySearchCtrl.text = city;
                          _dropAddress = '$city Center';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Selected City: $city (Pan India Service Active)'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // 4 SERVICE CARDS (2x2 Grid):
            // 1. Book Ride (Bike/Toto/Auto)
            // 2. Rent & Drive (Self-Drive Pan India)
            // 3. Home Service (Sevak)
            // 4. Hire Driver
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Row 1: Book Ride & Rent & Drive
                  Row(
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

                      // Card 2: Rent & Drive (Self-Drive Pan India)
                      Expanded(
                        child: _buildServiceCard(
                          index: 1,
                          title: 'Rent & Drive',
                          badge: 'PAN INDIA',
                          subtitle: 'Self-Drive Bike / Car',
                          icon: Icons.car_rental_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC2410C), Color(0xFFEA580C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: () {
                            setState(() => _selectedServiceCard = 1);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RentDriveScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Row 2: Home Service & Hire Driver
                  Row(
                    children: [
                      // Card 3: Home Service (Sevak)
                      Expanded(
                        child: _buildServiceCard(
                          index: 2,
                          title: 'home_services'.tr(),
                          badge: '0% CUT',
                          subtitle: 'Electrician, AC, Plumber',
                          icon: Icons.home_repair_service_rounded,
                          gradient: AppColors.orangeGradient,
                          onTap: () {
                            setState(() => _selectedServiceCard = 2);
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

                      // Card 4: Hire Driver ₹700/8Hrs
                      Expanded(
                        child: _buildServiceCard(
                          index: 3,
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
                            setState(() => _selectedServiceCard = 3);
                            _showHireDriverDialog();
                          },
                        ),
                      ),
                    ],
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

                  // Drop Location Field with direct typing + Autocomplete (Requirement 2)
                  Row(
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
                        child: Autocomplete<String>(
                          initialValue: TextEditingValue(text: _dropAddress),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            final query = textEditingValue.text.trim();
                            const List<String> popularDestinations = [
                              'Behala, Kolkata',
                              'Digha Sea Beach',
                              'Salt Lake Sector V, Kolkata',
                              'Howrah Railway Station',
                              'Park Street, Kolkata',
                              'Kolkata Airport (CCU)',
                              'Puri Sea Beach, Odisha',
                              'Darjeeling Mall Road',
                              'Baga Beach, North Goa',
                              'Mall Road, Manali',
                              'Hawa Mahal, Jaipur',
                              'Connaught Place, Delhi',
                              'Marine Drive, Mumbai',
                            ];
                            if (query.isEmpty) {
                              return popularDestinations.take(5);
                            }
                            final filtered = popularDestinations
                                .where((s) => s.toLowerCase().contains(query.toLowerCase()))
                                .toList();
                            filtered.add("Use: \"$query\"");
                            return filtered;
                          },
                          onSelected: (String selection) {
                            final actual = selection.startsWith("Use: \"") && selection.endsWith("\"")
                                ? selection.substring(6, selection.length - 1)
                                : selection;
                            setState(() {
                              _dropAddress = actual;
                              _recalculateDistanceAndFare();
                            });
                          },
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            if (controller.text.isEmpty && _dropAddress.isNotEmpty && !_dropAddress.startsWith('Where to')) {
                              controller.text = _dropAddress;
                            }
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                labelText: 'drop_location'.tr().toUpperCase(),
                                labelStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                  letterSpacing: 0.5,
                                ),
                                hintText: 'Type Drop Location - e.g. Behala, Digha Sea Beach',
                                hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              onChanged: (val) {
                                if (val.trim().isNotEmpty) {
                                  _dropAddress = val.trim();
                                  _recalculateDistanceAndFare();
                                }
                              },
                              onSubmitted: (val) {
                                if (val.trim().isNotEmpty) {
                                  setState(() {
                                    _dropAddress = val.trim();
                                    _recalculateDistanceAndFare();
                                  });
                                }
                              },
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.map_rounded, color: AppColors.textMuted, size: 22),
                        tooltip: 'Pick on Map',
                        onPressed: _openDropMapPicker,
                      ),
                    ],
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
      bottomNavigationBar: _buildBottomDualModeAndNav(context),
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

  Widget _buildBottomDualModeAndNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // DUAL MODE SWITCH BAR: [I am Customer] [I am Provider] - ALWAYS VISIBLE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person, size: 18),
                      label: const Text(
                        'I am Customer',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3A6E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        // Already in Customer mode
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.handyman, size: 18),
                      label: const Text(
                        'I am Provider',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1A3A6E), width: 1.5),
                        foregroundColor: const Color(0xFF1A3A6E),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _showProviderSwitchBottomSheet,
                    ),
                  ),
                ],
              ),
            ),

            // BOTTOM NAVIGATION: Home, Bookings, Profile
            BottomNavigationBar(
              currentIndex: _bottomNavIndex,
              selectedItemColor: const Color(0xFF1A3A6E),
              unselectedItemColor: Colors.grey.shade500,
              backgroundColor: Colors.white,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              onTap: (index) {
                setState(() => _bottomNavIndex = index);
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyTripsScreen()),
                  ).then((_) {
                    if (mounted) setState(() => _bottomNavIndex = 0);
                  });
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ).then((_) {
                    if (mounted) setState(() => _bottomNavIndex = 0);
                  });
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_rounded),
                  activeIcon: Icon(Icons.receipt_long_rounded),
                  label: 'Bookings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProviderSwitchBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Switch to Provider Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A3A6E),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select your partner role to manage booking requests and live GPS location:',
                style: TextStyle(fontSize: 12.5, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF1A3A6E).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.directions_car_filled_rounded, color: Color(0xFF1A3A6E)),
                ),
                title: const Text('Driver Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: const Text('Bike, Toto, Auto, Sedan, Personal Driver', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF0F766E).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.handyman_rounded, color: Color(0xFF0F766E)),
                ),
                title: const Text('Sevak Partner Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: const Text('Electrician, Plumber, AC Repair & Home Specialist', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SevakHomeScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFC2410C).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.car_rental_rounded, color: Color(0xFFC2410C)),
                ),
                title: const Text('Rent Vehicle Owner Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: const Text('Manage Self-Drive fleet (Bikes, Scooters, Cars)', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RentOwnerHomeScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
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
