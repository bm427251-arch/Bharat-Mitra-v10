import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/weekly_earning_chart.dart';
import '../widgets/review_tile.dart';

class SevakHomeScreen extends StatefulWidget {
  const SevakHomeScreen({super.key});

  @override
  State<SevakHomeScreen> createState() => _SevakHomeScreenState();
}

class _SevakHomeScreenState extends State<SevakHomeScreen> {
  bool _isActive = true;
  bool _hasUploadedWorkPhoto = false;

  int _todayJobs = 4;
  double _todayEarnings = 1250.0;
  int _totalJobs = 52;
  double _ratingAvg = 4.9;

  final List<double> _weeklyEarnings = [700, 950, 800, 1100, 1250, 1400, 1050];

  final List<Map<String, dynamic>> _completedJobsHistory = [
    {
      'customerName': 'Dr. Arindam Das',
      'service': 'AC Master Servicing & Filter Wash',
      'date': 'Today, 3:30 PM',
      'amount': 499.0,
      'status': 'Completed',
    },
    {
      'customerName': 'Meenakshi Iyer',
      'service': 'Switchboard & MCB Wiring Replacement',
      'date': 'Today, 1:15 PM',
      'amount': 299.0,
      'status': 'Completed',
    },
    {
      'customerName': 'Debjit Roy',
      'service': 'Water Purifier RO Filter Replacement',
      'date': 'Today, 10:45 AM',
      'amount': 450.0,
      'status': 'Completed',
    },
    {
      'customerName': 'Sunita Sen',
      'service': 'Kitchen Sink Leakage Fix',
      'date': 'Yesterday, 5:00 PM',
      'amount': 249.0,
      'status': 'Completed',
    },
  ];

  final List<Map<String, dynamic>> _defaultReviews = [
    {
      'customerName': 'Dr. Arindam Das',
      'rating': 5.0,
      'comment': 'Expert technician! Cleaned the AC thoroughly without any mess. 10/10.',
      'date': 'Today, 3:45 PM',
    },
    {
      'customerName': 'Meenakshi Iyer',
      'rating': 5.0,
      'comment': 'Prompt arrival within 20 mins. Fixed the short-circuit issue quickly.',
      'date': 'Today, 1:30 PM',
    },
    {
      'customerName': 'Kunal Bose',
      'rating': 4.8,
      'comment': 'Very polite and knowledgeable service partner. Paid direct UPI.',
      'date': '2 days ago',
    },
  ];

  final List<Map<String, dynamic>> _serviceRequests = [
    {
      'id': 'svc_1',
      'customerName': 'Rohan Sen',
      'service': 'Plumber - Kitchen sink water leakage',
      'address': 'Salt Lake Sector 2, Kolkata',
      'fee': 249.0,
      'time': 'Today, 5:30 PM',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (_isActive) {
      LocationService.instance.startLiveLocationUpdates(
        userId: 'sevak_current',
        userName: 'Tapan Roy (Electrician)',
        userType: 'sevak',
        serviceType: 'home_service',
      );
    }
  }

  void _toggleActive(bool val) async {
    setState(() => _isActive = val);
    if (val) {
      await LocationService.instance.startLiveLocationUpdates(
        userId: 'sevak_current',
        userName: 'Tapan Roy (Electrician)',
        userType: 'sevak',
        serviceType: 'home_service',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are now Online! Customers can request home visits.'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }
    } else {
      await LocationService.instance.stopLiveLocationUpdates('sevak_current');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are Offline. Service requests paused.'), backgroundColor: Colors.grey),
        );
      }
    }
  }

