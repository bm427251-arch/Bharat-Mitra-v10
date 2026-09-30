import 'package:flutter/material.dart';
import 'common_widgets.dart';
import 'screens/owner_add_vehicle_screen.dart';

class OutstationPage extends StatelessWidget {
  const OutstationPage({super.key});

  final List<String> vehicles = const ['Bike', 'Car', 'Auto', 'Toto', 'E-Rickshaw'];

  final Map<String, IconData> _vehicleIcons = const {
    'Bike': Icons.two_wheeler,
    'Car': Icons.directions_car,
    'Auto': Icons.electric_rickshaw,
    'Toto': Icons.moped,
    'E-Rickshaw': Icons.electric_rickshaw,
  };

  final Map<String, String> _spots = const {
    'Bike': 'Darjeeling / Sandakphu / Hill Sprint • ₹800/Day',
    'Car': 'Digha / Mandarmani / Bolpur • ₹1,800/Day',
    'Auto': 'Gram to Junction / Sundarbans Gate • ₹600/Day',
    'Toto': 'Mandarmani Beach / Shantiniketan • ₹500/Day',
    'E-Rickshaw': 'Rural Haat & Village Tour • ₹450/Day',
  };

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
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: [
                      Tab(text: 'Self-Drive'),
                      Tab(text: 'With Driver'),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText:
                          'Search Mandarmani Toto, Darjeeling Bike, Rural Auto...',
                      hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFFF9933)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Header Info and Subscription details
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      const Text(
                        'Where Ola/Uber Not Available - Tourist Spot + Gram - All Vehicles',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF9933),
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Sub: Starter 499/2 Car | Pro 999/5 Car | Fleet 1999/Unlimited',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9933),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OwnerAddVehicleScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          '+ Fleet Owner Profile Create - Add Bike/Car/Auto/Toto',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                // Vehicle List
                Expanded(
                  child: ListView.builder(
                    itemCount: 8,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (_, i) {
                      final vName = vehicles[i % 5];
                      final icon = _vehicleIcons[vName] ?? Icons.directions_car;
                      final spotInfo = _spots[vName] ?? 'Tourist & Rural Route';

                      return Card(
                        color: const Color(0xFF181818),
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF138808).withOpacity(0.2),
                            child: Icon(icon, color: const Color(0xFF138808)),
                          ),
                          title: Text(
                            'Owner Vehicle - $vName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                spotInfo,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Tourist + Rural - Subscription Active',
                                style: TextStyle(
                                  color: Color(0xFFFF9933),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF138808),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              minimumSize: const Size(60, 32),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF138808),
                                  content: Text(
                                    'Selected $vName for Outstation / Rural travel! Direct Owner Contact unlocked.',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Book',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
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
