import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../widgets/rating_dialog.dart';

class TrackingScreen extends StatefulWidget {
  final String serviceType; // 'book_ride', 'hire_driver', 'home_service', 'rent_drive'
  final String partnerId;
  final String partnerName;
  final String partnerPhone;
  final String vehicleInfo;
  final String pickupAddress;
  final String dropAddress;
  final double fare;
  final double rating;

  const TrackingScreen({
    super.key,
    required this.serviceType,
    required this.partnerId,
    required this.partnerName,
    required this.partnerPhone,
    required this.vehicleInfo,
    required this.pickupAddress,
    required this.dropAddress,
    this.fare = 140.0,
    this.rating = 4.9,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _refreshTimer;
  bool _isSatellite = false;
  Map<String, dynamic>? _liveData;
  double _distanceKm = 1.2;
  int _etaMinutes = 5;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _fetchLatestLocation();

    // Auto-refresh every 10 seconds from live_locations collection
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchLatestLocation();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _fetchLatestLocation() {
    final live = LocationService.instance.getLiveLocation(widget.partnerId);
    if (mounted) {
      setState(() {
        _liveData = live;
        if (_distanceKm > 0.3) {
          _distanceKm = (_distanceKm - 0.1).clamp(0.2, 5.0);
          _etaMinutes = (_distanceKm * 4).round().clamp(1, 15);
        }
      });
    }
  }

  void _callPartner() async {
    final Uri url = Uri(scheme: 'tel', path: widget.partnerPhone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Calling ${widget.partnerName} (${widget.partnerPhone})...'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  String _getServiceTitle() {
    switch (widget.serviceType) {
      case 'hire_driver':
        return 'Hired Driver is on the way';
      case 'home_service':
        return 'Sevak is on the way to your home';
      case 'rent_drive':
        return 'Where to go: Vehicle Pickup & Garage';
      case 'book_ride':
      default:
        return 'Driver is arriving';
    }
  }

  String _getSubtitle() {
    switch (widget.serviceType) {
      case 'rent_drive':
        return 'Owner Ramesh Verma is at garage • Vehicle Ready';
      case 'home_service':
        return 'Electrician/Plumber coming to service address';
      default:
        return 'Driver $_etaMinutes min away • ${_distanceKm.toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A6E),
        title: Text(_getServiceTitle(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSatellite ? Icons.satellite_alt_rounded : Icons.map_rounded,
              color: Colors.white,
            ),
            tooltip: _isSatellite ? 'Switch to Standard Map' : 'Switch to Satellite Map',
            onPressed: () => setState(() => _isSatellite = !_isSatellite),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. LIVE MAP CANVAS
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LiveTrackingMapPainter(
                    progress: _animController.value,
                    isSatellite: _isSatellite,
                    serviceType: widget.serviceType,
                  ),
                );
              },
            ),
          ),

          // 2. TOP FLOATING CARD: Live Partner Details & ETA
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0x24000000), blurRadius: 18, offset: Offset(0, 6)),
                ],
                border: Border.all(color: AppColors.primary.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.circle, color: Colors.green, size: 8),
                            const SizedBox(width: 6),
                            Text(
                              _liveData != null && _liveData!['speed'] != null
                                  ? 'LIVE • ${_liveData!['speed']} km/h'
                                  : 'LIVE • Auto update 10s',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₹${widget.fare.toInt()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A3A6E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Partner Info Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFF1A3A6E),
                        child: Text(
                          widget.partnerName.isNotEmpty ? widget.partnerName[0] : 'P',
                          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.partnerName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.vehicleInfo,
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                const SizedBox(width: 3),
                                Text(
                                  '⭐ ${widget.rating} (120 Ratings)',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Call Button
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                        icon: const Icon(Icons.call, color: Colors.white),
                        onPressed: _callPartner,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  // ETA banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getSubtitle(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: -0.2, end: 0, duration: 350.ms),
          ),

          // 3. BOTTOM FLOATING CARD: "Where to go" Addresses & Confirmations
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(color: Color(0x28000000), blurRadius: 20, offset: Offset(0, -4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.navigation_rounded, color: Color(0xFF1A3A6E), size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Where to go / Service Location',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '0% Commission',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 18),

                  // Pickup / Service Pin
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.radio_button_checked, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.serviceType == 'rent_drive' ? 'GARAGE / PICKUP' : 'PICKUP LOCATION',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            Text(
                              widget.pickupAddress,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Destination Pin
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.serviceType == 'home_service' ? 'CUSTOMER HOME' : 'DROP DESTINATION',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            Text(
                              widget.dropAddress,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3A6E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // Open rating dialog upon service completion
                        RatingDialog.show(
                          context,
                          booking: {
                            'bookingId': 'bk_live_${widget.partnerId}',
                            'driverName': widget.partnerName,
                            'vehicleNo': widget.vehicleInfo,
                            'fare': widget.fare,
                            'driverId': widget.partnerId,
                          },
                          onSubmitted: () => Navigator.pop(context),
                        );
                      },
                      child: const Text('Complete & Give Rating ⭐', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.2, end: 0, duration: 350.ms),
          ),
        ],
      ),
    );
  }
}

