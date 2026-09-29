import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../services/rating_service.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isActive = true;
  double _todayEarnings = 1480.0;
  int _todayRides = 7;

  // New incoming ride requests
  final List<Map<String, dynamic>> _newRequests = [
    {
      'id': 'req_1',
      'customerName': 'Suman Ghosh',
      'pickup': 'Salt Lake Karunamoyee',
      'drop': 'Howrah Station',
      'fare': 180.0,
      'vehicle': 'Sedan',
      'distance': '6.4 km',
    },
    {
      'id': 'req_2',
      'customerName': 'Priya Sen',
      'pickup': 'Park Street Metro',
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
            content: Text('You are Live - Party can see you'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }
    } else {
      await LocationService.instance.stopLiveLocationUpdates('driver_current');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are Offline'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    }
  }

  void _acceptRide(Map<String, dynamic> req) {
    setState(() {
      _newRequests.removeWhere((r) => r['id'] == req['id']);
      _todayEarnings += req['fare'];
      _todayRides += 1;
    });

    RatingService().addBooking({
      'bookingId': 'bk_${req['id']}',
      'serviceType': 'book_ride',
      'customerId': 'user_current',
      'customerName': req['customerName'],
      'driverId': 'driver_current',
      'driverName': 'Rajesh Das',
      'driverPhone': '+91 98301 23456',
      'vehicleType': req['vehicle'],
      'vehicleNo': 'WB 02 CZ 9012',
      'pickupAddress': req['pickup'],
      'dropAddress': req['drop'],
      'fare': req['fare'],
      'status': 'accepted',
      'paymentStatus': 'pending',
      'driverConfirmed': false,
      'ratingGiven': false,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ride accepted! Pickup: ${req['pickup']}'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Driver Partner Dashboard'),
        backgroundColor: const Color(0xFF1A3A6E),
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
                          _isActive ? 'You are Live - Party can see you' : 'You are Offline',
                          style: TextStyle(
                            fontSize: 16,
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
                    scale: 1.2,
                    child: Switch(
                      value: _isActive,
                      activeColor: const Color(0xFF16A34A),
                      onChanged: _toggleActive,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Today Earnings & Rides
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
                        const Text('Today Earning (0% Cut)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text(
                          '₹${_todayEarnings.toInt()}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                        const Text('Total Rides Completed', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text(
                          '$_todayRides',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // New Ride Requests Stream
            const Text(
              'New Ride Requests (Live)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E)),
            ),
            const SizedBox(height: 12),

            if (_newRequests.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.radar, color: Colors.grey, size: 36),
                    SizedBox(height: 8),
                    Text('Waiting for nearby ride requests...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              ..._newRequests.map((req) {
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
                            Text('₹${req['fare'].toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF16A34A))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.radio_button_checked, size: 14, color: Colors.green),
                            const SizedBox(width: 6),
                            Expanded(child: Text(req['pickup'], style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.red),
                            const SizedBox(width: 6),
                            Expanded(child: Text(req['drop'], style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() => _newRequests.remove(req));
                                },
                                child: const Text('Reject', style: TextStyle(color: Colors.red)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => _acceptRide(req),
                                child: const Text('Accept Ride', style: TextStyle(fontWeight: FontWeight.bold)),
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

            // Active Rides / Confirmation
            const Text(
              'Payment Confirmation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E)),
            ),
            const SizedBox(height: 10),

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
                      label: const Text('Payment Received - Received', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment confirmed! Rating request sent to Customer.'),
                            backgroundColor: Color(0xFF16A34A),
                          ),
                        );
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
                label: const Text('I am Customer', style: TextStyle(fontWeight: FontWeight.bold)),
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
                label: const Text('I am Provider', style: TextStyle(fontWeight: FontWeight.bold)),
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
