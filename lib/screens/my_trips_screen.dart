import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  final List<Map<String, dynamic>> _trips = const [
    {
      'type': 'ride',
      'title': 'Sedan Ride to Salt Lake Sector V',
      'partner': 'Subhash Sen (WB 02 CZ 9012)',
      'date': 'Today, 02:45 PM',
      'fare': '₹280',
      'status': 'Completed',
      'rating': 5,
      'icon': Icons.directions_car_filled_rounded,
    },
    {
      'type': 'ride',
      'title': 'Bike Ride from Howrah Station',
      'partner': 'Rajesh Das (WB 02 BB 1024)',
      'date': 'Yesterday, 10:15 AM',
      'fare': '₹30',
      'status': 'Completed',
      'rating': 5,
      'icon': Icons.two_wheeler_rounded,
    },
    {
      'type': 'sebak',
      'title': 'AC Filter Cleaning & Servicing',
      'partner': 'Ranjan Banerjee (Certified AC Sebak)',
      'date': '24 Sep, 11:30 AM',
      'fare': '₹349',
      'status': 'Completed',
      'rating': 5,
      'icon': Icons.home_repair_service_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Trips & Bookings'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _trips.length,
        itemBuilder: (context, index) {
          final trip = _trips[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.premiumCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: trip['type'] == 'ride' ? const Color(0xFFE8F1FD) : const Color(0xFFFFF4EB),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        trip['icon'] as IconData,
                        color: trip['type'] == 'ride' ? AppColors.primary : AppColors.secondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                          ),
                          Text(
                            trip['date'],
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      trip['fare'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      trip['partner'],
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (starIdx) => const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