class _LiveTrackingMapPainter extends CustomPainter {
  final double progress;
  final bool isSatellite;
  final String serviceType;

  _LiveTrackingMapPainter({
    required this.progress,
    required this.isSatellite,
    required this.serviceType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Map Background
    final Paint bgPaint = Paint();
    if (isSatellite) {
      bgPaint.color = const Color(0xFF0F1E19);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

      // Satellite patches
      final patchPaint = Paint()
        ..color = const Color(0xFF1A3B2F).withOpacity(0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 130, patchPaint);
      canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 160, patchPaint);
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.8), 90, patchPaint);
    } else {
      bgPaint.color = const Color(0xFFF1F5F9);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

      // Grid streets
      final gridPaint = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..strokeWidth = 2.5;
      for (double i = 0; i < size.width; i += 60) {
        canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
      }
      for (double j = 0; j < size.height; j += 60) {
        canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
      }
    }

    // 2. Define polyline curve path between Driver (Live) and Destination
    final path = Path();
    final startPoint = Offset(size.width * 0.2, size.height * 0.35);
    final controlPoint1 = Offset(size.width * 0.75, size.height * 0.38);
    final controlPoint2 = Offset(size.width * 0.25, size.height * 0.6);
    final endPoint = Offset(size.width * 0.8, size.height * 0.7);

    path.moveTo(startPoint.dx, startPoint.dy);
    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint.dx,
      endPoint.dy,
    );

    // 3. Draw road surface
    final roadPaint = Paint()
      ..color = isSatellite ? const Color(0xFF1E293B) : Colors.white
      ..strokeWidth = 22
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, roadPaint);

    // 4. Draw polyline
    final polylinePaint = Paint()
      ..color = isSatellite ? const Color(0xFF38BDF8) : const Color(0xFF1A3A6E)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, polylinePaint);

    // 5. Draw Customer Destination Pin (End Marker)
    final endPinPaint = Paint()..color = Colors.red;
    canvas.drawCircle(endPoint, 12, endPinPaint);
    canvas.drawCircle(endPoint, 5, Paint()..color = Colors.white);

    // 6. Draw Moving Live Partner Marker
    final metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      final tangent = metric.getTangentForOffset(metric.length * progress.clamp(0.0, 1.0));
      if (tangent != null) {
        final pos = tangent.position;

        // Pulse halo
        final pulse = Paint()
          ..color = (isSatellite ? const Color(0xFF38BDF8) : const Color(0xFF1A3A6E)).withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 28, pulse);

        // Vehicle dot
        final marker = Paint()..color = const Color(0xFF1A3A6E);
        canvas.drawCircle(pos, 16, marker);
        canvas.drawCircle(pos, 12, Paint()..color = Colors.amber);
        canvas.drawCircle(pos, 5, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LiveTrackingMapPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isSatellite != isSatellite ||
        oldDelegate.serviceType != serviceType;
  }
}
