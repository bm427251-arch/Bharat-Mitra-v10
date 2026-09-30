import 'package:flutter/material.dart';
import '../widgets/razorpay_qr_dialog.dart';
import '../widgets/active_radar_pulse.dart';
import '../common_widgets.dart';
import '../services/payment_service.dart';

class BookingDetailScreen extends StatefulWidget {
  final String providerName;
  final String providerType; // 'Driver' | 'Technician' | 'Professional'
  final String photoUrl;
  final String distance;
  final String eta;
  final double amount;
  final String serviceCategory;
  final String vehicleType;

  const BookingDetailScreen({
    super.key,
    this.providerName = 'Rajesh Kumar (Pilot)',
    this.providerType = 'Driver',
    this.photoUrl = '',
    this.distance = '0.8 km away',
    this.eta = '4 mins away',
    this.amount = 29.0,
    this.serviceCategory = 'Commercial Ride',
    this.vehicleType = 'Bike (WB 02 BB 1024)',
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Booking Details • Live NavIC',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          const CustomPaint(size: Size.infinite, painter: TricolorWatermarkPainter()),
          const BharatMitraWatermark(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. LIVE TRACKING BANNER WITH RADAR DOT
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF138808)),
                  ),
                  child: Row(
                    children: [
                      ActiveRadarPulse(
                        ringColor: const Color(0xFF138808),
                        maxRadius: 26,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Color(0xFF138808),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Live NavIC Satellite Tracking',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Distance: ${widget.distance} • ETA: ${widget.eta}',
                              style: const TextStyle(
                                color: Color(0xFFFF9933),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. PROVIDER PROFILE CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFFFF9933),
                            child: const Icon(Icons.person, size: 36, color: Colors.black),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.providerName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                    const SizedBox(width: 4),
                                    const Text('4.9 (184 reviews)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.verified, color: Colors.blue, size: 14),
                                    const Text(' Verified', style: TextStyle(color: Colors.blue, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.vehicleType,
                                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          // Call Button
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF138808),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.call),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF138808),
                                  content: Text('Calling ${widget.providerName}...'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. RATE CARD / PRICE SUMMARY (Shown at confirmation)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.receipt_long, color: Color(0xFFFF9933), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Transparent Rate Card',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '5% Cheaper than Other Apps',
                            style: TextStyle(color: Color(0xFF138808), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white12, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.serviceCategory, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          Text('₹${widget.amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Platform Commission', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          Text('Zero Extra Surge', style: TextStyle(color: Color(0xFF138808), fontSize: 12)),
                        ],
                      ),
                      const Divider(color: Colors.white12, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount Payable',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            '₹${widget.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFFF9933),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. ACTION BUTTONS: OFFICIAL LINK PAY NOW & GENERATE RAZORPAY QR
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF138808),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      await PaymentService.openRazorpayPayment(amount: widget.amount.toInt());
                      setState(() => _isCompleted = true);
                    },
                    icon: const Icon(Icons.verified, color: Colors.white, size: 20),
                    label: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pay Now',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '(razorpay.me/@bharatmitrainfotech)',
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                        SizedBox(width: 4),
                        Text('✅', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9933),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      RazorpayQrDialog.show(
                        context,
                        amount: widget.amount,
                        serviceTitle: '${widget.serviceCategory} • ${widget.providerName}',
                        onPaymentSuccess: () {
                          setState(() => _isCompleted = true);
                        },
                      );
                    },
                    icon: const Icon(Icons.qr_code_2, color: Colors.black, size: 22),
                    label: const Text(
                      'Generate Payment QR (RazorpayX)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_isCompleted)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Payment Settled & Booking Closed!',
                          style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
