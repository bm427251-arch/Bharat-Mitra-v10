import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/ride_model.dart';
import '../services/location_service.dart';
import 'active_drivers_screen.dart';
import 'sebak_list_screen.dart';
import 'rent_drive_screen.dart';
import 'hire_driver_screen.dart';
import 'wallet_screen.dart';
import 'parcel_screen.dart';
import '../widgets/bharat_mitra_watermark.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCard = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'BHARAT MITRA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Stack(
        children: [
          const BharatMitraWatermark(),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.percent_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '0% Commission Platform',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'commission_banner'.tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.verified_user_rounded,
                        color: Colors.green,
                        size: 24,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 350.ms),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _card(
                              index: 0,
                              title: "bookRide".tr(),
                              subtitle: 'Bike, Toto, Auto, Car',
                              icon: Icons.directions_car_filled_rounded,
                              color: const Color(0xFFFF8C42),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ActiveDriversScreen(
                                      rideOption: RideOption.availableRides.first,
                                      pickupAddress: 'Current',
                                      dropAddress: 'Drop',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _card(
                              index: 1,
                              title: "rentDrive".tr(),
                              badge: 'PAN INDIA',
                              subtitle: 'Self-Drive',
                              icon: Icons.car_rental_rounded,
                              color: Colors.blueAccent,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RentDriveScreen(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _card(
                              index: 2,
                              title: "serviceProvider".tr(),
                              badge: '0% CUT',
                              subtitle: 'Electrician, Plumber',
                              icon: Icons.home_repair_service_rounded,
                              color: Colors.orangeAccent,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SebakListScreen(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _card(
                              index: 3,
                              title: "hireDriver".tr(),
                              badge: 'Rs700',
                              subtitle: '8 Hours Shift',
                              icon: Icons.airline_seat_recline_normal_rounded,
                              color: Colors.tealAccent,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
