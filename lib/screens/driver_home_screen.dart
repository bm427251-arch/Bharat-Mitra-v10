import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../services/rating_service.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/weekly_earning_chart.dart';
import '../widgets/review_tile.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isActive = true;
  double _todayEarnings = 1480.0;
  int _todayRides = 7;
  int _totalRides = 84;
  double _ratingAvg = 4.9;

  final List<double> _weeklyEarnings = [850, 1100, 940, 1250, 1480, 1600, 1350];

  final List<Map<String, dynamic>> _defaultReviews = [
    {
      'customerName': 'Suman Ghosh',
      'rating': 5.0,
      'comment': 'Very polite driver, smooth ride to Howrah Station. Paid direct UPI.',
      'date': 'Today, 2:15 PM',
    },
    {
      'customerName': 'Priya Sen',
      'rating': 5.0,
      'comment': 'Prompt arrival at Barasat Court. Clean car and AC was great.',
      'date': 'Today, 11:30 AM',
    },
    {
      'customerName': 'Anirban Das',
      'rating': 4.8,
      'comment': 'Safe driving through city traffic. Highly recommended!',
      'date': 'Yesterday',
    },
  ];

  // New incoming ride requests
  final List<Map<String, dynamic>> _newRequests = [
    {
      'id': 'req_1',
      'customerName': 'Suman Ghosh',
      'pickup': 'Barasat Court, NH12',
      'drop': 'Howrah Station',
      'fare': 180.0,
      'vehicle': 'Sedan',
      'distance': '6.4 km',
    },
    {
      'id': 'req_2',
      'customerName': 'Priya Sen',
      'pickup': 'Chapadali More, Barasat',
      'drop': 'Kolkata Airport',
      'fare': 320.0,
      'vehicle': 'Sedan',
      'distance': '14.2 km',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startLocationIfActive();
    _fetchDriverStats();
  }

  void _fetchDriverStats() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('drivers').doc('driver_current').get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _todayEarnings = (data['todayEarning'] as num?)?.toDouble() ?? _todayEarnings;
          _todayRides = (data['todayRides'] as num?)?.toInt() ?? _todayRides;
          _totalRides = (data['totalRides'] as num?)?.toInt() ?? _totalRides;
          _ratingAvg = (data['ratingAvg'] as num?)?.toDouble() ?? _ratingAvg;
        });
      }
    } catch (_) {
      // Fallback to default realistic driver stats
    }
  }

  void _startLocationIfActive() {
    if (_isActive) {
      LocationService.instance.startLiveLocationUpdates(
        userId: 'driver_current',
        userName: 'Rajesh Das (Driver)',
        userType: 'driver',
        serviceType: 'book_ride',
        vehicleNumber: 'WB 02 CZ 9012',
      );
    }
  }

  void _toggleActive(bool val) async {
    setState(() => _isActive = val);
    if (val) {
      await LocationService.instance.startLiveLocationUpdates(
        userId: 'driver_current',
        userName: 'Rajesh Das (Driver)',
        userType: 'driver',
        serviceType: 'book_ride',
        vehicleNumber: 'WB 02 CZ 9012',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are now Online! Searching nearby ride bookings...'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }
    } else {
      LocationService.instance.stopLiveLocationUpdates('driver_current');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are now Offline. Location sharing paused.'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    }
  }

  void _acceptRide(int index) {
    final req = _newRequests[index];
    setState(() {
      _newRequests.removeAt(index);
      _todayEarnings += req['fare'];
      _todayRides += 1;
      _totalRides += 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ride Accepted for ${req['customerName']}! Start driving to pickup point.'),
        backgroundColor: const Color(0xFF1A3A6E),
      ),
    );
  }

  void _rejectRide(int index) {
    setState(() {
      _newRequests.removeAt(index);
    });
  }

  void _confirmPaymentReceived(Map<String, dynamic> req) {
    RatingService().confirmPaymentReceived('bk_${req['id']}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment ₹${req['fare'].toInt()} confirmed! Rating popup opened for ${req['customerName']}.'),
        backgroundColor: const Color(0xFF16A34A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("driverDashboard".tr()),
        backgroundColor: const Color(0xFF1A3A6E),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big Active ON/OFF Switch
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isActive ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _isActive ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isActive ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                    color: _isActive ? const Color(0xFF16A34A) : Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isActive ? 'activeStatus'.tr() : 'offlineStatus'.tr(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _isActive ? const Color(0xFF15803D) : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Background GPS updates location every 10s',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 1.15,
                    child: Switch(
                      value: _isActive,
                      activeColor: const Color(0xFF16A34A),
                      onChanged: _toggleActive,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3 Stat Cards: Today Rides | Today Earning | Total Rides
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    title: "todayRides".tr(),
                    value: '$_todayRides',
                    icon: Icons.directions_car_rounded,
                    color: const Color(0xFF1A3A6E),
                    subtitle: 'Completed',
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
                    title: "totalRides".tr(),
                    value: '$_totalRides',
                    icon: Icons.military_tech_rounded,
                    color: const Color(0xFFD97706),
                    subtitle: '⭐ $_ratingAvg',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Weekly Earnings Bar Chart (fl_chart 7 bars)
            WeeklyEarningChart(
              dailyEarnings: _weeklyEarnings,
              primaryColor: const Color(0xFF1A3A6E),
              title: "weeklyEarnings",
            ),

            const SizedBox(height: 20),

            // Ride Requests Section
            if (_newRequests.isNotEmpty) ...[
              const Text(
                'Incoming Ride Requests',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...List.generate(_newRequests.length, (index) {
                final req = _newRequests[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1A3A6E).withValues(alpha: 0.2)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF1A3A6E),
                                child: Text(
                                  req['customerName'][0],
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                req['customerName'],
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '₹${req['fare'].toInt()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.circle, color: Colors.green, size: 10),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              req['pickup'],
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 12),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              req['drop'],
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                foregroundColor: Colors.red,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _rejectRide(index),
                              child: const Text('Decline'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _acceptRide(index),
                              child: const Text('Accept Ride', style: TextStyle(fontWeight: FontWeight.bold)),
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

            // Customer Reviews Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "customerReviews".tr(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '⭐ $_ratingAvg Avg',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Fetch reviews from Firestore driver_reviews or fallback
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('driver_reviews')
                  .where('driverId', isEqualTo: 'driver_current')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ReviewTile(
                        customerName: data['customerName'] ?? 'Customer',
                        rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
                        comment: data['comment'] ?? 'Great ride service',
                        date: data['date'] ?? 'Recently',
                      );
                    }).toList(),
                  );
                }
                // Fallback default verified reviews
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

            const SizedBox(height: 20),

            // Direct Payment Confirmation Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Direct Cash / UPI Payment to You', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Click button after passenger pays to trigger star rating request for customer.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: const Text('Payment Received', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _confirmPaymentReceived({
                          'id': 'manual_1',
                          'customerName': 'Current Passenger',
                          'fare': 150.0,
                        });
                      },
                    ),
                  ),
                ],
              ),
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
                  side: const BorderSide(color: Color(0xFF1A3A6E)),
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
                  backgroundColor: const Color(0xFF1A3A6E),
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
