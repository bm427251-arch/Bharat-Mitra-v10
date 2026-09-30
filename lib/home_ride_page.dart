import 'package:flutter/material.dart';
import 'common_widgets.dart';
import 'screens/become_driver_screen.dart';
import 'screens/home_ride_screen.dart';
import 'isro_map_page.dart';

class HomeRidePage extends StatefulWidget {
  const HomeRidePage({super.key});

  @override
  State<HomeRidePage> createState() => _HomeRidePageState();
}

class _HomeRidePageState extends State<HomeRidePage> {
  int _selectedVehicle = 0; // 0: Bike, 1: Auto, 2: Car

  double calcComm(double fare) => fare * 0.15; // Ola 20% - Apni 15% - 5% Kom

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.grey[900]),
          const CustomPaint(size: Size.infinite, painter: TricolorWatermarkPainter()),
          const BharatMitraWatermark(),
          Column(
            children: [
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ISROMapPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF138808)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.satellite_alt, size: 14, color: Color(0xFF138808)),
                            SizedBox(width: 6),
                            Text(
                              'Kolkata, 700158 (ISRO)',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9933),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BecomeDriverScreen()),
                        );
                      },
                      child: const Text(
                        '+ Driver Profile Create',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Where to go?',
                        prefixIcon: Icon(Icons.search, color: Color(0xFFFF9933)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedVehicle = 0),
                            child: Card(
                              color: _selectedVehicle == 0 ? const Color(0xFFFFF3E0) : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: _selectedVehicle == 0
                                      ? const Color(0xFFFF9933)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: const ListTile(
                                dense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                title: Text(
                                  'Bike ₹29',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                subtitle: Text(
                                  '15% Comm',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF138808),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedVehicle = 1),
                            child: Card(
                              color: _selectedVehicle == 1 ? const Color(0xFFFFF3E0) : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: _selectedVehicle == 1
                                      ? const Color(0xFFFF9933)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: const ListTile(
                                dense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                title: Text(
                                  'Auto ₹47',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                subtitle: Text(
                                  '15% Comm',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF138808),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedVehicle = 2),
                            child: Card(
                              color: _selectedVehicle == 2 ? const Color(0xFFFFF3E0) : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: _selectedVehicle == 2
                                      ? const Color(0xFFFF9933)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: const ListTile(
                                dense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                title: Text(
                                  'Car ₹89',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                subtitle: Text(
                                  '15% Comm',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF138808),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9933),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          final names = ['Bike (₹29)', 'Auto (₹47)', 'Car (₹89)'];
                          final fares = [29.0, 47.0, 89.0];
                          final fare = fares[_selectedVehicle];
                          final comm = calcComm(fare);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF138808),
                              content: Text(
                                'Booked ${names[_selectedVehicle]}! Fare: ₹$fare (Our Comm: ₹${comm.toStringAsFixed(1)} vs Ola 20%: ₹${(fare * 0.20).toStringAsFixed(1)} - 5% Cheaper!)',
                              ),
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeRideScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Book Now - 5% Cheaper than Ola',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
