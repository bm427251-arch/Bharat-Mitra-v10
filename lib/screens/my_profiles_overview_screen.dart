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
          'My Profiles & Applications',
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
              // 1. SUBSCRIPTION STATUS CARD (Point 1, 16)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF221100), Color(0xFF0C1F0C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFF9933)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _isSubscribed ? Colors.green : const Color(0xFFFF9933),
                      radius: 22,
                      child: Icon(_isSubscribed ? Icons.verified : Icons.lock_clock, color: Colors.black, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Platform Membership',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isSubscribed
                                ? 'Status: 349/3 Months Active (All Walls Unlocked)'
                                : 'Status: Free Member (Tap to Subscribe ₹349/3M)',
                            style: TextStyle(
                              color: _isSubscribed ? Colors.greenAccent : const Color(0xFFFF9933),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9933),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final newStatus = !_isSubscribed;
                        await prefs.setBool('job_wall_subscribed', newStatus);
                        setState(() => _isSubscribed = newStatus);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF138808),
                            content: Text(newStatus
                                ? 'Subscribed: ₹349 / 3 Months Activated!'
                                : 'Membership reset to Free'),
                          ),
                        );
                      },
                      child: Text(
                        _isSubscribed ? 'Active' : 'Subscribe',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. MY APPLICATIONS
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_turned_in_outlined, color: Colors.blueAccent, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My Job Applications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('2 active applications • 1 under review', style: TextStyle(color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF138808),
                            content: Text('Viewing 2 submitted job applications.'),
                          ),
                        );
                      },
                      child: const Text('View', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. CREATE / EDIT PROFILES SECTION (Points 11 - 15)
              const Text(
                'Manage & Create Provider Profiles',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 10),

              // CANDIDATE PROFILE (Point 11)
              _profileTile(
                title: _hasCandidateProfile ? 'Candidate Profile (YOU LIVE)' : 'Candidate Profile',
                subtitle: _hasCandidateProfile ? '$_candidateName • Active on Candidate Wall' : 'Job Seeker • Upload CV, Skills & ISRO location',
                icon: Icons.person_search,
                iconColor: const Color(0xFFFF9933),
                actionText: _hasCandidateProfile ? 'Edit Profile' : '+ Create Candidate',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CandidateProfileCreateScreen(onProfileSaved: _loadState),
                    ),
                  );
                },
              ),

              // COMPANY PROFILE (Point 12)
              _profileTile(
                title: 'Company / Employer Profile',
                subtitle: 'Post Jobs for Free • Hire Drivers, Techs & Sales',
                icon: Icons.business,
                iconColor: Colors.blue,
                actionText: '+ Create Company',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CompanyPostJobScreen()),
                  );
                },
              ),

              // PRO PROFILE (Point 13)
              _profileTile(
                title: 'Professional Profile',
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

              // TECHNICIAN PROFILE (Point 14)
              _profileTile(
                title: 'Technician Profile',
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

              // OUTSTATION VEHICLE (Point 15)
              _profileTile(
                title: 'Vehicle Fleet / Outstation',
                subtitle: 'Register Bike, Car, Auto, Toto or E-Rickshaw for Rural/Outstation',
                icon: Icons.directions_car,
                iconColor: const Color(0xFF138808),
                actionText: '+ Register Vehicle',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OwnerAddVehicleScreen()),
                  );
                },
              ),

              // DRIVER PROFILE
              _profileTile(
                title: 'Ride Pilot / Driver',
                subtitle: 'Drive Bike, Auto, Cab • 5% Cheaper than Other Apps',
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
                subtitle: 'Past rides, technician visits, payments & receipts',
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
