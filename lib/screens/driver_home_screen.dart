import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import 'tracking_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  final String? driverName;
  final String? serviceType;
  const DriverHomeScreen({super.key, this.driverName, this.serviceType});
  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isActive = true;

  void _toggleActive(bool val) {
    setState(() => _isActive = val);
    if (val) {
      LocationService.instance.startLiveLocationUpdates(
        userId: 'driver_current',
        userName: widget.driverName ?? 'Rajesh Das',
        userType: 'driver',
        serviceType: widget.serviceType ?? 'book_ride',
        vehicleNumber: 'WB 02 CZ 9012',
      );
    } else {
      LocationService.instance.stopLiveLocationUpdates('driver_current');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.driverName ?? 'Driver Dashboard'),
        backgroundColor: const Color(0xFF1A3A6E),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text(_isActive ? 'Online' : 'Offline'),
            subtitle: const Text('GPS every 10s'),
            value: _isActive,
            onChanged: _toggleActive,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [const Text('Today Rides'), Text('7', style: Theme.of(context).textTheme.headlineMedium)])))),
              const SizedBox(width: 10),
              Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [const Text('Earning'), Text('Rs 1480', style: Theme.of(context).textTheme.headlineMedium)])))),
              const SizedBox(width: 10),
              Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [const Text('Total'), Text('84', style: Theme.of(context).textTheme.headlineMedium)])))),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Incoming Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              title: const Text('Suman Ghosh'),
              subtitle: const Text('Barasat Court -> Howrah - 6.4km'),
              trailing: Text('Rs 180', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingScreen(rideId: 'req_1', role: 'driver', fare: 180, driverName: 'Suman Ghosh', partnerName: 'Suman Ghosh', partnerId: 'req_1', partnerPhone: '+91 98301 23456', serviceType: 'book_ride')));
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Priya Sen'),
              subtitle: const Text('Chapadali -> Airport - 14km'),
              trailing: Text('Rs 320', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingScreen(rideId: 'req_2', role: 'driver', fare: 320, driverName: 'Priya Sen', partnerName: 'Priya Sen', partnerId: 'req_2', partnerPhone: '+91 98302 98765', serviceType: 'book_ride')));
              },
            ),
          ),
        ],
      ),
    );
  }
}
