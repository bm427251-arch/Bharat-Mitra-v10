import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/driver_model.dart';
import '../models/ride_model.dart';

enum MapStyleMode { standard, satellite }

class DriverComingWidget extends StatefulWidget {
  final DriverModel driver;
  final RideOption rideOption;
  final String pickupAddress;
  final String dropAddress;
  final VoidCallback onComplete;
  final VoidCallback? onCancel;

  const DriverComingWidget({
    super.key,
    required this.driver,
    required this.rideOption,
    required this.pickupAddress,
    required this.dropAddress,
    required this.onComplete,
    this.onCancel,
  });

  @override
  State<DriverComingWidget> createState() => _DriverComingWidgetState();
}

class _DriverComingWidgetState extends State<DriverComingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  MapStyleMode _mapStyle = MapStyleMode.standard;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );

    _progressController.forward().whenComplete(() {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, _) {
        final progress = _progressController.value;
        final double distanceRemainingKm =
            ((1.0 - progress) * (widget.driver.distanceKm > 0 ? widget.driver.distanceKm : 1.8))
                .clamp(0.05, 5.0);
        final int etaMinutes = ((1.0 - progress) * 3).ceil().clamp(1, 5);

        return Stack(
          children: [
            // Map with simulated polyline and moving vehicle marker
            Positioned.fill(
              child: CustomPaint(
                size: Size.infinite,
                painter: _DriverRouteMapPainter(
                  progress: progress,
                  mapStyle: _mapStyle,
                  vehicleType: widget.rideOption.id,
                ),
              ),
            ),

            // Top Header Card with Lottie car moving animation & Map Style Toggle
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _mapStyle == MapStyleMode.satellite
                      ? const Color(0xE60F172A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _mapStyle == MapStyleMode.satellite
                        ? Colors.white24
                        : AppColors.border,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Lottie Car moving animation
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Lottie.asset(
                          'assets/lottie/car_moving.json',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.primary.withOpacity(0.12),
                              child: Icon(
                                widget.rideOption.icon,
                                color: AppColors.primary,
                                size: 26,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'DRIVER ON THE WAY',
                                style: TextStyle(
                                  color: _mapStyle == MapStyleMode.satellite
                                      ? const Color(0xFF34D399)
                                      : AppColors.success,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Arriving in $etaMinutes min (${distanceRemainingKm.toStringAsFixed(1)} km)',
                            style: TextStyle(
                              color: _mapStyle == MapStyleMode.satellite
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Standard vs Satellite Toggle
                    _buildMapStyleToggle(),
                  ],
                ),
              ),
            ),

            // Bottom Driver Details Card: "Driver is coming - 2 min away"
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2E000000),
                      blurRadius: 24,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(widget.driver.photoUrl),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.driver.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.driver.vehicleNo} • ${widget.rideOption.title}',
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
                                    '${widget.driver.rating} (${widget.driver.totalRides} trips)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Direct call button
                        InkWell(
                          onTap: () => _callDriver(widget.driver.phone),
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColors.successBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.call_rounded,
                              color: AppColors.success,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Live Distance Countdown Progress
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Driver is coming - $etaMinutes min away',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '${distanceRemainingKm.toStringAsFixed(1)} km left',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Pickup info and OTP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PICKUP AT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                widget.pickupAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F1FD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'OTP: 4829',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMapStyleToggle() {
    final isSat = _mapStyle == MapStyleMode.satellite;
    return InkWell(
      onTap: () {
        setState(() {
          _mapStyle = isSat ? MapStyleMode.standard : MapStyleMode.satellite;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSat ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSat ? AppColors.secondary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSat ? Icons.satellite_alt_rounded : Icons.map_rounded,
              color: isSat ? AppColors.secondaryLight : AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              isSat ? 'Satellite' : 'Standard',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSat ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverRouteMapPainter extends CustomPainter {
  final double progress;
  final MapStyleMode mapStyle;
  final String vehicleType;

  _DriverRouteMapPainter({
    required this.progress,
    required this.mapStyle,
    required this.vehicleType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bool isSat = mapStyle == MapStyleMode.satellite;

    // 1. Draw Map Background
    final Paint bgPaint = Paint();
    if (isSat) {
      // Dark satellite imagery tones
      bgPaint.color = const Color(0xFF0F1E19);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

      // Satellite terrain patterns
      final terrainPaint = Paint()
        ..color = const Color(0xFF162E25).withOpacity(0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 120, terrainPaint);
      canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 160, terrainPaint);
      canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.2), 100, terrainPaint);
    } else {
      // Clean modern light road map
      bgPaint.color = const Color(0xFFF1F5F9);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

      // Background secondary city grid
      final gridPaint = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..strokeWidth = 3;
      for (double i = 0; i < size.width; i += 70) {
        canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
      }
      for (double j = 0; j < size.height; j += 70) {
        canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
      }
    }

    // 2. Define Route Path from Driver Start to User Pickup
    final path = Path();
    final startPoint = Offset(size.width * 0.18, size.height * 0.22);
    final controlPoint1 = Offset(size.width * 0.75, size.height * 0.28);
    final controlPoint2 = Offset(size.width * 0.22, size.height * 0.52);
    final endPoint = Offset(size.width * 0.82, size.height * 0.62);

    path.moveTo(startPoint.dx, startPoint.dy);
    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint.dx,
      endPoint.dy,
    );

    // 3. Draw Road under Polyline
    final roadBorder = Paint()
      ..color = isSat ? const Color(0xFF334155) : const Color(0xFFCBD5E1)
      ..strokeWidth = 26
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadSurface = Paint()
      ..color = isSat ? const Color(0xFF1E293B) : Colors.white
      ..strokeWidth = 22
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, roadBorder);
    canvas.drawPath(path, roadSurface);

    // 4. Draw Polyline (Glowing Neon in Satellite, Vibrant Blue in Standard)
    final polylinePaint = Paint()
      ..color = isSat
          ? const Color(0xFF38BDF8) // Glowing cyan polyline in satellite
          : AppColors.primary
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, polylinePaint);

    // 5. Draw Pickup Pin (Destination of driver)
    final pinOuter = Paint()..color = AppColors.secondary;
    canvas.drawCircle(endPoint, 12, pinOuter);
    canvas.drawCircle(endPoint, 5, Paint()..color = Colors.white);

    // Pickup label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Pickup',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          backgroundColor: AppColors.secondary,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(endPoint.dx - 16, endPoint.dy - 26));

    // 6. Draw Moving Vehicle Marker along Polyline
    final driverPoint = _getPointAlongPath(path, progress);

    // Halo pulse around vehicle
    final pulsePaint = Paint()
      ..color = (isSat ? const Color(0xFF38BDF8) : AppColors.primary).withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(driverPoint, 26, pulsePaint);

    // Vehicle body circle
    final vehiclePaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(driverPoint, 17, vehiclePaint);

    // Inner vehicle circle
    canvas.drawCircle(
      driverPoint,
      13,
      Paint()..color = isSat ? const Color(0xFF0284C7) : AppColors.primaryLight,
    );

    // Vehicle center dot/indicator
    canvas.drawCircle(driverPoint, 5, Paint()..color = Colors.white);
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
  bool shouldRepaint(covariant _DriverRouteMapPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.mapStyle != mapStyle ||
        oldDelegate.vehicleType != vehicleType;
  }
}
