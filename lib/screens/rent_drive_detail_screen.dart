import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/rent_vehicle_model.dart';
import '../services/rating_service.dart';
import 'tracking_screen.dart';

class RentDriveDetailScreen extends StatefulWidget {
  final RentVehicleModel vehicle;

  const RentDriveDetailScreen({super.key, required this.vehicle});

  @override
  State<RentDriveDetailScreen> createState() => _RentDriveDetailScreenState();
}

class _RentDriveDetailScreenState extends State<RentDriveDetailScreen> {
  int _activePhotoIndex = 0;
  bool _agreedToDamageInspection = false;
  bool _isBooking = false;

  void _callOwner() async {
    final Uri url = Uri(scheme: 'tel', path: widget.vehicle.ownerPhone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _handleBookNow() async {
    if (!_agreedToDamageInspection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check and agree to the 4-photo vehicle inspection policy.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isBooking = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final bookingId = 'bk_rent_${DateTime.now().millisecondsSinceEpoch}';
    RatingService().addBooking({
      'bookingId': bookingId,
      'serviceType': 'rent_drive',
      'customerId': 'user_current',
      'customerName': 'Bharat Customer',
      'driverId': widget.vehicle.ownerId,
      'driverName': widget.vehicle.ownerName,
      'driverPhone': widget.vehicle.ownerPhone,
      'vehicleType': widget.vehicle.modelName,
      'vehicleNo': widget.vehicle.rcNumber,
      'pickupAddress': '${widget.vehicle.ownerName} Garage, ${widget.vehicle.city}',
      'dropAddress': 'Self-Drive Pan India',
      'fare': widget.vehicle.dailyRent,
      'status': 'accepted',
      'paymentStatus': 'pending',
      'driverConfirmed': false,
      'ratingGiven': false,
    });

    if (mounted) {
      setState(() => _isBooking = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TrackingScreen(
            serviceType: 'rent_drive',
            partnerId: widget.vehicle.ownerId,
            partnerName: widget.vehicle.ownerName,
            partnerPhone: widget.vehicle.ownerPhone,
            vehicleInfo: '${widget.vehicle.modelName} • ${widget.vehicle.rcNumber}',
            pickupAddress: '${widget.vehicle.ownerName} Garage, ${widget.vehicle.city}',
            dropAddress: 'Self-Drive Exploration',
            fare: widget.vehicle.dailyRent,
            rating: widget.vehicle.avgRating,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final photos = v.photos.isNotEmpty
        ? v.photos
        : [
            'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=600&q=80',
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text(v.modelName),
        backgroundColor: const Color(0xFF1A3A6E),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 4 Photos Swipe Carousel
            Stack(
              children: [
                SizedBox(
                  height: 240,
                  child: PageView.builder(
                    itemCount: photos.length,
                    onPageChanged: (i) => setState(() => _activePhotoIndex = i),
                    itemBuilder: (context, i) {
                      return Image.network(
                        photos[i],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Photo ${_activePhotoIndex + 1}/${photos.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          v.modelName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '₹${v.dailyRent.toInt()}/day',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Location: ${v.city} • RC: ${v.rcNumber}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 16),

                  // Highlights Grid
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Deposit', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text('₹${v.deposit.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const Text('Refundable', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Commission', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 4),
                              const Text('0%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF16A34A))),
                              const Text('Direct to Owner', style: TextStyle(fontSize: 10, color: Colors.blueGrey)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Owner Rating', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text('⭐ ${v.avgRating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('${v.totalRatings} ratings', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Owner Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFF1A3A6E),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(v.ownerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('Verified Owner • ${v.city} Garage', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        IconButton.filled(
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                          icon: const Icon(Icons.call, color: Colors.white, size: 20),
                          onPressed: _callOwner,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Damage Policy Requirement
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.camera_alt, color: Colors.amber.shade900, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Damage Policy & Inspection',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber.shade900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'You must take 4 photos of vehicle (front, back, left, right) before ride and 4 photos after drop. This protects your security deposit.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _agreedToDamageInspection,
                          activeColor: const Color(0xFF1A3A6E),
                          title: const Text(
                            'I will take 4 photos before & after trip',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                          onChanged: (val) => setState(() => _agreedToDamageInspection = val ?? false),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Book Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3A6E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _isBooking ? null : _handleBookNow,
                      child: _isBooking
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Book Now (Direct UPI to Owner - 0% Commission)',
                              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
