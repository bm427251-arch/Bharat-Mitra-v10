import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firestore_service.dart';
import '../services/rating_service.dart';
import '../services/location_service.dart';
import '../models/driver_model.dart';
import '../models/sebak_model.dart';
import '../models/complaint_model.dart';
import '../config/fare_config.dart';
import 'admin_earnings_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  final String adminEmail;

  const AdminLoginScreen({
    super.key,
    this.adminEmail = 'bm427251@gmail.com',
  });

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final RatingService _ratingService = RatingService();
  bool _isLoading = true;
  List<DriverModel> _drivers = [];
  List<SebakModel> _sebaks = [];
  List<Map<String, dynamic>> _ratings = [];
  List<Map<String, dynamic>> _activeUsers = [];
  List<ComplaintModel> _complaints = [];

  // Editable fare text controllers
  final _bikeBaseCtrl = TextEditingController(text: FareConfig.bikeBase.toInt().toString());
  final _bikeKmCtrl = TextEditingController(text: FareConfig.bikePerKm.toInt().toString());
  final _totoBaseCtrl = TextEditingController(text: FareConfig.totoBase.toInt().toString());
  final _totoKmCtrl = TextEditingController(text: FareConfig.totoPerKm.toInt().toString());
  final _autoBaseCtrl = TextEditingController(text: FareConfig.autoBase.toInt().toString());
  final _autoKmCtrl = TextEditingController(text: FareConfig.autoPerKm.toInt().toString());
  final _sedanBaseCtrl = TextEditingController(text: FareConfig.sedanBase.toInt().toString());
  final _sedanKmCtrl = TextEditingController(text: FareConfig.sedanPerKm.toInt().toString());
  final _hireCtrl = TextEditingController(text: FareConfig.hire.toInt().toString());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _bikeBaseCtrl.dispose();
    _bikeKmCtrl.dispose();
    _totoBaseCtrl.dispose();
    _totoKmCtrl.dispose();
    _autoBaseCtrl.dispose();
    _autoKmCtrl.dispose();
    _sedanBaseCtrl.dispose();
    _sedanKmCtrl.dispose();
    _hireCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final drivers = await _firestoreService.getAllDriversForAdmin();
      final sebaks = await _firestoreService.getSebaks();
      final ratings = await _ratingService.getAllRatingsForAdmin();
      final activeUsers = LocationService.instance.getAllActiveUsers();
      final complaints = await _firestoreService.getComplaintsForAdmin();
      if (mounted) {
        setState(() {
          _drivers = drivers;
          _sebaks = sebaks;
          _ratings = ratings;
          _activeUsers = activeUsers;
          _complaints = complaints;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _callNumber(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _saveFares() async {
    FareConfig.bikeBase = double.tryParse(_bikeBaseCtrl.text) ?? 30.0;
    FareConfig.bikePerKm = double.tryParse(_bikeKmCtrl.text) ?? 10.0;
    FareConfig.totoBase = double.tryParse(_totoBaseCtrl.text) ?? 50.0;
    FareConfig.totoPerKm = double.tryParse(_totoKmCtrl.text) ?? 15.0;
    FareConfig.autoBase = double.tryParse(_autoBaseCtrl.text) ?? 40.0;
    FareConfig.autoPerKm = double.tryParse(_autoKmCtrl.text) ?? 18.0;
    FareConfig.sedanBase = double.tryParse(_sedanBaseCtrl.text) ?? 80.0;
    FareConfig.sedanPerKm = double.tryParse(_sedanKmCtrl.text) ?? 14.0;
    FareConfig.hire = double.tryParse(_hireCtrl.text) ?? 700.0;

    await _firestoreService.saveFareRatesToCloud({
      'bikeBase': FareConfig.bikeBase,
      'bikePerKm': FareConfig.bikePerKm,
      'totoBase': FareConfig.totoBase,
      'totoPerKm': FareConfig.totoPerKm,
      'autoBase': FareConfig.autoBase,
      'autoPerKm': FareConfig.autoPerKm,
      'sedanBase': FareConfig.sedanBase,
      'sedanPerKm': FareConfig.sedanPerKm,
      'hire': FareConfig.hire,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fare rates updated successfully across Pan India!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lowRatingsCount = _ratings.where((r) => (r['driverRating'] as num) < 3).length;
    final activeDrivers = _activeUsers.where((u) => u['userType'] == 'driver').length;
    final activeSebaks = _activeUsers.where((u) => u['userType'] == 'sevak').length;
    final pendingComplaints = _complaints.where((c) => c.status == 'pending_admin').length;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A3A6E),
          title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.amber,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              const Tab(icon: Icon(Icons.people_alt_outlined), text: 'Partners'),
              const Tab(icon: Icon(Icons.star_half_rounded), text: 'Ratings'),
              Tab(
                icon: Badge(
                  isLabelVisible: pendingComplaints > 0,
                  label: Text('$pendingComplaints'),
                  child: const Icon(Icons.report_problem_rounded),
                ),
                text: 'Complaints',
              ),
              const Tab(icon: Icon(Icons.location_on_rounded), text: 'Live Active'),
              const Tab(icon: Icon(Icons.price_change_rounded), text: 'Fare Rates'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // TAB 1: Drivers & Sebaks
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3A6E).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF1A3A6E).withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Color(0xFF1A3A6E),
                                child: Icon(Icons.admin_panel_settings, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Admin Access Granted', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(widget.adminEmail, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminEarningsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.analytics_rounded),
                            label: const Text(
                              'Earnings Report',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Registered Drivers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ..._drivers.map((driver) => Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF1A3A6E),
                                  child: Text(driver.name.isNotEmpty ? driver.name[0] : 'D', style: const TextStyle(color: Colors.white)),
                                ),
                                title: Text(driver.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${driver.vehicleType.toUpperCase()} • ${driver.vehicleNo}\n${driver.phone} • ⭐ ${driver.rating}'),
                                trailing: Switch(
                                  value: driver.isActive,
                                  activeColor: const Color(0xFF1A3A6E),
                                  onChanged: (val) async {
                                    await _firestoreService.toggleDriverActive(driver.id, val);
                                    _loadData();
                                  },
                                ),
                              ),
                            )),
                        const SizedBox(height: 24),
                        const Text('Active Sebaks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ..._sebaks.map((sebak) => Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal,
                                  child: Text(sebak.name.isNotEmpty ? sebak.name[0] : 'S', style: const TextStyle(color: Colors.white)),
                                ),
                                title: Text(sebak.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${sebak.skill} • ₹${sebak.pricePerHour}/hr\n${sebak.phone} • ⭐ ${sebak.rating}'),
                                trailing: Chip(
                                  label: Text(sebak.isAvailable ? 'Available' : 'Busy', style: const TextStyle(fontSize: 12)),
                                  backgroundColor: sebak.isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),

                  // TAB 2: Ratings & Reviews
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total Ratings', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text('${_ratings.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E))),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: lowRatingsCount > 0 ? const Color(0xFFFFEBEE) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: lowRatingsCount > 0 ? Colors.red.shade300 : Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Low Ratings (<3★)', style: TextStyle(fontSize: 12, color: Colors.red)),
                                    const SizedBox(height: 4),
                                    Text('$lowRatingsCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          'Customer Feedback & Ratings',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E)),
                        ),
                        const SizedBox(height: 12),

                        ..._ratings.map((r) {
                          final int stars = (r['driverRating'] as num?)?.toInt() ?? 5;
                          final bool isLowRating = stars < 3;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isLowRating ? const Color(0xFFFFF1F2) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isLowRating ? Colors.red.shade400 : Colors.grey.shade200,
                                width: isLowRating ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      r['driverName'] ?? 'Partner',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    if (isLowRating)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'LOW RATING ⚠️',
                                          style: TextStyle(
                                            color: Colors.red.shade900,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    ...List.generate(
                                      5,
                                      (i) => Icon(
                                        i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                                        color: isLowRating ? Colors.red : Colors.amber,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'By ${r['userName'] ?? "Customer"} • ${r['date'] ?? ""}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  r['comment']?.isNotEmpty == true ? r['comment'] : '(No review written)',
                                  style: TextStyle(fontSize: 13, color: isLowRating ? Colors.red.shade900 : Colors.black87),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // TAB 3: Complaints (Manual & Auto with Warning/Block/Resolved/Call)
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Complaints & Dispute Management',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E)),
                        ),
                        const SizedBox(height: 4),
                        const Text('Review customer complaints and take action against non-compliant partners.'),
                        const SizedBox(height: 16),

                        if (_complaints.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('No complaints registered.'),
                            ),
                          )
                        else
                          ..._complaints.map((c) {
                            final isPending = c.status == 'pending_admin';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            c.complaintType.toUpperCase(),
                                            style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isPending ? Colors.amber.shade100 : Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            c.status.toUpperCase(),
                                            style: TextStyle(
                                              color: isPending ? Colors.amber.shade900 : Colors.green.shade900,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Against: ${c.providerName}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Text(
                                      'Filed by: ${c.customerName} • Service: ${c.serviceType}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      c.description,
                                      style: const TextStyle(fontSize: 13, height: 1.3),
                                    ),
                                    const Divider(height: 20),

                                    // Action buttons for Admin
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.call, size: 16),
                                          label: const Text('Call Customer'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF1A3A6E),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                          onPressed: () => _callNumber('+91 98301 23456'),
                                        ),
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.warning, size: 16, color: Colors.orange),
                                          label: const Text('Warning', style: TextStyle(color: Colors.orange)),
                                          onPressed: () async {
                                            await _firestoreService.updateComplaintStatus(c.id, 'warning');
                                            _loadData();
                                          },
                                        ),
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.block, size: 16, color: Colors.red),
                                          label: const Text('Block User', style: TextStyle(color: Colors.red)),
                                          onPressed: () async {
                                            await _firestoreService.updateComplaintStatus(c.id, 'blocked');
                                            _loadData();
                                          },
                                        ),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.check, size: 16),
                                          label: const Text('Mark Resolved'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF16A34A),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                          onPressed: () async {
                                            await _firestoreService.updateComplaintStatus(c.id, 'resolved');
                                            _loadData();
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),

                  // TAB 4: Live Active Users
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFF93C5FD)),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.directions_car_filled, color: Color(0xFF1D4ED8), size: 22),
                                    const SizedBox(height: 4),
                                    const Text('Active Drivers', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                                    Text('$activeDrivers', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFF86EFAC)),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.handyman_rounded, color: Color(0xFF15803D), size: 22),
                                    const SizedBox(height: 4),
                                    const Text('Active Sebaks', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                                    Text('$activeSebaks', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF14532D))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Radar Canvas
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              children: [
                                Container(color: const Color(0xFFF1F5F9)),
                                CustomPaint(
                                  size: const Size(double.infinity, 220),
                                  painter: _AdminLiveMapGridPainter(users: _activeUsers),
                                ),
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.radar, color: Colors.green, size: 14),
                                        SizedBox(width: 4),
                                        Text('Pan-India Live Radar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),
                        ..._activeUsers.map((u) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Color(0xFF1A3A6E),
                                  child: Icon(Icons.location_on, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(u['userName'] ?? 'Active Partner', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                                      Text('${u['vehicleType']} • ${u['vehicleNumber']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                      Text('GPS: ${(u['lat'] as double).toStringAsFixed(4)}, ${(u['lng'] as double).toStringAsFixed(4)} • Speed: ${u['speed']} km/h', style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                                  child: const Text('ONLINE 🟢', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // TAB 5: Fare Rates (Editable Base & Per-Km)
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pan-India Editable Fare Config',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E)),
                        ),
                        const SizedBox(height: 4),
                        const Text('Update base fare and per-km rate in real time without republishing app.'),
                        const SizedBox(height: 16),

                        // Bike
                        _buildFareInputRow('Bike Fare', _bikeBaseCtrl, _bikeKmCtrl),
                        const SizedBox(height: 12),
                        // Toto
                        _buildFareInputRow('Toto Fare', _totoBaseCtrl, _totoKmCtrl),
                        const SizedBox(height: 12),
                        // Auto
                        _buildFareInputRow('Auto Fare', _autoBaseCtrl, _autoKmCtrl),
                        const SizedBox(height: 12),
                        // Sedan
                        _buildFareInputRow('Sedan Fare', _sedanBaseCtrl, _sedanKmCtrl),
                        const SizedBox(height: 12),

                        // Personal Driver Hire
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text('Hire Driver (8 Hrs)', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: _hireCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: '₹ Fee', border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Save & Sync Rates Pan India', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A3A6E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _saveFares,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFareInputRow(String title, TextEditingController baseCtrl, TextEditingController kmCtrl) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: baseCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Base Fare (₹)', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: kmCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Per Km Rate (₹)', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminLiveMapGridPainter extends CustomPainter {
  final List<Map<String, dynamic>> users;

  _AdminLiveMapGridPainter({required this.users});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.5;

    for (double i = 0; i < size.width; i += 35) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    for (double j = 0; j < size.height; j += 35) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), linePaint);
    }

    int idx = 0;
    for (final u in users) {
      final double x = (size.width * 0.2 + (idx * 65)) % size.width;
      final double y = (size.height * 0.3 + (idx * 45)) % size.height;

      Color color = Colors.blue;
      if (u['userType'] == 'sevak') color = Colors.green;
      if (u['userType'] == 'rent_owner') color = Colors.orange;

      final pulse = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 18, pulse);

      final dot = Paint()..color = color;
      canvas.drawCircle(Offset(x, y), 8, dot);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);

      idx++;
    }
  }

  @override
  bool shouldRepaint(covariant _AdminLiveMapGridPainter oldDelegate) => true;
}
