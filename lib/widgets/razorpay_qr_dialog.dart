import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/payment_service.dart';

class RazorpayQrDialog extends StatefulWidget {
  final double amount;
  final String serviceTitle;
  final VoidCallback? onPaymentSuccess;

  const RazorpayQrDialog({
    super.key,
    required this.amount,
    this.serviceTitle = 'Ride & Service Settlement',
    this.onPaymentSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required double amount,
    String serviceTitle = 'Ride & Service Settlement',
    VoidCallback? onPaymentSuccess,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RazorpayQrDialog(
        amount: amount,
        serviceTitle: serviceTitle,
        onPaymentSuccess: onPaymentSuccess,
      ),
    );
  }

  @override
  State<RazorpayQrDialog> createState() => _RazorpayQrDialogState();
}

class _RazorpayQrDialogState extends State<RazorpayQrDialog> {
  static const int _totalSeconds = 300; // 5 minutes
  int _secondsRemaining = _totalSeconds;
  Timer? _timer;
  bool _isPaid = false;
  final String _upiId = 'bharatmitra@razorpay';
  late final String _qrReferenceId;

  @override
  void initState() {
    super.initState();
    _qrReferenceId = 'qr_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimer(int totalSecs) {
    final m = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final s = (totalSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _markAsPaid() {
    _timer?.cancel();
    setState(() => _isPaid = true);
    HapticFeedback.mediumImpact();
    widget.onPaymentSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _secondsRemaining == 0 && !_isPaid;

    return Dialog(
      backgroundColor: const Color(0xFF141414),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFFF9933), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C2340),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueAccent),
                        ),
                        child: const Icon(Icons.qr_code_scanner, color: Colors.blueAccent, size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Bharat Mitra Infotech',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text('✅', style: TextStyle(fontSize: 11)),
                            ],
                          ),
                          Text(
                            'https://razorpay.me/@bharatmitrainfotech [Verified]',
                            style: TextStyle(color: Color(0xFF138808), fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 24),

              // AMOUNT & TIMER
              Text(
                '₹${widget.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFFFF9933),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.serviceTitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 12),

              // TIMER BADGE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isPaid
                      ? Colors.green.withOpacity(0.2)
                      : isExpired
                          ? Colors.red.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isPaid
                        ? Colors.green
                        : isExpired
                            ? Colors.red
                            : const Color(0xFFFF9933),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isPaid
                          ? Icons.check_circle
                          : isExpired
                              ? Icons.error_outline
                              : Icons.timer,
                      size: 14,
                      color: _isPaid
                          ? Colors.green
                          : isExpired
                              ? Colors.red
                              : const Color(0xFFFF9933),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isPaid
                          ? 'Payment Received! (Status: PAID)'
                          : isExpired
                              ? 'QR Expired (5m limit reached)'
                              : 'Expires in ${_formatTimer(_secondsRemaining)} (300s)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _isPaid
                            ? Colors.greenAccent
                            : isExpired
                                ? Colors.redAccent
                                : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // QR CODE CONTAINER
              Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_isPaid ? Colors.green : const Color(0xFFFF9933)).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _isPaid
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 70, color: Colors.green),
                          SizedBox(height: 10),
                          Text(
                            'PAID SUCCESSFULLY',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Settled via RazorpayX',
                            style: TextStyle(color: Colors.black54, fontSize: 10),
                          ),
                        ],
                      )
                    : isExpired
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.timer_off, size: 60, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'QR Expired',
                                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              // Decorative QR pattern
                              CustomPaint(
                                size: const Size(176, 176),
                                painter: _QrCodePainter(),
                              ),
                              // Center Bharat Mitra logo badge
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFFF9933), width: 1.5),
                                ),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.handshake,
                                    color: Color(0xFFFF9933),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
              const SizedBox(height: 14),

              // UPI ID & COPY
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 16, color: Color(0xFFFF9933)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _upiId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _upiId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF138808),
                            content: Text('UPI ID copied: bharatmitra@razorpay'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Text(
                          'COPY',
                          style: TextStyle(
                            color: Color(0xFFFF9933),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ref: $_qrReferenceId • Zero Commission Instant Settlement',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
              const SizedBox(height: 12),

              // OFFICIAL VERIFIED PAY LINK BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF138808),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    await PaymentService.openRazorpayPayment(amount: widget.amount.toInt());
                  },
                  icon: const Icon(Icons.verified, size: 16),
                  label: const Text(
                    'Pay via Official Link (razorpay.me/@bharatmitrainfotech) ✅',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF138808),
                            content: Text('QR Code image saved / shared with customer!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share, size: 14),
                      label: const Text('Share/Save', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPaid ? Colors.green : const Color(0xFF138808),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: _isPaid
                          ? () => Navigator.pop(context)
                          : () {
                              _markAsPaid();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xFF138808),
                                  content: Text('Webhook Triggered: Payment verified as PAID!'),
                                ),
                              );
                            },
                      icon: Icon(_isPaid ? Icons.check : Icons.bolt, size: 14),
                      label: Text(
                        _isPaid ? 'Done' : 'Simulate Paid',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Outer corner boxes
    void drawCorner(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, 42, 42), paint);
      final whitePaint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(x + 6, y + 6, 30, 30), whitePaint);
      canvas.drawRect(Rect.fromLTWH(x + 12, y + 12, 18, 18), paint);
    }

    drawCorner(8, 8);
    drawCorner(size.width - 50, 8);
    drawCorner(8, size.height - 50);

    // Random pattern grid
    final dotPaint = Paint()..color = Colors.black87;
    const int grid = 14;
    final double step = size.width / grid;

    for (int r = 0; r < grid; r++) {
      for (int c = 0; c < grid; c++) {
        // Skip corner boxes
        if ((r < 4 && c < 4) || (r < 4 && c > grid - 5) || (r > grid - 5 && c < 4)) {
          continue;
        }
        // Skip center
        if (r >= 5 && r <= 8 && c >= 5 && c <= 8) {
          continue;
        }
        if ((r * 7 + c * 13 + (r % 2)) % 3 == 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * step + 2, r * step + 2, step - 3, step - 3),
              const Radius.circular(2),
            ),
            dotPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
