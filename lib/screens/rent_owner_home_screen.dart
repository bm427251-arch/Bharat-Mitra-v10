import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../models/rent_vehicle_model.dart';
import '../services/firestore_service.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/weekly_earning_chart.dart';
import '../widgets/review_tile.dart';
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

  int _todayBookings = 3;
  double _todayEarnings = 3200.0;
  int _totalVehiclesRented = 18;
  double _ratingAvg = 4.9;

  final List<double> _weeklyEarnings = [2400, 3100, 2800, 3500, 3200, 4800, 4200];

  final List<Map<String, dynamic>> _defaultReviews = [
    {
      'customerName': 'Abhishek Banerjee',
      'rating': 5.0,
      'comment': 'Royal Enfield was in mint condition. Smooth handover and zero deposit hassle.',
      'date': 'Today, 12:30 PM',
    },
    {
      'customerName': 'Sneha Chatterjee',
      'rating': 5.0,
      'comment': 'Hired Swift Dzire for Digha family trip. Clean car and prompt owner response.',
      'date': 'Yesterday',
    },
    {
      'customerName': 'Vikram Rathore',
      'rating': 4.8,
      'comment': 'Best self-drive service in the city with genuine 0% commission direct deal.',
      'date': '3 days ago',
    },
  ];

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

  void _acceptRental(int index) {
    final req = _rentalRequests[index];
    setState(() {
      _rentalRequests.removeAt(index);
      _todayEarnings += req['totalRent'];
      _todayBookings += 1;
      _totalVehiclesRented += 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rental confirmed for ${req['customerName']}!'),
        backgroundColor: const Color(0xFFC2410C),
      ),
    );
  }

  void _rejectRental(int index) {
    setState(() {
      _rentalRequests.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("rentOwnerDashboard".tr()),
        backgroundColor: const Color(0xFFC2410C),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
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
            // 3 Stat Cards: Today Bookings | Today Earning | Total Vehicles Rented
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    title: "todayBookings".tr(),
                    value: '$_todayBookings',
                    icon: Icons.key_rounded,
                    color: const Color(0xFFC2410C),
                    subtitle: 'Confirmed',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DashboardStatCard(
                    title: "todayEarning".tr(),
                    value: '₹${_todayEarnings.toInt()}',
                    icon: Icons.currency_rupee_rounded,
                    color: const Color(0xFF16A34A),
                    subtitle: 'Direct Cash/UPI',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DashboardStatCard(
                    title: "totalVehiclesRented".tr(),
                    value: '$_totalVehiclesRented',
                    icon: Icons.directions_car_filled_rounded,
                    color: const Color(0xFF1A3A6E),
                    subtitle: '⭐ $_ratingAvg',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Weekly Earning Chart (fl_chart 7 bars)
            WeeklyEarningChart(
              dailyEarnings: _weeklyEarnings,
              primaryColor: const Color(0xFFC2410C),
              title: "weeklyEarnings",
            ),

            const SizedBox(height: 20),

            // New Incoming Rental Bookings
            if (_rentalRequests.isNotEmpty) ...[
              const Text(
                'Incoming Rental Bookings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...List.generate(_rentalRequests.length, (index) {
                final req = _rentalRequests[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC2410C).withOpacity(0.25)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            req['customerName'],
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '₹${req['totalRent'].toInt()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFC2410C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Vehicle: ${req['vehicle']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('Duration: ${req['duration']} • Pickup: ${req['pickupDate']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text('Security Deposit: ₹${req['deposit'].toInt()} (Refundable)', style: const TextStyle(fontSize: 12, color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _rejectRental(index),
                              child: const Text('Decline'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC2410C),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _acceptRental(index),
                              child: const Text('Confirm Rental', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 16),

            // Vehicle Wise Earning List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Vehicle Wise Earnings & Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Vehicle'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFC2410C)),
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
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          v.photos.first,
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 58,
                            height: 58,
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.directions_car, color: Color(0xFFC2410C)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.modelName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${v.dailyRent.toInt()}/day • Dep: ₹${v.deposit.toInt()}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFC2410C)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${v.city} • RC: ${v.rcNumber}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFFF0FDF4) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isActive ? 'ACTIVE' : 'PAUSED',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isActive ? const Color(0xFF16A34A) : Colors.grey,
                              ),
                            ),
                          ),
                          Switch(
                            value: isActive,
                            activeColor: const Color(0xFFC2410C),
                            onChanged: (val) {
                              setState(() => _activeMap[v.id] = val);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 20),

            // Reviews Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "customerReviews".tr(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '⭐ $_ratingAvg Overall',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFC2410C)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Fetch reviews from rent_owner_reviews collection or fallback
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rent_owner_reviews')
                  .where('ownerId', isEqualTo: 'owner_current')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ReviewTile(
                        customerName: data['customerName'] ?? 'Renter',
                        rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
                        comment: data['comment'] ?? 'Clean vehicle and smooth trip.',
                        date: data['date'] ?? 'Recently',
                      );
                    }).toList(),
                  );
                }
                return Column(
                  children: _defaultReviews.map((r) {
                    return ReviewTile(
                      customerName: r['customerName'],
                      rating: r['rating'],
                      comment: r['comment'],
                      date: r['date'],
                    );
                  }).toList(),
                );
              },
            ),
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
                label: Text('iAmCustomer'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
                label: Text('iAmProvider'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
