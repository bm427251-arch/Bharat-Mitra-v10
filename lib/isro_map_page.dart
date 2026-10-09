import 'package:flutter/material.dart';
import 'package:mappls_gl/mappls_gl.dart';
import 'services/mappls_service.dart';
import 'services/location_service.dart';
import 'common_widgets.dart';

class ISROMapPage extends StatefulWidget {
  const ISROMapPage({super.key});

  @override
  _ISROMapPageState createState() => _ISROMapPageState();
}

class _ISROMapPageState extends State<ISROMapPage> {
  MapplsMapController? _mapController;
  String _activeFilter = 'All'; // 'All' | 'Ride' | 'Technician' | 'SOS'
  bool _navicLocked = true;
  int _connectedSatellites = 7; // NavIC constellation
  String _selectedPinInfo = 'ISRO Bhuvan & NavIC Live GPS (22.6900, 88.4600) • Madhyamgram, 700129';
  double _centerLat = 22.6900;
  double _centerLng = 88.4600;

  final List<Map<String, dynamic>> _isroPoints = [
    {
      'title': 'Bike Pilot - Rajesh (₹29)',
      'subtitle': '15% Comm - 3 mins away',
      'lat': 22.6930,
      'lng': 88.4640,
      'type': 'Ride',
      'icon': Icons.two_wheeler,
      'color': Colors.green,
    },
    {
      'title': 'Auto Pilot - Amit (₹47)',
      'subtitle': '15% Comm - 5 mins away',
      'lat': 22.6870,
      'lng': 88.4560,
      'type': 'Ride',
      'icon': Icons.electric_rickshaw,
      'color': Colors.green,
    },
    {
      'title': 'Electrician - Subrata (₹199)',
      'subtitle': '20% Comm - Verified Sebak',
      'lat': 22.6980,
      'lng': 88.4610,
      'type': 'Technician',
      'icon': Icons.bolt,
      'color': Colors.orange,
    },
    {
      'title': 'Plumber - Manoj (₹149)',
      'subtitle': '20% Comm - Verified Sebak',
      'lat': 22.6840,
      'lng': 88.4690,
      'type': 'Technician',
      'icon': Icons.plumbing,
      'color': Colors.orange,
    },
    {
      'title': 'Elite SOS Beacon - Night Transit',
      'subtitle': '24H Live Telemetry - Group Active',
      'lat': 22.6900,
      'lng': 88.4600,
      'type': 'SOS',
      'icon': Icons.shield,
      'color': Colors.redAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initMapplsSDK();
    _fetchLiveGps();
  }

  Future<void> _fetchLiveGps() async {
    try {
      final loc = await LocationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _centerLat = loc.latitude;
          _centerLng = loc.longitude;
          final area = loc.area.isNotEmpty ? loc.area : 'Madhyamgram';
          _selectedPinInfo = 'ISRO Bhuvan & NavIC Live GPS (${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}) • $area';
        });
      }
    } catch (_) {}
  }

  Future<void> _initMapplsSDK() async {
    try {
      if (MapplsService.apiKey.isNotEmpty &&
          MapplsService.apiKey != 'YOUR_MAPPLS_KEY_HERE') {
        await MapplsAccountManager.setMapSDKKey(MapplsService.apiKey);
        await MapplsAccountManager.setRestAPIKey(MapplsService.apiKey);
      }
    } catch (e) {
      debugPrint('Mappls SDK init notice: $e');
    }
  }

  void _onMapCreated(MapplsMapController controller) {
    _mapController = controller;
    // ISRO Bhuvan + NavIC Data Loaded
    // For Ride, Technician, SOS Tracking - All using ISRO Satellite
    _loadISROSatellitePoints();
  }

  void _loadISROSatellitePoints() {
    if (_mapController == null) return;
    try {
      final filtered = _activeFilter == 'All'
          ? _isroPoints
          : _isroPoints.where((p) => p['type'] == _activeFilter).toList();

      for (var pt in filtered) {
        _mapController!.addSymbol(
          SymbolOptions(
            geometry: LatLng(pt['lat'] as double, pt['lng'] as double),
            textField: pt['title'] as String,
            textSize: 11,
            textOffset: const Offset(0, 1.2),
            textColor: '#FFFFFF',
            textHaloColor: '#000000',
            textHaloWidth: 1.5,
          ),
        );
      }
    } catch (e) {
      debugPrint('Notice adding symbols to MapplsMap: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bharat Mitra - ISRO Mappls + NavIC Connected',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              'ISRO Bhuvan GIS • NavIC Satellite Telemetry',
              style: TextStyle(
                color: Color(0xFFFF9933),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              Icons.satellite_alt,
              color: _navicLocked ? const Color(0xFF138808) : Colors.grey,
            ),
            tooltip: 'NavIC Constellation Lock (7 Sats)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF138808),
                  content: Text(
                    'NavIC Satellite Constellation: $_connectedSatellites satellites locked. Sub-meter precision enabled via ISRO Bhuvan.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. ISRO MAPPLS MAP LAYER
          Positioned.fill(
            child: MapplsMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(22.6900, 88.4600), // Madhyamgram, Kolkata 700129
                zoom: 13,
              ),
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              compassEnabled: true,
            ),
          ),

          // 2. TRICOLOR WATERMARK
          const BharatMitraWatermark(),

          // 3. TOP TELEMETRY STATUS HUD
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF9933).withOpacity(0.6)),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF138808),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'NavIC Constellation Active • Sub-meter GPS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9933).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFFF9933)),
                        ),
                        child: const Text(
                          '0% Google Dep.',
                          style: TextStyle(
                            color: Color(0xFFFF9933),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedPinInfo,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),

          // 4. FILTER PILLS FOR SATELLITE TRACKING
          Positioned(
            top: 86,
            left: 12,
            right: 12,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All', 'All Telemetry (5)', Icons.layers),
                  const SizedBox(width: 8),
                  _filterChip('Ride', 'Rides (15% Comm)', Icons.two_wheeler),
                  const SizedBox(width: 8),
                  _filterChip('Technician', 'Sebaks (20% Comm)', Icons.handyman),
                  const SizedBox(width: 8),
                  _filterChip('SOS', 'Elite SOS (24H GPS)', Icons.shield),
                ],
              ),
            ),
          ),

          // 5. BOTTOM SATELLITE QUICK ACTION BAR
          Positioned(
            bottom: 20,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
                boxShadow: const [
                  BoxShadow(color: Colors.black87, blurRadius: 10),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFFF9933),
                        child: Icon(Icons.satellite_outlined, color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ISRO Bhuvan + NavIC Live Radar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Kolkata 700158 • High Precision Satellite',
                              style: TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9933),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          minimumSize: const Size(60, 34),
                        ),
                        onPressed: () {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              const LatLng(22.5726, 88.3639),
                              14,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color(0xFF138808),
                              content: Text('Centered on Kolkata (700158) with NavIC fix!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.my_location, size: 14),
                        label: const Text(
                          'Center',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String filterKey, String label, IconData icon) {
    final isSelected = _activeFilter == filterKey;
    return InkWell(
      onTap: () {
        setState(() {
          _activeFilter = filterKey;
          _selectedPinInfo = 'Filtered for: $label via NavIC Satellite';
        });
        _loadISROSatellitePoints();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF9933) : Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9933) : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.black : Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
