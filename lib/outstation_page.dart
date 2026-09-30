import 'package:flutter/material.dart';
import 'common_widgets.dart';
import 'screens/owner_add_vehicle_screen.dart';
import 'screens/booking_detail_screen.dart';

class OutstationPage extends StatelessWidget {
  const OutstationPage({super.key});

  final List<Map<String, dynamic>> _fleetVehicles = const [
    {
      'type': 'Car (Innova Crysta / Ertiga)',
      'owner': 'Swapan Mukherjee (Fleet Owner)',
      'route': 'Digha / Mandarmani / Bolpur / Sundarbans',
      'distance': '1.2 km away',
      'icon': Icons.directions_car,
      'baseRate': 1800.0,
      'seats': '7 Seater AC',
    },
    {
      'type': 'Mountain Royal Enfield Bike',
      'owner': 'Tenzing Bhutia (Mountain Fleet)',
      'route': 'Darjeeling / Sandakphu / Hill Circuit',
      'distance': '0.9 km away',
      'icon': Icons.two_wheeler,
      'baseRate': 800.0,
      'seats': '2 Seater 350cc',
    },
    {
      'type': 'Rural Auto & Toto Fleet',
      'owner': 'Bikash Das (Gramin Sangh)',
      'route': 'Gram Haat to Railway Junction / Sundarbans Gate',
      'distance': '0.4 km away',
      'icon': Icons.electric_rickshaw,
      'baseRate': 500.0,
      'seats': '4 Seater Eco',
    },
    {
      'type': 'Beach Toto Safari',
      'owner': 'Mandarmani Local Toto Guild',
      'route': 'Beach Trail, Tajpur & Shankarpur Connect',
      'distance': '0.7 km away',
      'icon': Icons.electric_rickshaw_outlined,
      'baseRate': 450.0,
      'seats': '6 Seater',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          title: const Text(
            'Outstation + Rural - Bike/Car/Auto/Toto',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
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
                // TabBar for Self-Drive vs With Driver
                Container(
                  color: const Color(0xFF161616),
                  child: const TabBar(
                    indicatorColor: Color(0xFFFF9933),
                    indicatorWeight: 3,
                    labelColor: Color(0xFFFF9933),
                    unselectedLabelColor: Colors.white60,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: [
                      Tab(text: 'Self-Drive'),
                      Tab(text: 'With Driver'),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: TextField(
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Search Mandarmani Toto, Darjeeling Bike, Rural Auto...',
                      hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFFF9933)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Header Info (Point 29: "Where Other Apps Not Available")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    children: [
                      const Text(
                        'Where Other Apps Not Available - Tourist Spot + Gram - All Vehicles',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF9933),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF138808),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const OwnerAddVehicleScreen()),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 16),
                          label: const Text(
                            '+ Fleet Owner Profile Create - Add Vehicle',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // VEHICLES LIST (Point 30: Owner profile, car photo, distance, tracking)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    itemCount: _fleetVehicles.length,
                    itemBuilder: (_, i) {
                      final item = _fleetVehicles[i];
                      final fare = item['baseRate'] as double;

                      return Card(
                        color: const Color(0xFF181818),
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: Colors.white12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            // Rate card confirmation dialog showing price only at booking confirmation time (Point 35)
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
                                        Icon(item['icon'] as IconData, color: const Color(0xFFFF9933), size: 28),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['type'] as String,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            Text(item['owner'] as String, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Divider(color: Colors.white12, height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Base Outstation / Rural Day Rate', style: TextStyle(color: Colors.white70)),
                                        Text('₹${fare.toStringAsFixed(0)} / Day', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Distance via NavIC', style: TextStyle(color: Colors.blueAccent)),
                                        Text(item['distance'] as String, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const Divider(color: Colors.white12, height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total Estimated Package', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                        Text('₹${fare.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFFF9933), fontWeight: FontWeight.bold, fontSize: 20)),
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
                                                providerName: item['owner'] as String,
                                                providerType: 'Outstation Fleet',
                                                distance: item['distance'] as String,
                                                eta: '25 mins away',
                                                amount: fare,
                                                serviceCategory: 'Outstation & Rural Trip',
                                                vehicleType: '${item['type']} • ${item['seats']}',
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('Confirm Outstation Booking', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFFFF9933).withOpacity(0.18),
                                  child: Icon(item['icon'] as IconData, color: const Color(0xFFFF9933), size: 28),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['type'] as String,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item['owner'] as String,
                                        style: const TextStyle(color: Color(0xFFFF9933), fontSize: 11),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['route'] as String,
                                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.near_me, size: 12, color: Colors.blueAccent),
                                          const SizedBox(width: 4),
                                          Text(
                                            item['distance'] as String,
                                            style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            item['seats'] as String,
                                            style: const TextStyle(color: Colors.white54, fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Colors.white38),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
