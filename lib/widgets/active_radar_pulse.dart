import 'package:flutter/material.dart';

class ActiveRadarPulse extends StatefulWidget {
  final Widget child;
  final Color ringColor;
  final double maxRadius;
  final int ringCount;
  final Duration duration;

  const ActiveRadarPulse({
    super.key,
    required this.child,
    this.ringColor = const Color(0xFFFF9933),
    this.maxRadius = 70.0,
    this.ringCount = 3,
    this.duration = const Duration(milliseconds: 2200),
  });

  @override
  State<ActiveRadarPulse> createState() => _ActiveRadarPulseState();
}

class _ActiveRadarPulseState extends State<ActiveRadarPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RadarPulsePainter(
            progress: _controller.value,
            color: widget.ringColor,
            maxRadius: widget.maxRadius,
            ringCount: widget.ringCount,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _RadarPulsePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double maxRadius;
  final int ringCount;

  _RadarPulsePainter({
    required this.progress,
    required this.color,
    required this.maxRadius,
    required this.ringCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < ringCount; i++) {
      final ringProgress = (progress + (i / ringCount)) % 1.0;
      final radius = ringProgress * maxRadius;
      final opacity = (1.0 - ringProgress).clamp(0.0, 1.0) * 0.6;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 - (ringProgress * 1.5);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPulsePainter oldDelegate) => true;
}
