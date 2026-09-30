import 'package:flutter/material.dart';

class BharatMitraWatermark extends StatelessWidget {
  const BharatMitraWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.06,
          child: Center(
            child: Image.asset(
              'assets/watermark_india.png',
              width: 320,
              errorBuilder: (_, __, ___) => Icon(
                Icons.handshake,
                size: 280,
                color: const Color(0xFFFF9933).withOpacity(0.1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TricolorWatermarkPainter extends CustomPainter {
  const TricolorWatermarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c1 = Paint()..color = const Color(0xFFFF9933).withOpacity(0.08);
    final c2 = Paint()..color = Colors.white.withOpacity(0.05);
    final c3 = Paint()..color = const Color(0xFF138808).withOpacity(0.08);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.45), 160, c1);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.45), 110, c2);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.45), 60, c3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
