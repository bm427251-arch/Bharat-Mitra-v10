import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/rating_service.dart';
import '../services/firestore_service.dart';

class RatingDialog extends StatefulWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onSubmitted;

  const RatingDialog({
    super.key,
    required this.booking,
    this.onSubmitted,
  });

  /// Static helper to trigger the dialog automatically
  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> booking,
    VoidCallback? onSubmitted,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        booking: booking,
        onSubmitted: onSubmitted,
      ),
    );
  }

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedStars = 5;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _starLabels = [
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent! ⭐',
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    final bookingId = widget.booking['bookingId']?.toString() ?? '';
    final driverId = widget.booking['driverId']?.toString();
    final reviewText = _reviewController.text.trim();

    await RatingService().submitRating(
      bookingId: bookingId,
      rating: _selectedStars,
      review: reviewText,
      driverId: driverId,
    );

    // If rating <= 3, automatically log complaint record for admin review
    if (_selectedStars <= 3) {
      await FirestoreService().fileComplaint({
        'bookingId': bookingId,
        'serviceType': widget.booking['serviceType'] ?? 'ride',
        'customerId': widget.booking['customerId'] ?? 'user_current',
        'customerName': widget.booking['customerName'] ?? 'Bharat Customer',
        'providerId': driverId ?? '',
        'providerName': widget.booking['driverName'] ?? 'Partner',
        'complaintType': 'Low Rating (${_selectedStars} Stars)',
        'description': reviewText.isEmpty ? 'Customer rated $_selectedStars stars' : reviewText,
        'status': 'pending_admin',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you! Your rating has been submitted successfully ⭐'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );

      widget.onSubmitted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverName = widget.booking['driverName'] ?? 'Partner';
    final vehicleNo = widget.booking['vehicleNo'] ?? '';
    final fare = widget.booking['fare']?.toString() ?? '0';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration Badge Icon
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: AppColors.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: AppColors.success,
                  size: 38,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 14),

              // Title: "Ride Completed! 🎉"
              const Text(
                'Ride Completed! 🎉',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A3A6E),
                ),
              ),

              const SizedBox(height: 6),

              // English confirmation text
              Text(
                '$driverName ($vehicleNo)\nconfirmed payment (₹$fare) received. How was the service?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 14),

              // Rating label badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: const Text(
                  'Rate Your Experience ⭐',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 5 Star Animation (tap to select)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starNum = index + 1;
                  final isFilled = starNum <= _selectedStars;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStars = starNum;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedScale(
                        scale: isFilled ? 1.15 : 0.95,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        child: Icon(
                          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: isFilled ? Colors.amber.shade600 : Colors.grey.shade400,
                          size: 38,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 8),

              // Sentiment description text
              Text(
                _starLabels[_selectedStars - 1],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _selectedStars >= 4
                      ? Colors.green.shade700
                      : (_selectedStars == 3 ? Colors.orange.shade800 : Colors.red.shade700),
                ),
              ),

              const SizedBox(height: 18),

              // TextField: "Review (Optional)"
              TextField(
                controller: _reviewController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Write a review (Optional)',
                  hintText: 'Share your feedback about the service...',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF1A3A6E), width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Low rating warning notice
              if (_selectedStars <= 3)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Not satisfied? This will also be sent to Admin for quick investigation.',
                          style: TextStyle(fontSize: 11.5, color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A6E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Submit Rating',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
