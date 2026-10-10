import 'package:flutter/material.dart';
import '../models/ride_model.dart';
import 'active_drivers_screen.dart';
import 'rent_drive_screen.dart';
import 'sebak_list_screen.dart';
import 'hire_driver_screen.dart';
import 'wallet_screen.dart';
import 'parcel_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('BHARAT MITRA'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _btn('Book Ride - Bike, Toto, Auto', Icons.car_rental, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ActiveDriversScreen(
              rideOption: RideOption.availableRides.first,
              pickupAddress: 'Current',
              dropAddress: 'Drop',
            )));
          }),
          _btn('Rent Drive - PAN INDIA', Icons.car_rental_rounded, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RentDriveScreen()));
          }),
          _btn('Service Provider - 0% CUT', Icons.home_repair_service, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SebakListScreen()));
          }),
          _btn('Hire Driver - Rs700', Icons.person, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HireDriverScreen()));
          }),
          _btn('Wallet - Rs0', Icons.wallet, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
          }),
          _btn('Parcel - NEW', Icons.local_shipping, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ParcelScreen()));
          }),
        ],
      ),
    );
  }

  Widget _btn(String t, IconData ic, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(ic),
        label: Text(t),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(18),
        ),
      ),
    );
  }
}
