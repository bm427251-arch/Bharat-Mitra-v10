import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/ride_model.dart';
import '../models/driver_model.dart';
import '../services/firestore_service.dart';
import '../widgets/searching_radar.dart';
import '../widgets/driver_coming.dart';

class ActiveDriversScreen extends StatefulWidget {
  final RideOption rideOption;
  final String pickupAddress;
  final String dropAddress;

  const ActiveDriversScreen({
    super.key,
    required this.rideOption,
    required this.pickupAddress,
    required this.dropAddress,
  });

  @override
  State<ActiveDriversScreen> createState() => _ActiveDriversScreenState();
}

class _ActiveDriversScreenState extends State<ActiveDriversScreen> {
  List<DriverModel> _drivers = [];
  bool _isLoading = true;
  bool _isSearching = true;
  DriverModel? _selectedDriver;
  bool _isBooking = false;
  bool _driverAccepted = false;
  bool _rideCompleted = false;
  bool _isSatellite = false;

  // Rating flow
  int _driverRating = 5;
  int _providerRating = 5;
  final _commentController = TextEditingController();
  bool _ratingSubmitted = false;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    final startTime = DateTime.now();
    final list = await FirestoreService().getActiveDrivers(widget.rideOption.id);
    final elapsed = DateTime.now().difference(startTime);

    // Maintain searching radar animation for 3.5 seconds while searching
    if (elapsed.inMilliseconds < 3500) {
      await Future.delayed(Duration(milliseconds: 3500 - elapsed.inMilliseconds));
    }

