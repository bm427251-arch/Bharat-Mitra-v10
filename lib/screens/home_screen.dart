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
import 'hire_driver_screen.dart';
import 'wallet_screen.dart';
import 'parcel_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/rating_service.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/admin_login_dialog.dart';
import '../widgets/bharat_mitra_watermark.dart';
import '../services/places_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;
  const HomeScreen({super.key, this.onNavigateTab});
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
  int _selectedServiceCard = 0;
  final TextEditingController _citySearchCtrl = TextEditingController();
  final TextEditingController _dropLocationController = TextEditingController();
  List<PlaceSuggestion> _placeSuggestions = [];
  bool _showPlaceSuggestions = false;
  Timer? _adminTimer;
  int _holdCount = 0;
  bool _isLogoPressing = false;
  String adminEmail = "bm427251@gmail.com";
  StreamSubscription? _ratingSubscription;
  bool _isPartnerLiveActive = false;

  void _openAdmin() { AdminLoginDialog.show(context); }

  @override
  void dispose() {
    _citySearchCtrl.dispose();
    _dropLocationController.dispose();
    _ratingSubscription?.cancel();
    _adminTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _dropLocationController.text = _dropAddress;
    _recalculateDistanceAndFare();
    _fetchCurrentLocation();
    _ratingSubscription = RatingService().onPendingRating.listen((booking) {
      if (mounted) { RatingDialog.show(context, booking: booking); }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = RatingService().getPendingRatingForCustomer('user_current');
      if (pending != null && mounted) { RatingDialog.show(context, booking: pending); }
    });
  }

  void _recalculateDistanceAndFare() {
    try {
      final double distanceInMeters = Geolocator.distanceBetween(_pickupLat, _pickupLng, _dropLat, _dropLng);
      double km = distanceInMeters / 1000.0;
      if (km < 0.1) km = 4.2;
      setState(() { _distanceKm = km; });
    } catch (e) { setState(() { _distanceKm = 4.2; }); }
  }

  double get _currentFare => FareConfig.getFareForVehicle(_selectedRide.id, _distanceKm);
  String get _liveDistanceFareText => "Distance: ${_distanceKm.toStringAsFixed(1)} KM | Fare Rs ${_currentFare.round()}";

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final res = await LocationService.getCurrentLocation();
        if (mounted) { setState(() { _isLocating = false; _pickupAddress = res.formattedAddress; _pickupLat = res.latitude; _pickupLng = res.longitude; _recalculateDistanceAndFare(); }); }
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        final res = await LocationService.getCurrentLocation();
        if (mounted) { setState(() { _isLocating = false; _pickupAddress = res.formattedAddress; _pickupLat = res.latitude; _pickupLng = res.longitude; _recalculateDistanceAndFare(); }); }
        return;
      }
      final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 8));
      String formattedAddr = 'Live GPS (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
      try {
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = <String>[];
          if (p.street != null && p.street!.isNotEmpty) parts.add(p.street!);
          if (p.subLocality != null && p.subLocality!.isNotEmpty) parts.add(p.subLocality!);
          if (p.locality != null && p.locality!.isNotEmpty) parts.add(p.locality!);
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) parts.add(p.administrativeArea!);
          if (parts.isNotEmpty) formattedAddr = parts.join(', ');
        }
      } catch (e) {}
      if (mounted) { setState(() { _isLocating = false; _pickupLat = position.latitude; _pickupLng = position.longitude; _pickupAddress = formattedAddr; _recalculateDistanceAndFare(); }); }
    } catch (e) {
      final res = await LocationService.getCurrentLocation();
      if (mounted) { setState(() { _isLocating = false; _pickupAddress = res.formattedAddress; _pickupLat = res.latitude; _pickupLng = res.longitude; _recalculateDistanceAndFare(); }); }
    }
  }

  void _openPickupMapPicker() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => MapPickerScreen(title: 'pickup_location'.tr(), initialLat: _pickupLat, initialLng: _pickupLng, initialAddress: _pickupAddress)));
    if (result != null && result is Map<String, dynamic>) {
      setState(() { _pickupAddress = result['address'] ?? _pickupAddress; _pickupLat = (result['lat'] as num?)?.toDouble() ?? _pickupLat; _pickupLng = (result['lng'] as num?)?.toDouble() ?? _pickupLng; _recalculateDistanceAndFare(); });
    }
  }

  void _openDropMapPicker() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => MapPickerScreen(title: 'drop_location'.tr(), initialLat: _dropLat, initialLng: _dropLng, initialAddress: _dropAddress)));
    if (result != null && result is Map<String, dynamic>) {
      setState(() { _dropAddress = result['address'] ?? _dropAddress; _dropLat = (result['lat'] as num?)?.toDouble() ?? _dropLat; _dropLng = (result['lng'] as num?)?.toDouble() ?? _dropLng; _recalculateDistanceAndFare(); });
    }
  }

  void _onBookRideNow() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ActiveDriversScreen(rideOption: _selectedRide, pickupAddress: _pickupAddress, dropAddress: _dropAddress)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A), elevation: 0, titleSpacing: 0,
        title: Row(children: [
          const SizedBox(width: 12),
          GestureDetector(
            onLongPressDown: (_) { setState(() => _isLogoPressing = true); _holdCount = 0; _adminTimer?.cancel(); _adminTimer = Timer.periodic(const Duration(seconds: 1), (t) { _holdCount++; if (_holdCount >= 7) { t.cancel(); if (mounted) setState(() => _isLogoPressing = false); _openAdmin(); } }); },
            onLongPressUp: () { if (mounted) setState(() => _isLogoPressing = false); if (_holdCount < 7) _adminTimer?.cancel(); },
            onLongPressCancel: () { if (mounted) setState(() => _isLogoPressing = false); _adminTimer?.cancel(); },
            child: Stack(alignment: Alignment.center, children: [
              Image.asset('assets/images/app_icon.png', width: 42, height: 42, errorBuilder: (c, e, s) => Image.asset('assets/images/logo.png', width: 42, height: 42, errorBuilder: (c2, e2, s2) => const Icon(Icons.handshake, color: Colors.white, size: 30))),
              if (_isLogoPressing) const SizedBox(width: 44, height: 44, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white70)),
            ]),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Text('BHARAT MITRA', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
          GestureDetector(onTap: _fetchCurrentLocation, child: const Icon(Icons.my_location, color: Colors.white)),
          const SizedBox(width: 4),
          IconButton(icon: const Icon(Icons.receipt_long_rounded, color: Colors.white), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTripsScreen())); }),
          const SizedBox(width: 8),
        ]),
      ),
      body: Stack(children: [
        const BharatMitraWatermark(),
        SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.withOpacity(0.3))), child: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle), child: const Icon(Icons.percent_rounded, color: Colors.white, size: 20)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('0% Commission Platform', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(height: 2), Text('commission_banner'.tr(), style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)))])),
            const Icon(Icons.verified_user_rounded, color: Colors.green, size: 24),
          ])).animate().fadeIn(duration: 350.ms).slideY(begin: -0.1, end: 0),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(children: [
            Row(children: [
              Expanded(child: _buildDarkServiceCard(index: 0, title: "bookRide".tr(), subtitle: 'Bike, Toto, Auto, Car', icon: Icons.directions_car_filled_rounded, onTap: () { setState(() => _selectedServiceCard = 0); _onBookRideNow(); })),
              const SizedBox(width: 10),
              Expanded(child: _buildDarkServiceCard(index: 1, title: "rentDrive".tr(), badge: 'PAN INDIA', subtitle: 'Self-Drive Bike / Car', icon: Icons.car_rental_rounded, onTap: () { setState(() => _selectedServiceCard = 1); Navigator.push(context, MaterialPageRoute(builder: (_) => const RentDriveScreen())); })),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _buildDarkServiceCard(index: 2, title: "serviceProvider".tr(), badge: '0% CUT', subtitle: 'Electrician, AC, Plumber', icon: Icons.home_repair_service_rounded, onTap: () { setState(() => _selectedServiceCard = 2); Navigator.push(context, MaterialPageRoute(builder: (_) => const SebakListScreen())); })),
              const SizedBox(width: 10),
              Expanded(child: _buildDarkServiceCard(index: 3, title: "hireDriver".tr(), badge: 'Rs700', subtitle: '8 Hours Shift', icon: Icons.airline_seat_recline_normal_rounded, onTap: () { setState(() => _selectedServiceCard = 3); Navigator.push(context, MaterialPageRoute(builder: (_) => const HireDriverScreen())); })),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _buildDarkServiceCard(index: 4, title: "Wallet", badge: 'Rs0', subtitle: 'Balance & History', icon: Icons.account_balance_wallet_rounded, iconColor: Colors.greenAccent, onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())); })),
              const SizedBox(width: 10),
              Expanded(child: _buildDarkServiceCard(index: 5, title: "Parcel", badge: 'NEW', subtitle: 'Courier & Delivery', icon: Icons.local_shipping_rounded, iconColor: Colors.purpleAccent, onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const ParcelScreen())); })),
            ]),
          ])).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 40),
        ])),
      ]),
    );
  }

  Widget _buildDarkServiceCard({required int index, required String title, required String subtitle, required IconData icon, required VoidCallback onTap, String? badge, Color iconColor = const Color(0xFFFF8C42)}) {
    final isSelected = _selectedServiceCard == index;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8C42).withOpacity(0.15) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFFFF8C42) : Colors.white.withOpacity(0.06), width: 1.2),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, size: 20, color: iconColor)),
            if (badge != null) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: isSelected ? const Color(0xFFFF8C42) : Colors.white, borderRadius: BorderRadius.circular(20)), child: Text(badge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black))),
          ]),
          const SizedBox(height: 14),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFFFF8C42) : Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, color: Colors.white.withOpacity(0.55))),
        ]),
      ),
    );
  }
}
