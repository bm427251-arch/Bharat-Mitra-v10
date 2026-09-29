import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/rating_service.dart';
import '../services/firestore_service.dart';
import '../widgets/rating_dialog.dart';
import 'tracking_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  final RatingService _ratingService = RatingService();
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription? _ratingSub;
  int _viewMode = 0; // 0: Customer View, 1: Provider View

  @override
  void initState() {
    super.initState();
    // Listen for driver confirming payment to trigger rating popup
    _ratingSub = _ratingService.onPendingRating.listen((booking) {
      if (mounted) {
        setState(() {});
        RatingDialog.show(
          context,
          booking: booking,
          onSubmitted: () => setState(() {}),
        );
      }
    });

    // Check if any existing booking is waiting for rating
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = _ratingService.getPendingRatingForCustomer('user_current');
      if (pending != null && mounted) {
        RatingDialog.show(
          context,
          booking: pending,
          onSubmitted: () => setState(() {}),
        );
      }
    });
  }

  @override
  void dispose() {
    _ratingSub?.cancel();
    super.dispose();
  }

  Future<void> _handleDriverPaymentConfirmed(String bookingId) async {
    final success = await _ratingService.confirmPaymentReceived(bookingId);
    if (mounted && success) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment confirmed! Rating request sent to Customer.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showFileComplaintDialog(Map<String, dynamic> booking) {
    String selectedType = 'Overcharge';
    final descCtrl = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.report_problem_rounded, color: Colors.red),
                  SizedBox(width: 8),
                  Text('File a Complaint', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip with ${booking['driverName']} (${booking['vehicleNo']})',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E)),
                    ),
                    const SizedBox(height: 14),
                    const Text('Complaint Reason', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: [
                        'Overcharge',
                        'Late',
                        'BadBehaviour',
                        'VehicleIssue',
                        'PaymentIssue',
                        'Other',
                      ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Explain the issue clearly for Admin review...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setDialogState(() => isSubmitting = true);
                          await _firestoreService.fileComplaint({
                            'bookingId': booking['bookingId'] ?? '',
                            'serviceType': booking['serviceType'] ?? 'ride',
                            'customerId': booking['customerId'] ?? 'user_current',
                            'customerName': booking['customerName'] ?? 'Bharat Customer',
                            'providerId': booking['driverId'] ?? '',
                            'providerName': booking['driverName'] ?? 'Partner',
                            'complaintType': selectedType,
                            'description': descCtrl.text.trim(),
                            'status': 'pending_admin',
                            'createdAt': DateTime.now().toIso8601String(),
                          });

                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Complaint filed successfully. Admin is investigating.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit Complaint'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _ratingService.allBookings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Trips & Bookings'),
        backgroundColor: const Color(0xFF1A3A6E),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(
                      child: Text('Customer View', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    selected: _viewMode == 0,
                    selectedColor: const Color(0xFF1A3A6E),
                    labelStyle: TextStyle(color: _viewMode == 0 ? Colors.white : const Color(0xFF1A3A6E)),
                    onSelected: (val) => setState(() => _viewMode = 0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(
                      child: Text('Provider View', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    selected: _viewMode == 1,
                    selectedColor: const Color(0xFF1A3A6E),
                    labelStyle: TextStyle(color: _viewMode == 1 ? Colors.white : const Color(0xFF1A3A6E)),
                    onSelected: (val) => setState(() => _viewMode = 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: bookings.isEmpty
          ? const Center(child: Text('No bookings found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final b = bookings[index];
                final isCleared = b['paymentStatus'] == 'cleared';
                final driverConfirmed = b['driverConfirmed'] == true;
                final ratingGiven = b['ratingGiven'] == true;
                final int rating = (b['rating'] as num?)?.toInt() ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.premiumCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: b['serviceType'] == 'home_service'
                                  ? const Color(0xFFFFF4EB)
                                  : const Color(0xFFE8F1FD),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              b['serviceType'] == 'home_service'
                                  ? Icons.home_repair_service_rounded
                                  : (b['serviceType'] == 'rent_drive' ? Icons.car_rental : Icons.directions_car_filled_rounded),
                              color: b['serviceType'] == 'home_service'
                                  ? AppColors.secondary
                                  : AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${b['vehicleType']} • ${b['vehicleNo']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                                ),
                                Text(
                                  '${b['pickupAddress']} ➔ ${b['dropAddress']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${b['fare']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 20),

                      // Status & Partner Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Partner: ${b['driverName']}',
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isCleared ? const Color(0xFFE8F5E9) : const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isCleared ? 'Payment Cleared' : 'Payment: Pending',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isCleared ? Colors.green.shade800 : Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // LIVE TRACKING SHORTCUT FOR BOTH VIEWS
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.navigation_rounded, color: Color(0xFF1A3A6E), size: 18),
                          label: const Text('Live Track on Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A3A6E),
                            side: const BorderSide(color: Color(0xFF1A3A6E)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TrackingScreen(
                                  serviceType: b['serviceType'] ?? 'book_ride',
                                  partnerId: b['driverId'] ?? 'd1',
                                  partnerName: b['driverName'] ?? 'Partner',
                                  partnerPhone: b['driverPhone'] ?? '+91 98301 23456',
                                  vehicleInfo: '${b['vehicleType']} • ${b['vehicleNo']}',
                                  pickupAddress: b['pickupAddress'] ?? 'Pickup Address',
                                  dropAddress: b['dropAddress'] ?? 'Drop Address',
                                  fare: (b['fare'] as num?)?.toDouble() ?? 140.0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // PROVIDER ACTION
                      if (_viewMode == 1) ...[
                        if (!driverConfirmed)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                              label: const Text(
                                'Payment Received - Received',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A5D1A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _handleDriverPaymentConfirmed(b['bookingId']),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified, color: Colors.green, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Payment Confirmed • Rating request sent to Customer',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A5D1A)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],

                      // CUSTOMER VIEW ACTION
                      if (_viewMode == 0) ...[
                        if (driverConfirmed && !ratingGiven)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.star_rate_rounded, color: Colors.amber, size: 22),
                              label: const Text(
                                'Rate Your Experience ⭐',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A3A6E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                RatingDialog.show(
                                  context,
                                  booking: b,
                                  onSubmitted: () => setState(() {}),
                                );
                              },
                            ),
                          )
                        else if (ratingGiven)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Your Rating: ', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                                  ...List.generate(
                                    5,
                                    (starIdx) => Icon(
                                      starIdx < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      b['review']?.isNotEmpty == true ? '"${b['review']}"' : '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // File Complaint Button (Visible 7 days)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (rating <= 3)
                                    Text(
                                      'Low Rating Detected',
                                      style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.bold),
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  TextButton.icon(
                                    icon: const Icon(Icons.report_problem_outlined, size: 16, color: Colors.red),
                                    label: const Text('File Complaint', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                                    onPressed: () => _showFileComplaintDialog(b),
                                  ),
                                ],
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Waiting for partner payment confirmation...',
                                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                              ),
                              TextButton(
                                onPressed: () => _showFileComplaintDialog(b),
                                child: const Text('File Complaint', style: TextStyle(color: Colors.red, fontSize: 11)),
                              ),
                            ],
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