    if (mounted) {
      setState(() {
        _drivers = list;
        _selectedDriver = list.isNotEmpty ? list.first : null;
        _isLoading = false;
        _isSearching = false;
      });
    }
  }

  void _onBookDriver(DriverModel driver) async {
    setState(() {
      _selectedDriver = driver;
      _isBooking = true;
    });

    try {
      // 1. Create booking in Firestore with 'searching' status
      final bookingId = await FirestoreService().createBooking(
        driverId: driver.id,
        driverName: driver.name,
        vehicleType: widget.rideOption.id,
        vehicleNo: driver.vehicleNo,
        pickupAddress: widget.pickupAddress,
        dropAddress: widget.dropAddress,
        fare: widget.rideOption.baseFare.toDouble(),
        status: 'searching',
      );

      // 2. Simulate driver accepting after 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // 3. Update Firestore booking status to 'accepted'
      await FirestoreService().updateBookingStatus(bookingId, 'accepted');
    } catch (e) {
      debugPrint('Booking execution error: $e');
    }

    if (mounted) {
      setState(() {
        _isBooking = false;
        _driverAccepted = true; // Radar turns off, vehicle moves along polyline
      });
    }
  }

  void _callDriver(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Calling $phone...'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_rideCompleted) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Trip Completed'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _buildRatingScreen(),
      );
    }

    // Step 4.3: When driver accepts, radar OFF -> show driver_coming.dart animation with vehicle moving along polyline
    if (_driverAccepted && _selectedDriver != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Driver En-Route'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: DriverComingWidget(
          driver: _selectedDriver!,
          rideOption: widget.rideOption,
          pickupAddress: widget.pickupAddress,
          dropAddress: widget.dropAddress,
          onComplete: () {
            setState(() {
              _rideCompleted = true;
            });
          },
          onCancel: () {
            setState(() {
              _driverAccepted = false;
              _selectedDriver = null;
            });
          },
        ),
      );
    }

    // Step 4.4: Initially show searching_radar.dart widget for 3-5 sec while fetching
    if (_isSearching) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Searching ${widget.rideOption.title} Drivers'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF1F5FD), Color(0xFFE8EFFD)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SearchingRadar(
                text: 'Searching ${widget.rideOption.title} drivers...',
                onCancel: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x10000000), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.secondary, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Pickup: ${widget.pickupAddress}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Step 4.4: After drivers found, keep live map tracker with drivers list below!
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Nearby ${widget.rideOption.title} Drivers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Map Style Toggle Icon in AppBar as well
          IconButton(
            icon: Icon(
              _isSatellite ? Icons.satellite_alt_rounded : Icons.map_rounded,
              color: Colors.white,
            ),
            tooltip: _isSatellite ? 'Switch to Standard' : 'Switch to Satellite',
            onPressed: () {
              setState(() {
                _isSatellite = !_isSatellite;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Top Live Map Tracker with standard & satellite view styles
          Positioned.fill(
            child: _buildMapTrackerView(),
          ),

          // Floating Map Tracker Header Card with Standard vs Satellite Toggle
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildLiveMapTrackerHeaderCard(),
          ),

          // Booking in-progress overlay (simulating 2 sec driver acceptance)
          if (_isBooking)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.65),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Connecting with ${_selectedDriver?.name ?? "Driver"}...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_selectedDriver?.vehicleNo} • ${widget.rideOption.title}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.flash_on_rounded, color: AppColors.success, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Simulating Driver Acceptance (2 sec)...',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom Sheet / Driver List
          _buildDraggableBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildMapTrackerView() {
    return CustomPaint(
      size: Size.infinite,
      painter: _LiveTrackingPainter(
        progress: 0.25,
        isSatellite: _isSatellite,
      ),
    );
  }

  Widget _buildLiveMapTrackerHeaderCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isSatellite ? const Color(0xE60F172A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isSatellite ? Colors.white24 : AppColors.border,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isSatellite ? const Color(0xFF1E293B) : const Color(0xFFE8F1FD),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.rideOption.icon,
              color: _isSatellite ? AppColors.secondaryLight : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.rideOption.title} - ${widget.rideOption.fare}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: _isSatellite ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'To: ${widget.dropAddress}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _isSatellite ? Colors.white70 : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Toggle button to switch between standard and satellite view map styles
          InkWell(
            onTap: () {
              setState(() {
                _isSatellite = !_isSatellite;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _isSatellite ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSatellite ? AppColors.secondary : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSatellite ? Icons.satellite_alt_rounded : Icons.map_rounded,
                    color: _isSatellite ? AppColors.secondaryLight : AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isSatellite ? 'Satellite' : 'Standard',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _isSatellite ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildDraggableBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.44,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_drivers.length} Active Drivers Nearby',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bolt_rounded, color: AppColors.success, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '0% Commission',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                ..._drivers.map((driver) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(driver.photoUrl),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${driver.vehicleNo} • ${driver.distanceKm} km away',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${driver.rating}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${driver.totalRides} trips)',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Direct call button
                        IconButton(
                          icon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                          onPressed: () => _callDriver(driver.phone),
                        ),
                        const SizedBox(width: 4),
                        // Book button -> Triggers acceptance simulation -> driver_coming.dart animation
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          onPressed: () => _onBookDriver(driver),
                          child: const Text('Book', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatingScreen() {
    if (_ratingSubmitted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 54,
                ),
              ).animate().scale(duration: 400.ms),
              const SizedBox(height: 20),
              const Text(
                'Thank You for Rating!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your feedback empowers our 0% commission community drivers & sebak partners to maintain top quality standards.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 32),
              AppTheme.primaryGradientButton(
                text: 'Back to Home',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.successBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.celebration_rounded, color: AppColors.success, size: 40),
          ),
          const SizedBox(height: 14),
          const Text(
            'Ride Completed!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Paid: ${widget.rideOption.fare} (Direct Cash/UPI to Driver)',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Rate Driver card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.premiumCardDecoration(),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(
                    _selectedDriver?.photoUrl ??
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedDriver?.name ?? 'Driver Partner',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_selectedDriver?.vehicleNo} • ${widget.rideOption.title}',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Rate your Driver',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    return IconButton(
                      icon: Icon(
                        star <= _driverRating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () => setState(() => _driverRating = star),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Rate Service Platform Provider
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.premiumCardDecoration(),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user_rounded, color: AppColors.secondary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Rate Bharat Mitra Platform',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'How was your experience with 0% commission booking?',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    return IconButton(
                      icon: Icon(
                        star <= _providerRating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: AppColors.secondary,
                        size: 32,
                      ),
                      onPressed: () => setState(() => _providerRating = star),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          AppTheme.primaryGradientButton(
            text: 'Submit 5-Star Reviews',
            onPressed: () {
              setState(() => _ratingSubmitted = true);
            },
          ),
        ],
      ),
    );
  }
}

class _LiveTrackingPainter extends CustomPainter {
  final double progress;
  final bool isSatellite;

  _LiveTrackingPainter({
    required this.progress,
    required this.isSatellite,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isSatellite) {
      // Dark aerial imagery tone
      final bg = Paint()..color = const Color(0xFF0F1E19);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

      // Terrain patches
      final patchPaint = Paint()
        ..color = const Color(0xFF1B382B).withOpacity(0.7)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.3), 110, patchPaint);
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.65), 140, patchPaint);

      // Roads
      final roadBorder = Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 28
        ..style = PaintingStyle.stroke;
      final roadPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..strokeWidth = 24
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(size.width * 0.15, size.height * 0.2);
      path.cubicTo(
        size.width * 0.7,
        size.height * 0.25,
        size.width * 0.25,
        size.height * 0.55,
        size.width * 0.8,
        size.height * 0.65,
      );

      canvas.drawPath(path, roadBorder);
      canvas.drawPath(path, roadPaint);

      // Glowing route line
      final glowPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, glowPaint);

      // Pickup Pin
      final pickupPoint = Offset(size.width * 0.8, size.height * 0.65);
      canvas.drawCircle(pickupPoint, 11, Paint()..color = AppColors.secondary);
      canvas.drawCircle(pickupPoint, 4, Paint()..color = Colors.white);

      // Driver position
      final driverPoint = _getPointAlongPath(path, progress);
      canvas.drawCircle(
        driverPoint,
        24,
        Paint()
          ..color = const Color(0xFF38BDF8).withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(driverPoint, 16, Paint()..color = const Color(0xFF0284C7));
      canvas.drawCircle(driverPoint, 6, Paint()..color = Colors.white);
    } else {
      // Background canvas (Standard)
      final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

      // City road network
      final gridPaint = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..strokeWidth = 2;
      for (double i = 0; i < size.width; i += 60) {
        canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
      }

      // Roads
      final roadPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 26
        ..style = PaintingStyle.stroke;

      final roadBorder = Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 30
        ..style = PaintingStyle.stroke;

      // Curved route path from driver start to pickup point
      final path = Path();
      path.moveTo(size.width * 0.15, size.height * 0.2);
      path.cubicTo(
        size.width * 0.7,
        size.height * 0.25,
        size.width * 0.25,
        size.height * 0.55,
        size.width * 0.8,
        size.height * 0.65,
      );

      canvas.drawPath(path, roadBorder);
      canvas.drawPath(path, roadPaint);

      // Highlight route line
      final routePaint = Paint()
        ..color = AppColors.primary.withOpacity(0.35)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, routePaint);

      // Pickup Pin at endpoint
      final pickupPoint = Offset(size.width * 0.8, size.height * 0.65);
      final pinPaint = Paint()..color = AppColors.secondary;
      canvas.drawCircle(pickupPoint, 11, pinPaint);
      canvas.drawCircle(pickupPoint, 4, Paint()..color = Colors.white);

      // Driver moving position based on progress
      final driverPoint = _getPointAlongPath(path, progress);

      // Ripple effect around driver
      final ripplePaint = Paint()
        ..color = AppColors.primary.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(driverPoint, 24, ripplePaint);

      // Driver vehicle circle
      final carCircle = Paint()..color = AppColors.primary;
      canvas.drawCircle(driverPoint, 16, carCircle);
      canvas.drawCircle(driverPoint, 6, Paint()..color = Colors.white);
    }
  }

  Offset _getPointAlongPath(Path path, double fraction) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return const Offset(100, 100);
    final metric = metrics.first;
    final length = metric.length;
    final tangent = metric.getTangentForOffset(length * fraction.clamp(0.0, 1.0));
    return tangent?.position ?? const Offset(100, 100);
  }

  @override
  bool shouldRepaint(covariant _LiveTrackingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isSatellite != isSatellite;
  }
}
