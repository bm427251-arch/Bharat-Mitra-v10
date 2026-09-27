import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class SearchingRadar extends StatefulWidget {
  final String text;
  final VoidCallback? onCancel;
  final double size;
  final bool compact;

  const SearchingRadar({
    super.key,
    this.text = 'Searching nearby drivers...',
    this.onCancel,
    this.size = 280,
    this.compact = false,
  });

  @override
  State<SearchingRadar> createState() => _SearchingRadarState();
}

class _SearchingRadarState extends State<SearchingRadar>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double radarSize = widget.compact ? 180.0 : widget.size;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: radarSize,
            height: radarSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 3 pulsating circles animation (scale 1 to 3, opacity 1 to 0, repeat infinite)
                // Radar effect with Primary Color #0B2E6E 30% opacity using flutter_animate
                _buildPulseCircle(delay: 0.ms, size: radarSize * 0.35),
                _buildPulseCircle(delay: 650.ms, size: radarSize * 0.35),
                _buildPulseCircle(delay: 1300.ms, size: radarSize * 0.35),

                // Radar scanning sweep overlay
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: Container(
                        width: radarSize * 0.85,
                        height: radarSize * 0.85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            center: Alignment.center,
                            startAngle: 0.0,
                            endAngle: math.pi / 2,
                            colors: [
                              const Color(0xFF0B2E6E).withOpacity(0.0),
                              const Color(0xFF0B2E6E).withOpacity(0.25),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Animated vehicles around radar (Bike, Toto, Auto) moving in circle path
                // using AnimatedBuilder + Transform.rotate
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    final double angle = _rotationController.value * 2 * math.pi;
                    final double orbitRadius = radarSize * 0.38;

                    return Stack(
                      children: [
                        // Vehicle 1: Bike
                        _buildOrbitingVehicle(
                          angle: angle,
                          orbitRadius: orbitRadius,
                          icon: Icons.two_wheeler_rounded,
                          color: AppColors.primary,
                          label: 'Bike',
                        ),
                        // Vehicle 2: Toto (Electric Rickshaw)
                        _buildOrbitingVehicle(
                          angle: angle + (2 * math.pi / 3),
                          orbitRadius: orbitRadius * 0.9,
                          icon: Icons.electric_rickshaw_rounded,
                          color: AppColors.secondary,
                          label: 'Toto',
                        ),
                        // Vehicle 3: Auto
                        _buildOrbitingVehicle(
                          angle: angle + (4 * math.pi / 3),
                          orbitRadius: orbitRadius * 1.05,
                          icon: Icons.electric_moped_rounded,
                          color: const Color(0xFF0D9488),
                          label: 'Auto',
                        ),
                      ],
                    );
                  },
                ),

                // Center user location dot blue with pulse
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B2E6E).withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.3, 1.3), duration: 1.seconds),

                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B2E6E), // Center user location dot blue
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x660B2E6E),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_pin_circle_rounded,
                      color: Colors.white,
                      size: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!widget.compact) ...[
            const SizedBox(height: 18),
            // "Searching nearby drivers..." animated text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(duration: 800.ms),
                const SizedBox(width: 8),
                Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn(duration: 1.seconds),

            const SizedBox(height: 6),
            const Text(
              'Connecting with 0% commission local partners...',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),

            if (widget.onCancel != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                ),
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Cancel Search', style: TextStyle(fontSize: 13)),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPulseCircle({required Duration delay, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF0B2E6E).withOpacity(0.35),
          width: 2.2,
        ),
        color: const Color(0xFF0B2E6E).withOpacity(0.08),
      ),
    )
        .animate(
          delay: delay,
          onPlay: (controller) => controller.repeat(),
        )
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(3.0, 3.0),
          duration: 2.seconds,
          curve: Curves.easeOutQuad,
        )
        .fadeOut(
          duration: 2.seconds,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildOrbitingVehicle({
    required double angle,
    required double orbitRadius,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    // Trigonometric positioning
    final double x = orbitRadius * math.cos(angle);
    final double y = orbitRadius * math.sin(angle);

    return Positioned(
      left: (widget.compact ? 180.0 : widget.size) / 2 + x - 18,
      top: (widget.compact ? 180.0 : widget.size) / 2 + y - 18,
      child: Transform.rotate(
        // Keep vehicle oriented along motion or upright
        angle: angle + math.pi / 2,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
      ),
    );
  }
}
