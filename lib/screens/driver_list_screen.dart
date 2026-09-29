import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  final List<Map<String, dynamic>> _drivers = [
    {
      'id': 'dr_1',
      'name': 'Subhash Ghosh',
      'phone': '+91 98301 23456',
      'experience': 7,
      'rating': 4.9,
      'trips': 142,
      'charge8hr': 700,
      'city': 'Kolkata & Barasat',
      'isAvailable': true,
    },
    {
      'id': 'dr_2',
      'name': 'Rajesh Das',
      'phone': '+91 98302 34567',
      'experience': 5,
      'rating': 4.8,
      'trips': 98,
      'charge8hr': 700,
      'city': 'Salt Lake & New Town',
      'isAvailable': true,
    },
    {
      'id': 'dr_3',
      'name': 'Bikram Saha',
      'phone': '+91 98303 45678',
      'experience': 9,
      'rating': 5.0,
      'trips': 210,
      'charge8hr': 750,
      'city': 'Howrah & Behala',
      'isAvailable': true,
    },
    {
      'id': 'dr_4',
      'name': 'Amit Mondal',
      'phone': '+91 98304 56789',
      'experience': 4,
      'rating': 4.7,
      'trips': 64,
      'charge8hr': 700,
      'city': 'Digha & Coastal Zone',
      'isAvailable': true,
    },
  ];

  void _callDriver(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Calling $phone')),
        );
      }
    }
  }

  void _bookDriver(Map<String, dynamic> driver) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Book Driver: ${driver['name']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${driver['charge8hr']} for 8 Hours • 0% Commission',
                style: const TextStyle(fontSize: 14, color: AppColors.secondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Text(
                'Direct cash or UPI to driver upon completing shift. No advance or platform charges.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.call),
                      label: Text('callDriver'.tr()),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _callDriver(driver['phone']);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Confirm Shift'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Shift booked with ${driver['name']}! Driver will contact you shortly.'),
                            backgroundColor: const Color(0xFF0F766E),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _drivers.length,
      itemBuilder: (context, index) {
        final d = _drivers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF0F766E),
                    child: Text(
                      d['name'][0],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              d['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified_rounded, color: Color(0xFF0F766E), size: 16),
                          ],
                        ),
                        Text(
                          d['city'],
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Text(
                      '₹${d['charge8hr']}/8hrs',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 3),
                      Text('⭐ ${d['rating']} (${d['trips']} Shifts)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.badge_rounded, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text('${d['experience']} Yrs Exp', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.call, size: 16),
                      label: Text('callDriver'.tr()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F766E),
                        side: const BorderSide(color: Color(0xFF0F766E)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _callDriver(d['phone']),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: Text('bookDriver'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _bookDriver(d),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 350.ms);
      },
    );
  }
}
