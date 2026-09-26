import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/ride_model.dart';
import '../models/driver_model.dart';
import '../services/firestore_service.dart';

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

class _ActiveDriversScreenState extends State<ActiveDriversScreen> with SingleTickerProviderStateMixin {
  late AnimationController _trackerController;
  List<DriverModel> _drivers = [];
  bool _isLoading = true;
  DriverModel? _selectedDriver;
  bool _rideConfirmed = false;
  bool _rideCompleted = false;

  // Rating flow
  int _driverRating = 5;
  int _providerRating = 5;
  final _commentController = TextEditingController();
  bool _ratingSubmitted = false;

  @override
  void initState() {
    super.initState();
    _trackerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );

    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    final list = await FirestoreService().getActiveDrivers(widget.rideOption.id);
    if (mounted) {
      setState(() {
        _drivers = list;
        _selectedDriver = list.isNotEmpty ? list.first : null;
        _isLoading = false;
      });
    }
  }

  void _confirmRide(DriverModel driver) {
    setState(() {
      _selectedDriver = driver;
      _rideConfirmed = true;
    });

    _trackerController.forward().whenComplete(() {
      if (mounted) {
        setState(() {
          _rideCompleted = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _trackerController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _rideCompleted
              ? 'Trip Completed'
              : _rideConfirmed
                  ? 'Driver En-Route'
                  : 'Nearby ${widget.rideOption.title} Drivers',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _rideCompleted
          ? _buildRatingScreen()
          : Stack(
              children: [
                // Top Live Map Tracker
                Positioned.fill(
                  child: _buildMapWithAnimatedDriver(),
                ),

                // Floating Info Header
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F1FD),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(widget.rideOption.icon, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.rideOption.title} - ${widget.rideOption.fare}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                              ),
                              Text(
                                'To: ${widget.dropAddress}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (_rideConfirmed)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.successBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ARRIVING',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                ),

                // Bottom Sheet / Driver List
                _buildDraggableBottomSheet(),
              ],
            ),
    );
  }

  Widget _buildMapWithAnimatedDriver() {
    return AnimatedBuilder(
      animation: _trackerController,
      builder: (context, child) {
        final progress = _trackerController.value;
        return CustomPaint(
          size: Size.infinite,
          painter: _LiveTrackingPainter(
            progress: _rideConfirmed ? progress : 0.0,
            hasConfirmed: _rideConfirmed,
          ),
        );
      },
    );
  }

  Widget _buildDraggableBottomSheet() {
    if (_rideConfirmed && _selectedDriver != null) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.premiumCardDecoration(radius: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(_selectedDriver!.photoUrl),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDriver!.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_selectedDriver!.vehicleNo} • ${widget.rideOption.title}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${_selectedDriver!.rating} (${_selectedDriver!.totalRides} trips)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.successBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.call_rounded, color: AppColors.success, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _trackerController.value,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                borderRadius: BorderRadius.circular(10),
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Driver is ${((1.0 - _trackerController.value) * 1.2).toStringAsFixed(1)} km away',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                  Text(
                    'ETA: ${((1.0 - _trackerController.value) * 5).ceil()} mins',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.secondary),
                  ),
                ],
              ),
            ],
          ),
        ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms),
      );
    }

    // List of available drivers draggable sheet
    return DraggableScrollableSheet(
      initialChildSize: 0.42,
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
                        // Call button
                        IconButton(
                          icon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 4),
                        // Book button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          onPressed: () => _confirmRide(driver),
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
                  backgroundImage: NetworkImage(_selectedDriver?.photoUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'),
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
  final bool hasConfirmed;

  _LiveTrackingPainter({
    required this.progress,
    required this.hasConfirmed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background canvas
    final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

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

    // Draw route background road
    canvas.drawPath(path, roadBorder);
    canvas.drawPath(path, roadPaint);

    // Highlight route line
    final routePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, routePaint);

    // Pickup Pin at endpoint
    final pickupPoint = Offset(size.width * 0.8, size.height * 0.65);
    final pinPaint = Paint()..color = AppColors.secondary;
    canvas.drawCircle(pickupPoint, 10, pinPaint);
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
    return oldDelegate.progress != progress || oldDelegate.hasConfirmed != hasConfirmed;
  }
}
