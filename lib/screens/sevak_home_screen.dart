import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';

class SevakHomeScreen extends StatefulWidget {
  const SevakHomeScreen({super.key});

  @override
  State<SevakHomeScreen> createState() => _SevakHomeScreenState();
}

class _SevakHomeScreenState extends State<SevakHomeScreen> {
  bool _isActive = true;
  bool _hasUploadedWorkPhoto = false;

  final List<Map<String, dynamic>> _serviceRequests = [
    {
      'id': 'svc_1',
      'customerName': 'Meenakshi Iyer',
      'service': 'Electrician - Switchboard repair & wiring',
      'address': 'Flat 4B, South City Residency, Kolkata',
      'fee': 299.0,
      'time': 'Urgent (Within 30 mins)',
    },
    {
      'id': 'svc_2',
      'customerName': 'Rohan Sen',
      'service': 'Plumber - Kitchen sink water leakage',
      'address': 'Salt Lake Sector 2, Kolkata',
      'fee': 249.0,
      'time': 'Today, 2:00 PM',
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
            content: Text('You are Live - Party can see you'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }
    } else {
      await LocationService.instance.stopLiveLocationUpdates('sevak_current');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are Offline'), backgroundColor: Colors.grey),
        );
      }
    }
  }

  void _simulateUploadWorkPhoto() {
    setState(() => _hasUploadedWorkPhoto = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Work photo uploaded successfully! (1 photo compulsory verified)'),
        backgroundColor: Color(0xFF16A34A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sevak Partner Dashboard'),
        backgroundColor: const Color(0xFF0F766E),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big Active Switch
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
                    _isActive ? Icons.handyman : Icons.handyman_outlined,
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
                          'Customers see your live arrival location',
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

            const SizedBox(height: 20),

            // Service Requests
            const Text(
              'New Service Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
            ),
            const SizedBox(height: 12),

            ..._serviceRequests.map((svc) {
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
                          Text(svc['customerName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('₹${svc['fee'].toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F766E))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(svc['service'], style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(svc['address'], style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() => _serviceRequests.remove(svc));
                              },
                              child: const Text('Decline', style: TextStyle(color: Colors.red)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Service request accepted! On the way to customer location.'),
                                    backgroundColor: Color(0xFF0F766E),
                                  ),
                                );
                              },
                              child: const Text('Accept & Go', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Work Completion & Compulsory 1 Photo
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
                  const Text('Complete Job & Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text(
                    'Upload 1 work photo (compulsory) to verify quality service before payment receipt.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    icon: Icon(_hasUploadedWorkPhoto ? Icons.check_circle : Icons.camera_alt, color: _hasUploadedWorkPhoto ? Colors.green : const Color(0xFF0F766E)),
                    label: Text(_hasUploadedWorkPhoto ? 'Work Photo Uploaded (Verified ✅)' : 'Upload 1 Work Photo (Compulsory)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F766E),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _simulateUploadWorkPhoto,
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text('Payment Received - Received', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        if (!_hasUploadedWorkPhoto) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please upload 1 work photo first before confirming payment.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment confirmed! Rating request sent to customer.'),
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
                  side: const BorderSide(color: Color(0xFF0F766E)),
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
                  backgroundColor: const Color(0xFF0F766E),
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
