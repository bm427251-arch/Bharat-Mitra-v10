import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/rent_vehicle_model.dart';
import '../services/firestore_service.dart';
import 'rent_drive_detail_screen.dart';

class RentDriveScreen extends StatefulWidget {
  const RentDriveScreen({super.key});

  @override
  State<RentDriveScreen> createState() => _RentDriveScreenState();
}

class _RentDriveScreenState extends State<RentDriveScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final List<String> _cities = [
    'All Cities',
    'Goa',
    'Manali',
    'Digha',
    'Darjeeling',
    'Puri',
    'Jaipur',
    'Kolkata',
    'Delhi',
    'Mumbai',
    'Bengaluru',
  ];

  final List<String> _vehicleTypes = ['All', 'Bike', 'Scooty', 'Car'];

  String _selectedCity = 'All Cities';
  String _selectedType = 'All';
  DateTime _selectedDate = DateTime.now();
  List<RentVehicleModel> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    final list = await _firestoreService.getRentVehicles(
      city: _selectedCity,
      vehicleType: _selectedType,
    );
    if (mounted) {
      setState(() {
        _vehicles = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rent & Drive (Self-Drive Pan India)'),
        backgroundColor: const Color(0xFF1A3A6E),
      ),
      body: Column(
        children: [
          // Filters Header
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.white,
            child: Column(
              children: [
                // City & Date Row
                Row(
                  children: [
                    // City Dropdown
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCity,
                            isExpanded: true,
                            icon: const Icon(Icons.location_on, color: Color(0xFF1A3A6E), size: 18),
                            items: _cities.map((city) {
                              return DropdownMenuItem(
                                value: city,
                                child: Text(city, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCity = val);
                                _loadVehicles();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Date Picker
                    Expanded(
                      flex: 4,
                      child: InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF93C5FD)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Color(0xFF1D4ED8)),
                              const SizedBox(width: 6),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF1D4ED8)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Vehicle Type Segmented Chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _vehicleTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final type = _vehicleTypes[index];
                      final isSelected = _selectedType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        selectedColor: const Color(0xFF1A3A6E),
                        backgroundColor: const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          setState(() => _selectedType = type);
                          _loadVehicles();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Vehicle List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _vehicles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.car_rental, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('No self-drive vehicles available in $_selectedCity', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _vehicles.length,
                        itemBuilder: (context, index) {
                          final v = _vehicles[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            clipBehavior: Clip.antiAlias,
                            elevation: 2,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RentDriveDetailScreen(vehicle: v),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Photo with Badges
                                  Stack(
                                    children: [
                                      Image.network(
                                        v.photos.first,
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 180,
                                          color: Colors.grey.shade300,
                                          child: const Icon(Icons.car_repair, size: 50, color: Colors.grey),
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        left: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.75),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.location_on, color: Colors.amber, size: 14),
                                              const SizedBox(width: 4),
                                              Text(v.city, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Row(
                                          children: [
                                            if (v.gpsInstalled)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF16A34A),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text('GPS Verified', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                              ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1A3A6E),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text('RC Verified', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Details Row
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                v.modelName,
                                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Text(
                                              '₹${v.dailyRent.toInt()}/day',
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Refundable Deposit: ₹${v.deposit.toInt()} • 0% Commission Direct Pay',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                        ),
                                        const Divider(height: 18),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor: Color(0xFF1A3A6E),
                                                  child: Icon(Icons.person, size: 14, color: Colors.white),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(v.ownerName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                                const SizedBox(width: 2),
                                                Text('⭐ ${v.avgRating} (${v.totalRatings})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
