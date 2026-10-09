import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common_widgets.dart';
import 'candidate_profile_create_screen.dart';
import 'company_post_job_screen.dart';
import 'service_provider_profile_screen.dart';
import 'become_sebak_screen.dart';
import 'owner_add_vehicle_screen.dart';
import 'become_driver_screen.dart';
import 'my_trips_screen.dart';
import 'wallet_screen.dart';
import 'parcel_screen.dart';
import '../technician_page.dart';
import '../professional_page.dart';
import '../outstation_page.dart';
import '../elite_sos_page.dart';
import '../job_dashboard_page.dart';
import '../isro_map_page.dart';

class MyProfilesOverviewScreen extends StatefulWidget {
  const MyProfilesOverviewScreen({super.key});

  @override
  State<MyProfilesOverviewScreen> createState() => _MyProfilesOverviewScreenState();
}

class _MyProfilesOverviewScreenState extends State<MyProfilesOverviewScreen> {
  bool _hasCandidateProfile = false;
  String _candidateName = 'Rahul Sharma';
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasCandidateProfile = prefs.getBool('has_candidate_profile') ?? false;
      _candidateName = prefs.getString('candidate_name') ?? 'Rahul Sharma';
      _isSubscribed = prefs.getBool('job_wall_subscribed') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'My Profile & Services',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          const CustomPaint(size: Size.infinite, painter: TricolorWatermarkPainter()),
          const BharatMitraWatermark(),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. MEMBERSHIP STATUS CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF221100), Color(0xFF0C1F0C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF138808)),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 22,
                      child: Icon(Icons.verified, color: Colors.black, size: 24),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Platform Membership',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Status: 100% Free Open Platform (Zero Commission Guaranteed)',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. MY ESSENTIAL SERVICES (WALLET & PARCEL)
              const Text(
                'Essential Services',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 10),

              // WALLET MENU ITEM
              _profileTile(
                title: 'My Wallet',
                subtitle: 'Check wallet balance, transaction history & instant recharge',
                icon: Icons.account_balance_wallet,
                iconColor: Colors.greenAccent,
                actionText: 'Open Wallet',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WalletScreen(),
                      settings: const RouteSettings(name: '/wallet'),
                    ),
                  );
                },
              ),

              // PARCEL SERVICE MENU ITEM
              _profileTile(
                title: 'Parcel Service',
                subtitle: 'Doorstep parcel pickup, delivery & intercity shipping',
                icon: Icons.local_shipping,
                iconColor: Colors.deepOrangeAccent,
                actionText: 'Parcel Service',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ParcelScreen(),
                      settings: const RouteSettings(name: '/parcel'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 3. ALL ON-DEMAND HOME SERVICES MENU (Moved from Home Page)
              const Text(
                'Services Directory',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 10),

              // TECHNICIANS & HOME SERVICES
              _profileTile(
                title: 'Technicians & Home Services',
                subtitle: 'Verified electricians, plumbers, AC mechanics, carpenters',
                icon: Icons.handyman,
                iconColor: Colors.blueAccent,
                actionText: 'View Techs',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TechnicianPage()),
                  );
                },
              ),

              // PROFESSIONALS
              _profileTile(
                title: 'Professional Services',
                subtitle: 'Advocates, CAs, doctors, beauticians, teachers & experts',
                icon: Icons.work,
                iconColor: Colors.purpleAccent,
                actionText: 'View Pros',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfessionalPage()),
                  );
                },
              ),

              // OUTSTATION + RURAL
              _profileTile(
                title: 'Outstation & Rural Rides',
                subtitle: 'Book intercity Bike, Car, Auto & Toto with 0% surge',
                icon: Icons.directions_car,
                iconColor: Colors.greenAccent,
                actionText: 'Explore',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OutstationPage()),
                  );
                },
              ),

              // ELITE SOS GROUP
              _profileTile(
                title: 'Elite SOS Emergency Circle',
                subtitle: '24H Live NavIC satellite emergency tracking & security shield',
                icon: Icons.shield,
                iconColor: Colors.redAccent,
                actionText: 'Open SOS',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EliteSOSPage()),
                  );
                },
              ),

              // JOB DASHBOARD
              _profileTile(
                title: 'Job Dashboard & Hiring Portal',
                subtitle: 'Post free vacancies & connect directly with candidates',
                icon: Icons.business_center,
                iconColor: Colors.tealAccent,
                actionText: 'Job Wall',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JobDashboardPage()),
                  );
                },
              ),

              // ISRO MAPPLS + NavIC
              _profileTile(
                title: 'ISRO Mappls & NavIC GPS',
                subtitle: 'Sovereign indigenous satellite map with real-time positioning',
                icon: Icons.satellite_alt,
                iconColor: const Color(0xFF138808),
                actionText: 'Open Map',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ISROMapPage()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 4. PROVIDER PROFILE CREATION & MANAGEMENT
              const Text(
                'Manage & Create Provider Profiles',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 10),

              // CANDIDATE PROFILE
              _profileTile(
                title: _hasCandidateProfile ? 'Candidate Profile (Active)' : 'Candidate Profile',
                subtitle: _hasCandidateProfile ? '$_candidateName • Active on Candidate Wall' : 'Job Seeker • Upload CV, skills & NavIC location',
                icon: Icons.person_search,
                iconColor: const Color(0xFFFF9933),
                actionText: _hasCandidateProfile ? 'Edit Profile' : '+ Create',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CandidateProfileCreateScreen(onProfileSaved: _loadState),
                    ),
                  );
                },
              ),

              // COMPANY PROFILE
              _profileTile(
                title: 'Company / Employer Profile',
                subtitle: 'Post jobs for free • Hire drivers, techs & sales staff',
                icon: Icons.business,
                iconColor: Colors.blue,
                actionText: '+ Post Job',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CompanyPostJobScreen()),
                  );
                },
              ),

              // PRO PROFILE
              _profileTile(
                title: 'Professional Service Provider',
                subtitle: 'Advocate, CA, Doctor, Beautician, Teacher, Photographer',
                icon: Icons.badge,
                iconColor: Colors.purpleAccent,
                actionText: '+ Become Pro',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ServiceProviderProfileScreen()),
                  );
                },
              ),

              // TECHNICIAN PROFILE
              _profileTile(
                title: 'Technician Profile (Sevak)',
                subtitle: 'Plumber, Electrician, AC Repair, Mechanic, Carpenter',
                icon: Icons.handyman,
                iconColor: Colors.amber,
                actionText: '+ Become Tech',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BecomeSebakScreen()),
                  );
                },
              ),

              // OUTSTATION VEHICLE
              _profileTile(
                title: 'Vehicle Fleet / Outstation Owner',
                subtitle: 'Register Bike, Car, Auto, Toto or E-Rickshaw',
                icon: Icons.local_taxi,
                iconColor: const Color(0xFF138808),
                actionText: '+ Add Vehicle',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OwnerAddVehicleScreen()),
                  );
                },
              ),

              // DRIVER PROFILE
              _profileTile(
                title: 'Ride Pilot / Driver Partner',
                subtitle: 'Drive Bike, Auto, Cab • 0% Commission Guarantee',
                icon: Icons.two_wheeler,
                iconColor: const Color(0xFFFF9933),
                actionText: '+ Become Driver',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BecomeDriverScreen()),
                  );
                },
              ),

              // MY RIDES & TRIPS HISTORY
              _profileTile(
                title: 'Ride & Service History',
                subtitle: 'Past rides, technician visits, payments & digital receipts',
                icon: Icons.history,
                iconColor: Colors.tealAccent,
                actionText: 'View Trips',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyTripsScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Card(
      color: const Color(0xFF181818),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Colors.white12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.18),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9933),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: const Size(60, 32),
          ),
          onPressed: onAction,
          child: Text(actionText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
