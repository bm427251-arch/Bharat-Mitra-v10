import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/platform_map.dart';
import '../theme/app_theme.dart';
import 'select_drop_location_screen.dart';
import 'home_ride_screen.dart';
import 'rent_drive_screen.dart';
import 'hire_driver_screen.dart';
import 'sebak_list_screen.dart';
import 'become_driver_screen.dart';
import 'driver_home_screen.dart';
import '../services/firestore_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});
  @override State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;
  final LatLng _currentLatLng = const LatLng(22.7244, 88.4781);
  String _selectedDropLocation = 'Select Drop Location';
  bool _isDriverVerified = false; // Guard Flag
  String _driverName = 'Driver';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _slideAnimation = Tween<Offset>(begin: const Offset(-1.2, 0), end: const Offset(1.2, 0)).animate(CurvedAnimation(parent: _animController, curve: Curves.linear));
    _checkDriverProfile(); // Check if Profile Created
  }

  Future<void> _checkDriverProfile() async {
    try {
      final driver = await FirestoreService.instance.getCurrentDriver();
      if(driver != null && driver['status'] == 'verified'){
        setState(() {
          _isDriverVerified = true;
          _driverName = driver['driverName'] ?? 'Driver';
        });
      }
    } catch(e) { /* Not a driver yet */ }
  }

  @override void dispose() { _animController.dispose(); super.dispose(); }

  Future<void> _openSelectDropLocation() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => SelectDropLocationScreen(currentLatLng: _currentLatLng)));
    if (result != null && result is Map<String, dynamic>) {
      setState(() => _selectedDropLocation = result['address'] ?? 'Selected Location');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bharat Mitra - 100% Direct'),
        backgroundColor: const Color(0xFF1A3A6E),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          // Driver Mode Switch - Only if Verified
          if(_isDriverVerified)
            IconButton(icon: Icon(Icons.two_wheeler_rounded, color: Colors.yellowAccent), onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (_)=> DriverHomeScreen(driverName: _driverName))); }, tooltip: 'Go On Duty'),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.all(16), height: 120, width: double.infinity,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A3A6E), Color(0xFF2563EB)]), begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)),
            child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Stack(children: [
              Lottie.network('https://lottie.host/bike-car.json', fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (context, error, stackTrace) {
                return Stack(children: [
                  Positioned(left: 16, top: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                    Text('0% Commission Rides & Services', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Direct Driver UPI • 100% Transparent', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ])),
                  Positioned(bottom: 12, left: 0, right: 0, child: SlideTransition(position: _slideAnimation, child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.electric_bike_rounded, color: Color(0xFFFBBF24), size: 36), SizedBox(width: 8), Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 32)]))),
                ]);
              }),
            ])),
          ),
          // Driver On Duty Banner - Only if Verified
          if(_isDriverVerified)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.green)),
              child: Row(children: [
                Icon(Icons.verified_rounded, color: Colors.green),
                SizedBox(width: 10),
                Expanded(child: Text('Driver Verified - You can Go On Duty', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade800))),
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (_)=> DriverHomeScreen(driverName: _driverName))); }, child: Text('On Duty 🟢')),
              ]),
            ),
          if(!_isDriverVerified)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.orange)),
              child: Row(children: [
                Icon(Icons.info_rounded, color: Colors.orange),
                SizedBox(width: 10),
                Expanded(child: Text('Become a Driver to Earn 100% - On Duty only after Profile Creation', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                TextButton(onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (_)=> BecomeDriverScreen())); }, child: Text('Create')),
              ]),
            ),

          SizedBox(height: 12),
          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: InkWell(onTap: _openSelectDropLocation, borderRadius: BorderRadius.circular(16), child: Container(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(0xFF1A3A6E).withOpacity(0.2))), child: Row(children: [Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Color(0xFFC2410C).withOpacity(0.12), shape: BoxShape.circle), child: Icon(Icons.location_on_rounded, color: Color(0xFFC2410C), size: 20)), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Drop Location', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)), SizedBox(height: 2), Text(_selectedDropLocation, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)])), Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey)])))),
          SizedBox(height: 16),
          Container(margin: EdgeInsets.symmetric(horizontal: 16), height: 200, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)), child: ClipRRect(borderRadius: BorderRadius.circular(20), child: PlatformMap(initialCameraPosition: CameraPosition(target: _currentLatLng, zoom: 14), markers: {Marker(markerId: MarkerId('current_loc'), position: _currentLatLng, infoWindow: InfoWindow(title: 'Your Location (Barasat)'))}))),
          SizedBox(height: 20),
          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Explore Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6E)))),
          SizedBox(height: 12),
          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, shrinkWrap: true, physics: NeverScrollableScrollPhysics(), children: [
            _buildServiceCard(title: 'bookRide'.tr(), subtitle: 'Bike, Auto, Cab', icon: Icons.two_wheeler_rounded, color: Color(0xFF1A3A6E), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> HomeRideScreen()))),
            _buildServiceCard(title: 'rentDrive'.tr(), subtitle: 'Self-Drive Pan India', icon: Icons.car_rental_rounded, color: Color(0xFFC2410C), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> RentDriveScreen()))),
            _buildServiceCard(title: 'serviceProvider'.tr(), subtitle: 'Electrician, Plumber', icon: Icons.handyman_rounded, color: Color(0xFF16A34A), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> SebakListScreen()))),
            _buildServiceCard(title: 'hireDriver'.tr(), subtitle: 'Personal Chauffeur', icon: Icons.person_pin_circle_rounded, color: Color(0xFF7C3AED), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> HireDriverScreen()))),
          ])),
          SizedBox(height: 30),
        ]),
      ),
    );
  }
  Widget _buildServiceCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(0.2), width: 1.5)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 28)), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis), SizedBox(height: 2), Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)])]))); 
  }
}
