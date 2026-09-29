import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/rent_vehicle_model.dart';
import '../services/firestore_service.dart';
import 'owner_add_vehicle_screen.dart';

class RentOwnerHomeScreen extends StatefulWidget {
  const RentOwnerHomeScreen({super.key});

  @override
  State<RentOwnerHomeScreen> createState() => _RentOwnerHomeScreenState();
}

class _RentOwnerHomeScreenState extends State<RentOwnerHomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<RentVehicleModel> _myVehicles = [];
  bool _isLoading = true;
  final Map<String, bool> _activeMap = {};

  final List<Map<String, dynamic>> _rentalRequests = [
    {
      'id': 'rent_req_1',
      'customerName': 'Abhishek Banerjee',
      'vehicle': 'Royal Enfield Classic 350',
      'duration': '3 Days',
      'totalRent': 2400.0,
      'deposit': 2000.0,
      'pickupDate': 'Tomorrow, 9:00 AM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    final all = await _firestoreService.getRentVehicles();
    if (mounted) {
      setState(() {
        _myVehicles = all;
        for (final v in all) {
          _activeMap[v.id] = true;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rent Vehicle Owner Dashboard'),
        backgroundColor: const Color(0xFFC2410C),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Vehicle',
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OwnerAddVehicleScreen()),
              );
              if (added == true) _loadVehicles();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header stats
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Monthly Rentals', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        const Text('₹28,400', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFC2410C))),
                        Text('${_myVehicles.length} Vehicles Listed', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDBA74)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Owner Direct Pay', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        const Text('0% Cut', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                        const Text('Direct Cash / UPI', style: TextStyle(fontSize: 11, color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Rental Requests
            const Text(
              'Rental Booking Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC2410C)),
            ),
            const SizedBox(height: 10),

            ..._rentalRequests.map((req) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(req['customerName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('₹${req['totalRent'].toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFC2410C))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${req['vehicle']} • ${req['duration']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Pickup: ${req['pickupDate']} • Deposit ₹${req['deposit'].toInt()}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _rentalRequests.remove(req)),
                              child: const Text('Decline', style: TextStyle(color: Colors.red)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Rental confirmed! Party will arrive at garage for 4-photo inspection.'),
                                    backgroundColor: Color(0xFF16A34A),
                                  ),
                                );
                              },
                              child: const Text('Accept Booking', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // My Vehicles List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Garage Fleet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E)),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add_circle, color: Color(0xFFC2410C)),
                  label: const Text('Add Vehicle', style: TextStyle(color: Color(0xFFC2410C), fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    final added = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OwnerAddVehicleScreen()),
                    );
                    if (added == true) _loadVehicles();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ..._myVehicles.map((v) {
                final isActive = _activeMap[v.id] ?? true;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(v.photos.first, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.car_repair)),
                    ),
                    title: Text(v.modelName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('₹${v.dailyRent.toInt()}/day • ${v.rcNumber}\nCity: ${v.city} • Dep: ₹${v.deposit.toInt()}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isActive ? 'LIVE 🟢' : 'OFFLINE ⚪', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.green : Colors.grey)),
                        Switch(
                          value: isActive,
                          activeColor: const Color(0xFF16A34A),
                          onChanged: (val) {
                            setState(() => _activeMap[v.id] = val);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
      bottomNavigationBar: _buildDualModeBottomBar(context),
    );
  }

  Widget _buildDualModeBottomBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.person),
                label: const Text('I am Customer', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFC2410C)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.handyman),
                label: const Text('I am Provider', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC2410C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
