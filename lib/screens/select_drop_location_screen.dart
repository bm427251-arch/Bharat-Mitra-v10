import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/mappls_service.dart';
import '../widgets/platform_map.dart';
import '../theme/app_theme.dart';

class SelectDropLocationScreen extends StatefulWidget {
  final LatLng currentLatLng;

  const SelectDropLocationScreen({
    super.key,
    this.currentLatLng = const LatLng(22.7244, 88.4781), // Default Barasat
  });

  @override
  State<SelectDropLocationScreen> createState() => _SelectDropLocationScreenState();
}

class _SelectDropLocationScreenState extends State<SelectDropLocationScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final MapplsService _mapplsService = MapplsService();
  String _selectedChip = 'Hospitals';
  List<Map<String, dynamic>> _places = [];
  bool _isLoading = false;
  LatLng _selectedLatLng = const LatLng(22.7244, 88.4781);
  String _selectedAddress = '';

  final List<Map<String, dynamic>> _chips = [
    {'name': 'Hospitals', 'icon': Icons.local_hospital_rounded},
    {'name': 'Railway Station', 'icon': Icons.train_rounded},
    {'name': 'Bus Stand', 'icon': Icons.directions_bus_rounded},
    {'name': 'Temple', 'icon': Icons.temple_hindu_rounded},
    {'name': 'College', 'icon': Icons.school_rounded},
    {'name': 'Mall', 'icon': Icons.local_mall_rounded},
    {'name': 'ATM', 'icon': Icons.atm_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLatLng = widget.currentLatLng;
    _loadNearbyPlaces(_selectedChip);
  }

  Future<void> _loadNearbyPlaces(String chip) async {
    setState(() {
      _isLoading = true;
      _selectedChip = chip;
    });

    final results = await _mapplsService.searchNearby(
      widget.currentLatLng.latitude,
      widget.currentLatLng.longitude,
      chip,
    );

    if (mounted) {
      setState(() {
        _places = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _onSearch(String query) async {
    if (query.trim().isEmpty) {
      _loadNearbyPlaces(_selectedChip);
      return;
    }
    setState(() => _isLoading = true);
    final results = await _mapplsService.searchNearby(
      widget.currentLatLng.latitude,
      widget.currentLatLng.longitude,
      query,
    );
    if (mounted) {
      setState(() {
        _places = results;
        _isLoading = false;
      });
    }
  }

  IconData _getIconForCategory(String? iconType, String? name) {
    final cat = (iconType ?? name ?? '').toLowerCase();
    if (cat.contains('hospital')) return Icons.local_hospital_rounded;
    if (cat.contains('train') || cat.contains('station') || cat.contains('railway')) return Icons.train_rounded;
    if (cat.contains('bus')) return Icons.directions_bus_rounded;
    if (cat.contains('temple')) return Icons.temple_hindu_rounded;
    if (cat.contains('college') || cat.contains('school')) return Icons.school_rounded;
    if (cat.contains('mall')) return Icons.local_mall_rounded;
    if (cat.contains('atm')) return Icons.atm_rounded;
    return Icons.location_on_rounded;
  }

  void _selectAndReturn(Map<String, dynamic> place) {
    final lat = (place['lat'] as num?)?.toDouble() ?? _selectedLatLng.latitude;
    final lng = (place['lng'] as num?)?.toDouble() ?? _selectedLatLng.longitude;
    final name = place['placeName']?.toString() ?? 'Selected Location';
    final addr = place['address']?.toString() ?? name;
    final dist = place['distance']?.toString() ?? '0 km';

    Navigator.pop(context, {
      'address': name,
      'fullAddress': addr,
      'lat': lat,
      'lng': lng,
      'distanceKm': dist,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Drop Location'),
        backgroundColor: const Color(0xFF1A3A6E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search place, hospital, station...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1A3A6E)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          _loadNearbyPlaces(_selectedChip);
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),

          // Horizontal Important Places Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _chips.map((chip) {
                  final isSelected = _selectedChip == chip['name'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      avatar: Icon(
                        chip['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : const Color(0xFF1A3A6E),
                      ),
                      label: Text(chip['name'] as String),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF1A3A6E),
                      ),
                      selectedColor: const Color(0xFF1A3A6E),
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF1A3A6E) : Colors.transparent,
                        ),
                      ),
                      onSelected: (_) => _loadNearbyPlaces(chip['name'] as String),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Mini PlatformMap view
          SizedBox(
            height: 140,
            width: double.infinity,
            child: PlatformMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLatLng,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('selected_point'),
                  position: _selectedLatLng,
                  infoWindow: InfoWindow(title: _selectedAddress.isNotEmpty ? _selectedAddress : 'Drop Location'),
                ),
              },
            ),
          ),

          // ListView of Nearby Important Places
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _places.isEmpty
                    ? const Center(child: Text('No nearby places found'))
                    : ListView.separated(
                        itemCount: _places.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
                        itemBuilder: (context, index) {
                          final place = _places[index];
                          final placeName = place['placeName']?.toString() ?? 'Place';
                          final address = place['address']?.toString() ?? '';
                          final distance = place['distance']?.toString() ?? '';
                          final icon = place['icon']?.toString();

                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A3A6E).withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getIconForCategory(icon, placeName),
                                color: const Color(0xFF1A3A6E),
                                size: 22,
                              ),
                            ),
                            title: Text(
                              placeName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            trailing: distance.isNotEmpty
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      distance,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                  )
                                : null,
                            onTap: () {
                              final pLat = (place['lat'] as num?)?.toDouble() ?? _selectedLatLng.latitude;
                              final pLng = (place['lng'] as num?)?.toDouble() ?? _selectedLatLng.longitude;
                              setState(() {
                                _selectedLatLng = LatLng(pLat, pLng);
                                _selectedAddress = placeName;
                              });
                              _selectAndReturn(place);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
