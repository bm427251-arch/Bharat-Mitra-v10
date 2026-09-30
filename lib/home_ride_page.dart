import 'package:flutter/material.dart';
import 'common_widgets.dart';
import 'screens/become_driver_screen.dart';
import 'screens/booking_detail_screen.dart';
import 'widgets/active_radar_pulse.dart';
import 'isro_map_page.dart';
import 'services/location_service.dart';

class HomeRidePage extends StatefulWidget {
  const HomeRidePage({super.key});

  @override
  State<HomeRidePage> createState() => _HomeRidePageState();
}

class _HomeRidePageState extends State<HomeRidePage> {
  int _selectedVehicle = 0; // 0: Bike, 1: Auto, 2: Car, 3: Toto
  final TextEditingController _destinationCtrl = TextEditingController(text: 'Barasat Court, Kolkata');
  String _pickupLocation = 'Madhyamgram, Kolkata 700129 (ISRO NavIC)';
  bool _isLocating = false;

  final List<String> _landmarks = [
    'Madhyamgram Chowrasta',
    'Barasat Court',
    'Madhyamgram Station',
    'Jessore Road',
    'Airport Gate 2.5',
  ];

  @override
  void initState() {
    super.initState();
    _fetchLiveLocation();
  }

  Future<void> _fetchLiveLocation() async {
    try {
      final loc = await LocationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _pickupLocation = '${loc.formattedAddress} (Live NavIC)';
        });
      }
    } catch (_) {}
  }

  final List<Map<String, dynamic>> _vehicles = [
    {
      'title': 'Bike',
      'distance': '0.4 km away',
      'eta': '3 mins',
      'icon': Icons.two_wheeler,
      'baseRate': 29.0,
      'pilot': 'Rajesh Kumar (Pilot)',
      'regNo': 'WB 02 BB 1024',
    },
    {
      'title': 'Auto',
      'distance': '0.6 km away',
      'eta': '5 mins',
      'icon': Icons.electric_rickshaw,
      'baseRate': 47.0,
      'pilot': 'Amit Mondal (Auto Pilot)',
      'regNo': 'WB 04 ET 5521',
    },
    {
      'title': 'Car / Cab',
      'distance': '1.1 km away',
      'eta': '7 mins',
      'icon': Icons.directions_car,
      'baseRate': 89.0,
      'pilot': 'Subrata Sen (Cab Pilot)',
      'regNo': 'WB 06 AC 9988',
    },
    {
      'title': 'Toto / E-Rick',
      'distance': '0.3 km away',
      'eta': '2 mins',
      'icon': Icons.electric_rickshaw_outlined,
      'baseRate': 20.0,
      'pilot': 'Bappa Das (Toto Pilot)',
      'regNo': 'WB 08 ER 3321',
    },
  ];

  @override
  void dispose() {
    _destinationCtrl.dispose();
    super.dispose();
  }

  void _confirmAndBook() {
    final v = _vehicles[_selectedVehicle];
    final fare = v['baseRate'] as double;

    // Rate card confirmation dialog showing price only at booking confirmation time (Point 35)
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(v['icon'] as IconData, color: const Color(0xFFFF9933), size: 28),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Rate Card • ${v['title']}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Text(
                        '5% Cheaper than Other Apps • Zero Surge',
                        style: TextStyle(color: Color(0xFF138808), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Base Fare & Distance (ISRO NavIC)', style: TextStyle(color: Colors.white70)),
                  Text('₹${fare.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Platform Savings vs Other Apps', style: TextStyle(color: Color(0xFF138808))),
                  Text('-5% Savings', style: TextStyle(color: Color(0xFF138808), fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(color: Colors.white12, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimated Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    '₹${fare.toStringAsFixed(0)}',
                    style: const TextStyle(color: Color(0xFFFF9933), fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingDetailScreen(
                          providerName: v['pilot'] as String,
                          providerType: 'Driver',
                          distance: v['distance'] as String,
                          eta: v['eta'] as String,
                          amount: fare,
                          serviceCategory: '${v['title']} Ride',
                          vehicleType: '${v['title']} (${v['regNo']})',
                        ),
                      ),
                    );
                  },
                  child: const Text('Confirm Ride & Open Live Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          const CustomPaint(size: Size.infinite, painter: TricolorWatermarkPainter()),
          const BharatMitraWatermark(),
          Column(
            children: [
              const SizedBox(height: 50),

              // HEADER ROW (Location + Driver Profile Create)
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF138808)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.satellite_alt, size: 14, color: Color(0xFF138808)),
                            const SizedBox(width: 6),
                            Text(
                              _pickupLocation,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BecomeDriverScreen()),
                        );
                      },
                      child: const Text(
                        '+ Driver Profile Create',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),

              // ACTIVE PULSING RADAR (Point 19: 3 expanding orange rings, not dead)
              Expanded(
                child: Center(
                  child: ActiveRadarPulse(
                    ringColor: const Color(0xFFFF9933),
                    maxRadius: 110,
                    ringCount: 3,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFF9933), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black87, blurRadius: 12),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _vehicles[_selectedVehicle]['icon'] as IconData,
                            color: const Color(0xFFFF9933),
                            size: 34,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Live Radar',
                            style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // BOTTOM SHEET WITH SEARCH, AUTO-LOCATION & LANDMARKS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 12)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search with Auto Location button (Point 22)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _destinationCtrl,
                            style: const TextStyle(color: Colors.black87, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Where to go? (ISRO Mappls)',
                              hintStyle: TextStyle(color: Colors.black45),
                              prefixIcon: Icon(Icons.search, color: Color(0xFFFF9933)),
                              border: UnderlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        // Auto Location Button
                        IconButton(
                          icon: _isLocating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF138808)),
                                )
                              : const Icon(Icons.my_location, color: Color(0xFF138808)),
                          tooltip: 'Detect NavIC Location',
                          onPressed: () async {
                            setState(() => _isLocating = true);
                            final loc = await LocationService.getCurrentLocation();
                            if (mounted) {
                              setState(() {
                                _isLocating = false;
                                _pickupLocation = '${loc.formattedAddress} (Live NavIC)';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF138808),
                                  content: Text('Auto Location locked via ISRO NavIC: ${loc.area}!'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Nearby Landmarks / Autocomplete (Point 22)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _landmarks.map((landmark) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              label: Text(landmark, style: const TextStyle(fontSize: 10, color: Colors.black87)),
                              backgroundColor: Colors.grey[200],
                              side: BorderSide(color: Colors.grey[300]!),
                              onPressed: () {
                                setState(() => _destinationCtrl.text = '$landmark, Kolkata');
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // RIDE CARDS (NO PRICE ON CARDS - Point 20, 21, 35, 36)
                    Row(
                      children: List.generate(_vehicles.length, (i) {
                        final v = _vehicles[i];
                        final isSel = _selectedVehicle == i;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedVehicle = i),
                            child: Card(
                              elevation: isSel ? 3 : 1,
                              color: isSel ? const Color(0xFFFFF3E0) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: isSel ? const Color(0xFFFF9933) : Colors.grey[300]!,
                                  width: isSel ? 2 : 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                child: Column(
                                  children: [
                                    Icon(v['icon'] as IconData, size: 24, color: isSel ? const Color(0xFFFF9933) : Colors.black87),
                                    const SizedBox(height: 4),
                                    Text(
                                      v['title'] as String,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: isSel ? Colors.black : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    // Mandatory Distance (Point 36)
                                    Text(
                                      v['distance'] as String,
                                      style: const TextStyle(fontSize: 9, color: Colors.black54),
                                    ),
                                    Text(
                                      v['eta'] as String,
                                      style: const TextStyle(fontSize: 9, color: Color(0xFF138808), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),

                    // BOOK NOW BUTTON (Point 21: "5% Cheaper than Other Apps")
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9933),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _confirmAndBook,
                        child: const Text(
                          'Book Now - 5% Cheaper than Other Apps',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
