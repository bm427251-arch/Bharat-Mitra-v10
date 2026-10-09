import 'package:flutter/material.dart';
import 'common_widgets.dart';
import 'screens/become_sebak_screen.dart';
import 'screens/booking_detail_screen.dart';

class TechnicianPage extends StatelessWidget {
  const TechnicianPage({super.key});

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

  final Map<String, String> _technicianNames = const {
    'Plumber': 'Manoj Sarkar (Plumbing Specialist)',
    'Electrician': 'Subhash Sen (Licensed Wireman)',
    'AC Repair': 'Aniket Roy (HVAC & AC Expert)',
    'Mechanic': 'Tapas Das (Auto & 2-Wheeler)',
    'Carpenter': 'Ratan Mondal (Furniture Master)',
    'Painter': 'Biplab Paul (Home & Waterproofing)',
  };

  final Map<String, String> _distances = const {
    'Plumber': '0.7 km away',
    'Electrician': '0.9 km away',
    'AC Repair': '1.4 km away',
    'Mechanic': '0.5 km away',
    'Carpenter': '1.2 km away',
    'Painter': '1.8 km away',
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
        // Point 23: Technician header remove "20% Comm" - Only "Technicians"
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technicians',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Verified Home & Service Experts • ISRO NavIC',
              style: TextStyle(color: Color(0xFFFF9933), fontSize: 10),
            ),
          ],
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
              // ACTION BUTTON (+ Become Tech)
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

              // SERVICES GRID (PRICE POLICY GLOBAL: NO PRICE ON CARDS - Point 23, 35, 36)
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
                    final techName = _technicianNames[e] ?? 'Certified Expert';
                    final distance = _distances[e] ?? '0.8 km away';

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
                          // Show Rate card confirmation dialog (Point 35: Show price only at booking confirmation time)
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: const Color(0xFF161616),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (ctx) => Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(icon, color: const Color(0xFFFF9933), size: 28),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$e Service Rate Card',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Text(
                                            'Assigned: $techName',
                                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(color: Colors.white12, height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Standard Inspection & Visit Charge', style: TextStyle(color: Colors.white70)),
                                      Text('₹$charge', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Distance via NavIC', style: TextStyle(color: Colors.blueAccent)),
                                      Text(distance, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const Divider(color: Colors.white12, height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Total Inspection Fare', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                      Text(
                                        '₹$charge',
                                        style: const TextStyle(color: Color(0xFFFF9933), fontWeight: FontWeight.bold, fontSize: 20),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF9933),
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BookingDetailScreen(
                                              providerName: techName,
                                              providerType: 'Technician',
                                              distance: distance,
                                              eta: '12 mins',
                                              amount: charge.toDouble(),
                                              serviceCategory: '$e Service Visit',
                                              vehicleType: 'Tool Bag & Emergency Kit',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Confirm & Open Live Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFFF9933).withOpacity(0.18),
                                child: Icon(icon, color: const Color(0xFFFF9933), size: 24),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                e,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Distance mandatory on all cards (Point 36)
                              Text(
                                distance,
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'NavIC Verified Sebak',
                                style: TextStyle(
                                  color: Color(0xFF138808),
                                  fontSize: 9,
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
