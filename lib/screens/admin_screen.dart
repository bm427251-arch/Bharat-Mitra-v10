import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/driver_model.dart';
import '../models/sebak_model.dart';

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
  bool _isLoading = true;
  List<DriverModel> _drivers = [];
  List<SebakModel> _sebaks = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final drivers = await _firestoreService.getAllDriversForAdmin();
      final sebaks = await _firestoreService.getSebaks();
      if (mounted) {
        setState(() {
          _drivers = drivers;
          _sebaks = sebaks;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A6E),
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                  const SizedBox(height: 24),
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
                          subtitle: Text('${driver.vehicleType.toUpperCase()} • ${driver.vehicleNo}\n${driver.phone}'),
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
                          subtitle: Text('${sebak.skill} • ₹${sebak.pricePerHour}/hr\n${sebak.phone}'),
                          trailing: Chip(
                            label: Text(sebak.isAvailable ? 'Available' : 'Busy', style: const TextStyle(fontSize: 12)),
                            backgroundColor: sebak.isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                          ),
                        ),
                      )),
                ],
              ),
            ),
    );
  }
}