  void _acceptService(int index) {
    final svc = _serviceRequests[index];
    setState(() {
      _serviceRequests.removeAt(index);
      _todayEarnings += svc['fee'];
      _todayJobs += 1;
      _totalJobs += 1;
      _completedJobsHistory.insert(0, {
        'customerName': svc['customerName'],
        'service': svc['service'],
        'date': 'Just now',
        'amount': svc['fee'],
        'status': 'Accepted',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Service request accepted for ${svc['customerName']}!'),
        backgroundColor: Colors.orange.shade800,
      ),
    );
  }

  void _rejectService(int index) {
    setState(() {
      _serviceRequests.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("serviceProviderDashboard".tr()),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Switch
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isActive ? const Color(0xFFFFF7ED) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _isActive ? Colors.orange.shade300 : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isActive ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                    color: _isActive ? Colors.orange.shade800 : Colors.grey,
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
                            color: _isActive ? Colors.orange.shade900 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Nearby customers can book your verified skills',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 1.15,
                    child: Switch(
                      value: _isActive,
                      activeColor: Colors.orange.shade800,
                      onChanged: _toggleActive,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3 Stat Cards: Today Jobs | Today Earning | Total Jobs
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    title: "todayJobs".tr(),
                    value: '$_todayJobs',
                    icon: Icons.assignment_turned_in_rounded,
                    color: Colors.orange.shade800,
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
                    subtitle: '0% Platform Cut',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DashboardStatCard(
                    title: "totalJobs".tr(),
                    value: '$_totalJobs',
                    icon: Icons.handyman_rounded,
                    color: const Color(0xFF1A3A6E),
                    subtitle: '⭐ $_ratingAvg',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Weekly Earning / Jobs Chart
            WeeklyEarningChart(
              dailyEarnings: _weeklyEarnings,
              primaryColor: Colors.orange.shade800,
              title: "weeklyEarnings",
            ),

            const SizedBox(height: 20),

            // Incoming Service Requests
            if (_serviceRequests.isNotEmpty) ...[
              const Text(
                'Incoming Service Bookings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...List.generate(_serviceRequests.length, (index) {
                final svc = _serviceRequests[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200),
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
                            svc['customerName'],
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '₹${svc['fee'].toInt()}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        svc['service'],
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        svc['address'],
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
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
                              onPressed: () => _rejectService(index),
                              child: const Text('Decline'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade800,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _acceptService(index),
                              child: const Text('Accept Visit', style: TextStyle(fontWeight: FontWeight.bold)),
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

            // Completed Jobs History List
            const Text(
              'Completed Jobs History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _completedJobsHistory.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final job = _completedJobsHistory[i];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Color(0xFF16A34A), size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job['customerName'],
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              job['service'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            Text(
                              job['date'],
                              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '+₹${(job['amount'] as num).toInt()}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Customer Reviews Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "customerReviews".tr(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '⭐ $_ratingAvg Overall',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Fetch reviews from service_provider_reviews collection or fallback
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('service_provider_reviews')
                  .where('providerId', isEqualTo: 'sevak_current')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ReviewTile(
                        customerName: data['customerName'] ?? 'Customer',
                        rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
                        comment: data['comment'] ?? 'Punctual and reliable service.',
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

            const SizedBox(height: 20),

            // Work Verification Photo
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
                  const Text('Completed Work Proof', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Upload customer repair photo to verify completion and get direct cash payment.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: Icon(_hasUploadedWorkPhoto ? Icons.check_circle : Icons.camera_alt, color: _hasUploadedWorkPhoto ? Colors.green : Colors.orange.shade800),
                    label: Text(_hasUploadedWorkPhoto ? 'Photo Uploaded Successfully' : 'Take Repair Photo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _hasUploadedWorkPhoto ? Colors.green : Colors.orange.shade800,
                      side: BorderSide(color: _hasUploadedWorkPhoto ? Colors.green : Colors.orange.shade800),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    onPressed: () {
                      setState(() => _hasUploadedWorkPhoto = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Work proof photo uploaded! Direct payment unlocked.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
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
                  side: BorderSide(color: Colors.orange.shade800),
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
                  backgroundColor: Colors.orange.shade800,
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
