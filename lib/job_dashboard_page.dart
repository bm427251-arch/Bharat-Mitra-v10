import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common_widgets.dart';
import 'screens/company_post_job_screen.dart';
import 'screens/candidate_profile_create_screen.dart';
import 'services/alert_service.dart';

export 'services/alert_service.dart';

class JobDashboardPage extends StatefulWidget {
  const JobDashboardPage({super.key});

  @override
  State<JobDashboardPage> createState() => _JobDashboardPageState();
}

class _JobDashboardPageState extends State<JobDashboardPage> {
  bool _isSubscribed = true; // 100% Free Open Platform for both Jobs & Candidates
  bool _hasCandidateProfile = false;
  String _candidateName = 'Rahul Sharma';
  String _candidateCategory = 'Commercial Driver';
  String _candidateLocation = 'Madhyamgram, Kolkata 700129';

  @override
  void initState() {
    super.initState();
    _loadLocalProfileState();
  }

  Future<void> _loadLocalProfileState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasCandidateProfile = prefs.getBool('has_candidate_profile') ?? false;
      _candidateName = prefs.getString('candidate_name') ?? 'Rahul Sharma';
      _candidateCategory = prefs.getString('candidate_category') ?? 'Commercial Driver';
      _candidateLocation = prefs.getString('candidate_location') ?? 'Madhyamgram, Kolkata 700129';
      _isSubscribed = true;
    });
  }

  void _showSubscribeModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_open, color: Color(0xFFFF9933), size: 24),
                  const SizedBox(width: 10),
                  const Text(
                    'Unlock Full Direct Access',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Unlock direct calls to employers & candidates, view complete addresses on ISRO Mappls, and get instant job alerts.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF9933)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quarterly Plan',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text('3 Months Unlimited Access', style: TextStyle(color: Colors.white60, fontSize: 11)),
                      ],
                    ),
                    const Text(
                      '₹349 / 3 Months',
                      style: TextStyle(
                        color: Color(0xFFFF9933),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9933),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('job_wall_subscribed', true);
                    setState(() => _isSubscribed = true);
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF138808),
                        content: Text('Subscribed to ₹349 / 3 Months! Phone & Addresses are now UNLOCKED.'),
                      ),
                    );
                  },
                  child: const Text('Subscribe for ₹349 / 3 Months', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(dynamic rawTime) {
    if (rawTime is Timestamp) {
      final dt = rawTime.toDate();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (rawTime is String) {
      return rawTime;
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Job Dashboard - Double Wall',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() => _isSubscribed = !_isSubscribed);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: _isSubscribed ? const Color(0xFF138808) : Colors.grey[800],
                  content: Text(_isSubscribed
                      ? 'Subscription Active (349/3 Months): Wall Unlocked'
                      : 'Wall Locked (View-only mode: Subscribe to Call & Unlock Address)'),
                ),
              );
            },
            icon: Icon(
              _isSubscribed ? Icons.lock_open : Icons.lock,
              color: _isSubscribed ? Colors.greenAccent : const Color(0xFFFF9933),
              size: 16,
            ),
            label: Text(
              _isSubscribed ? 'UNLOCKED' : '349/3M',
              style: TextStyle(
                color: _isSubscribed ? Colors.greenAccent : const Color(0xFFFF9933),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const CustomPaint(size: Size.infinite, painter: TricolorWatermarkPainter()),
          const BharatMitraWatermark(),
          Column(
            children: [
              const SearchBarCommon(hint: 'Search Job Wall, Candidate Wall, Alerts...'),
              // ALERT BANNER SECTION
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFF9933)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Alerts: New matching jobs, Application status updates, Company direct messages',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      Container(
                        color: const Color(0xFF161616),
                        child: const TabBar(
                          isScrollable: true,
                          indicatorColor: Color(0xFFFF9933),
                          indicatorWeight: 3,
                          labelColor: Color(0xFFFF9933),
                          unselectedLabelColor: Colors.white60,
                          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          tabs: [
                            Tab(text: 'Candidate Dashboard'),
                            Tab(text: 'Company Dashboard'),
                            Tab(text: 'Job Wall (Company Posts)'),
                            Tab(text: 'Candidate Wall (Profiles)'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // 1. CANDIDATE DASHBOARD
                            _buildCandidateDashboardTab(),

                            // 2. COMPANY DASHBOARD
                            _buildCompanyDashboardTab(),

                            // 3. JOB WALL (DOUBLE WALL - COMPANY POSTS)
                            _buildJobWallTab(),

                            // 4. CANDIDATE WALL (DOUBLE WALL - CANDIDATE PROFILES)
                            _buildCandidateWallTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== CANDIDATE DASHBOARD TAB ====================
  Widget _buildCandidateDashboardTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('candidates')
          .doc('current_user_id')
          .collection('alerts')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        // Duplicate filter (Point 4): Filter alerts by unique title+message
        final seenAlerts = <String>{};
        final filteredAlerts = <DocumentSnapshot>[];
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final key = '${data['title']}_${data['message']}';
          if (!seenAlerts.contains(key)) {
            seenAlerts.add(key);
            filteredAlerts.add(doc);
          }
        }

        return ListView(
          padding: const EdgeInsets.all(8),
          children: [
            // CARD: 100% Free Open Dashboard - No lock or price texts
            Card(
              color: const Color(0xFF181818),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white12),
              ),
              child: const ListTile(
                title: Text(
                  'My Job Entry Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Alerts ON',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.verified, color: Color(0xFFFF9933), size: 13),
                    SizedBox(width: 4),
                    Text(
                      '100% Free Open Platform',
                      style: TextStyle(color: Color(0xFFFF9933), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // CREATE CANDIDATE PROFILE ACTION / STATUS (Point 11)
            if (!_hasCandidateProfile)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF9933)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.person_pin_circle_outlined, size: 40, color: Color(0xFFFF9933)),
                    const SizedBox(height: 8),
                    const Text(
                      'No Profile Yet',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Create candidate profile with photo, skills, and ISRO location to go live and receive alerts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9933),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CandidateProfileCreateScreen(
                              onProfileSaved: _loadLocalProfileState,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        '+ Create Candidate Profile',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF142414),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 18,
                      child: Icon(Icons.check, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _candidateName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'YOU LIVE',
                                  style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$_candidateCategory • 349/3 Months Active',
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white60, size: 18),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CandidateProfileCreateScreen(
                              onProfileSaved: _loadLocalProfileState,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

            // QUICK ACTIONS ROW
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9933),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () async {
                        await sendAlertToCandidates('Commercial Driver', 'Company Payroll');
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF138808),
                            content: Text('Triggered: New Job Alert sent to candidates!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send, size: 14),
                      label: const Text(
                        'Test Job Alert',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CompanyPostJobScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.business_center, size: 14),
                    label: const Text('Post Job', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Text(
              'Live Alert Inbox (Deduplicated)',
              style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            // FILTERED DEDUPLICATED ALERTS
            if (filteredAlerts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('No job alerts yet. New matches will arrive live.', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ),
              )
            else
              ...filteredAlerts.map((docSnap) {
                final doc = docSnap.data() as Map<String, dynamic>? ?? {};
                final title = doc['title']?.toString() ?? 'Job Alert';
                // Point 3: Remove "Company FREE Posted" from messages
                final rawMsg = doc['message']?.toString() ?? 'Matching opening available.';
                final cleanMsg = rawMsg.replaceAll('Company FREE Posted - ', '').replaceAll('Company FREE Posted', '');
                final timeStr = _formatTime(doc['time']);

                return Card(
                  color: const Color(0xFF181818),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.work_history, color: Color(0xFFFF9933)),
                    title: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      cleanMsg,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    trailing: Text(
                      timeStr,
                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  // ==================== COMPANY DASHBOARD TAB ====================
  Widget _buildCompanyDashboardTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('companies')
          .doc('current_company_id')
          .collection('alerts')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        return ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Card(
              color: Colors.green[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const ListTile(
                title: Text(
                  'Company Job Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), fontSize: 14),
                ),
                subtitle: Text('Alerts: Candidate Applications Received', style: TextStyle(color: Colors.black87, fontSize: 11)),
                trailing: Icon(Icons.notifications_active, color: Colors.green),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF138808),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CompanyPostJobScreen()),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('+ Post New Job', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF9933),
                    side: const BorderSide(color: Color(0xFFFF9933)),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  ),
                  onPressed: () async {
                    await sendAlertToCompany('current_company_id', 'Rahul Sharma (Candidate)');
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF138808),
                        content: Text('Triggered candidate application alert!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add, size: 14),
                  label: const Text('Test Apply Alert', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const Text(
              'Incoming Candidate Applications',
              style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            if (docs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('No applications received yet.', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ),
              )
            else
              ...docs.map((docSnap) {
                final doc = docSnap.data() as Map<String, dynamic>? ?? {};
                final title = doc['title']?.toString() ?? 'New Application';
                final message = doc['message']?.toString() ?? 'Candidate applied for job.';
                final timeStr = _formatTime(doc['time']);

                return Card(
                  color: const Color(0xFF181818),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person_pin, color: Color(0xFFFF9933)),
                    title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(message, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    trailing: Text(timeStr, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  // ==================== JOB WALL (COMPANY POSTS) ====================
  Widget _buildJobWallTab() {
    final sampleJobs = [
      {
        'title': 'Commercial Fleet Driver',
        'company': 'Apex Logistics Bengal',
        'address': 'Madhyamgram Chowrasta, Kolkata 700129',
        'distance': '0.5 km away (Madhyamgram)',
        'vacancies': '3 Openings',
        'phone': '+91 98301 55667',
      },
      {
        'title': 'Certified AC & Home Electrician',
        'company': 'North 24 Pgs Facility Hub',
        'address': 'Barasat Road, Madhyamgram 700129',
        'distance': '1.1 km away',
        'vacancies': '2 Openings',
        'phone': '+91 98302 77889',
      },
      {
        'title': 'B2B Field Sales Partner',
        'company': 'Kolkata Distribution Hub',
        'address': 'Jessore Road, Madhyamgram 700129',
        'distance': '1.4 km away',
        'vacancies': '5 Openings',
        'phone': '+91 98303 99001',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sampleJobs.length,
      itemBuilder: (ctx, idx) {
        final job = sampleJobs[idx];

        return Card(
          color: const Color(0xFF181818),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Colors.white12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      job['title']!,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        job['vacancies']!,
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(job['company']!, style: const TextStyle(color: Color(0xFFFF9933), fontSize: 12)),
                const SizedBox(height: 8),

                // Distance (Mandatory on all cards - Point 36)
                Row(
                  children: [
                    const Icon(Icons.near_me, color: Colors.blueAccent, size: 14),
                    const SizedBox(width: 4),
                    Text(job['distance']!, style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    const Icon(Icons.satellite_alt, color: Color(0xFF138808), size: 14),
                    const SizedBox(width: 4),
                    const Text('NavIC ISRO Verified', style: TextStyle(color: Color(0xFF138808), fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 8),

                // Address (100% UNLOCKED - Free Platform)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job['address']!,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Action Buttons: View Details + Call Employer (Both 100% Open, Free)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF161616),
                            content: Text('${job['title']} at ${job['company']} - Quick Apply Sent ✅'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline, size: 13),
                      label: const Text('View Details', style: TextStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF138808),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF138808),
                            content: Text('Calling ${job['company']} at ${job['phone']} (Free) ✅'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.call, size: 14),
                      label: const Text(
                        'Call Employer',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== CANDIDATE WALL (CANDIDATE PROFILES) ====================
  Widget _buildCandidateWallTab() {
    final sampleCandidates = [
      {
        'name': _candidateName,
        'category': _candidateCategory,
        'skills': 'Commercial Driving, Heavy & Light Vehicles',
        'address': _candidateLocation,
        'distance': '0.3 km away (Madhyamgram)',
        'experience': '4 Years Exp',
        'phone': '+91 98301 22334',
        'isYou': _hasCandidateProfile,
      },
      {
        'name': 'Amit Mondal',
        'category': 'Electrician & Wireman',
        'skills': '3-Phase Wiring, AC Installation, Inverters',
        'address': 'Barasat Road, Madhyamgram 700129',
        'distance': '0.9 km away',
        'experience': '5 Years Exp',
        'phone': '+91 98302 44556',
        'isYou': false,
      },
      {
        'name': 'Pooja Banerjee',
        'category': 'Tuition & Music Teacher',
        'skills': 'Classical Vocal, Rabindra Sangeet, Class 1-8',
        'address': 'Station Road, Madhyamgram 700129',
        'distance': '1.2 km away',
        'experience': '3 Years Exp',
        'phone': '+91 98303 66778',
        'isYou': false,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sampleCandidates.length,
      itemBuilder: (ctx, idx) {
        final cand = sampleCandidates[idx];
        final isYou = cand['isYou'] as bool? ?? false;

        return Card(
          color: const Color(0xFF181818),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: isYou ? Colors.green : Colors.white12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFFF9933),
                      child: const Icon(Icons.person, color: Colors.black, size: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                cand['name']!.toString(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              if (isYou) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('YOU LIVE', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          Text(cand['category']!.toString(), style: const TextStyle(color: Color(0xFFFF9933), fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(cand['experience']!.toString(), style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(cand['skills']!.toString(), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 8),

                // Distance (Point 36)
                Row(
                  children: [
                    const Icon(Icons.near_me, color: Colors.blueAccent, size: 14),
                    const SizedBox(width: 4),
                    Text(cand['distance']!.toString(), style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    const Icon(Icons.satellite_alt, color: Color(0xFF138808), size: 14),
                    const SizedBox(width: 4),
                    const Text('NavIC Satellite Verified', style: TextStyle(color: Color(0xFF138808), fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 8),

                // Address (100% UNLOCKED - Free Platform)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        cand['address']!.toString(),
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Action Buttons: View Profile + Call Candidate (Both 100% Open, Free)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF161616),
                            content: Text('Candidate Profile: ${cand['name']} - Skills: ${cand['skills']}'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 13),
                      label: const Text('View Profile', style: TextStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF138808),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF138808),
                            content: Text('Calling Candidate ${cand['name']} at ${cand['phone']} (Free) ✅'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.call, size: 14),
                      label: const Text(
                        'Call Candidate',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
