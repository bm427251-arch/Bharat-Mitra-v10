import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_theme.dart';
import '../models/ride_model.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import 'map_picker_screen.dart';
import 'active_drivers_screen.dart';

class HomeRideScreen extends StatefulWidget {
  const HomeRideScreen({super.key});

  @override
  State<HomeRideScreen> createState() => _HomeRideScreenState();
}

class _HomeRideScreenState extends State<HomeRideScreen> {
  final TextEditingController _dropController = TextEditingController();
  List<PlaceSuggestion> _placeSuggestions = [];
  bool _showSuggestions = false;

  String _pickupAddress = 'Detecting current GPS location...';
  String _dropAddress = 'Where to? (e.g. Barasat, Salt Lake)';
  double _pickupLat = LocationService.defaultLat;
  double _pickupLng = LocationService.defaultLng;

  RideOption _selectedRide = RideOption.availableRides.first;
  bool _isLocating = false;

  @override
  void dispose() {
    _dropController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLocating = true);
    final res = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _isLocating = false;
        _pickupAddress = res.formattedAddress;
        _pickupLat = res.latitude;
        _pickupLng = res.longitude;
      });
    }
  }

  void _openPickupMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          title: 'Select Pickup Location',
          initialLat: _pickupLat,
          initialLng: _pickupLng,
          initialAddress: _pickupAddress,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _pickupAddress = result['address'];
        _pickupLat = result['lat'];
        _pickupLng = result['lng'];
      });
    }
  }

  void _openDropMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          title: 'Select Drop Location',
          initialLat: _pickupLat + 0.015,
          initialLng: _pickupLng + 0.015,
          initialAddress: 'Salt Lake Sector V, Bidhannagar, Kolkata',
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _dropAddress = result['address'];
      });
    }
  }

  void _bookRideNow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveDriversScreen(
          rideOption: _selectedRide,
          pickupAddress: _pickupAddress,
          dropAddress: _dropAddress == 'Where to? (e.g. Salt Lake Sector V)'
              ? 'Salt Lake Sector V, Kolkata'
              : _dropAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book a Ride'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: _isLocating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
            tooltip: 'Refresh GPS',
            onPressed: _fetchCurrentLocation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "0% Commission" Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.commissionBannerGradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F10B981),
                    blurRadius: 12,
                    offset: Offset(0, 4),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '0% Commission Platform',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF065F46),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '100% of your fare goes straight to your driver partner.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.security_rounded,
                    color: Color(0xFF059669),
                    size: 24,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

            // Pickup / Drop Fields
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
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
                              const Text(
                                'PICKUP POINT',
                                style: TextStyle(
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

                  // Divider with connecting line
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 2,
                          height: 24,
                          color: AppColors.border,
                        ),
                        const SizedBox(width: 24),
                        const Expanded(child: Divider(height: 1)),
                      ],
                    ),
                  ),

                  // Drop Field with Places Search & Barasat Linked Suggestions
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
                        child: TextField(
                          controller: _dropController,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                            labelText: 'DESTINATION',
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                              letterSpacing: 0.5,
                            ),
                            hintText: 'Type Drop Location - e.g. Barasat, Salt Lake',
                            hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          onChanged: (val) async {
                            if (val.trim().isNotEmpty) {
                              _dropAddress = val.trim();
                            }
                            if (val.trim().length >= 2) {
                              final suggestions = await PlacesService.getPlaceSuggestions(
                                val,
                                currentLatLng: LatLng(_pickupLat, _pickupLng),
                              );
                              if (mounted) {
                                setState(() {
                                  _placeSuggestions = suggestions;
                                  _showSuggestions = suggestions.isNotEmpty;
                                });
                              }
                            } else {
                              if (mounted) {
                                setState(() => _showSuggestions = false);
                              }
                            }
                          },
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              setState(() {
                                _dropAddress = val.trim();
                                _showSuggestions = false;
                              });
                            }
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

                  // Linked Suggestions List (Barasat Court, Station, SP Office, etc.)
                  if (_showSuggestions && _placeSuggestions.isNotEmpty) ...[
                    const Divider(height: 16),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _placeSuggestions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final p = _placeSuggestions[i];
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on_rounded, size: 16, color: AppColors.secondary),
                            ),
                            title: Text(
                              p.mainText,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            subtitle: Text(
                              p.secondaryText,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F1FD),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                p.distance,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _dropAddress = p.fullAddress;
                                _dropController.text = p.fullAddress;
                                _showSuggestions = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.08, end: 0),

            const SizedBox(height: 24),

            // Select Ride Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Ride (0% Commission)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Direct Cash / UPI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Ride selector: 5 options (Bike, Toto, Auto, Sedan, XL SUV)
            // Each item is a premium white card 120x110
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
                                  color: Color(0x400B2E6E),
                                  blurRadius: 14,
                                  offset: Offset(0, 7),
                                ),
                              ],
                            )
                          : BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x10000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                      child: Stack(
                        children: [
                          Column(
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
                                        ride.fare,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
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
                        ],
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

            const SizedBox(height: 24),

            // Book Ride Button & Fair Guarantee Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  AppTheme.primaryGradientButton(
                    text: 'Book ${_selectedRide.title} (${_selectedRide.fare})',
                    icon: Icon(_selectedRide.icon, color: Colors.white, size: 22),
                    onPressed: _bookRideNow,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Verified drivers • Direct UPI or Cash • No surge pricing',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            const SizedBox(height: 100), // Spacing for floating bottom nav
          ],
        ),
      ),
    );
  }
}
