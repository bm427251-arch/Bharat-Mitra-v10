import 'package:flutter/material.dart';
import 'common_widgets.dart';
import 'screens/become_sebak_screen.dart';

class TechnicianPage extends StatelessWidget {
  const TechnicianPage({super.key});

  double calcComm(double bill) => bill * 0.20; // Urban 25% - Apni 20%

  final Map<String, IconData> _serviceIcons = const {
    'Plumber': Icons.plumbing,
    'Electrician': Icons.electrical_services,
    'AC Repair': Icons.ac_unit,
    'Mechanic': Icons.car_repair,
    'Carpenter': Icons.carpenter,
    'Painter': Icons.format_paint,
  };

  final Map<String, int> _baseVisitingCharge = const {
    'Plumber': 149,
    'Electrician': 149,
    'AC Repair': 249,
    'Mechanic': 199,
    'Carpenter': 199,
    'Painter': 199,
  };

  @override
  Widget build(BuildContext context) {
    final services = [
      'Plumber',
      'Electrician',
      'AC Repair',
      'Mechanic',
      'Carpenter',
      'Painter',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Technicians - 20% Comm',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          const CustomPaint(size: Size.infinite, painter: TricolorWatermarkPainter()),
          const BharatMitraWatermark(),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9933),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BecomeSebakScreen()),
                      );
                    },
                    icon: const Icon(Icons.person_add_alt_1, size: 20),
                    label: const Text(
                      '+ Become Technician - Create Profile',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  childAspectRatio: 1.25,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: services.map((e) {
                    final icon = _serviceIcons[e] ?? Icons.handyman;
                    final charge = _baseVisitingCharge[e] ?? 149;
                    final comm = calcComm(charge.toDouble());

                    return Card(
                      color: const Color(0xFF181818),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Colors.white12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (dCtx) => AlertDialog(
                              backgroundColor: const Color(0xFF1E1E1E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Row(
                                children: [
                                  Icon(icon, color: const Color(0xFFFF9933)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Book $e',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Visiting Charge: ₹$charge',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Bharat Mitra Commission: 20% (₹${comm.toStringAsFixed(0)})\nUrban Company charges 25% — You save 5% with Bharat Mitra!',
                                    style: const TextStyle(
                                      color: Color(0xFF138808),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Technician arrives in 20-30 mins with verified identity and sanitized tools.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dCtx),
                                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF9933),
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(dCtx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(0xFF138808),
                                        content: Text('$e booked successfully! Visiting charge: ₹$charge.'),
                                      ),
                                    );
                                  },
                                  child: const Text('Confirm Visit', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon, color: const Color(0xFFFF9933), size: 36),
                              const SizedBox(height: 8),
                              Text(
                                e,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'From ₹$charge • 20% Comm',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
