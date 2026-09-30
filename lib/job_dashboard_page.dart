import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'common_widgets.dart';
import 'screens/company_post_job_screen.dart';
import 'services/alert_service.dart';

export 'services/alert_service.dart';

class JobDashboardPage extends StatelessWidget {
  const JobDashboardPage({super.key});

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
          'Job Dashboard - Alert System',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          const CustomPaint(size: Size.infinite, painter: TricolorWatermarkPainter()),
          const BharatMitraWatermark(),
          Column(
            children: [
              const SearchBarCommon(hint: 'Search My Jobs, Applications, Alerts...'),
              // ALERT BANNER SECTION
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFF9933)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Alerts: New jobs matching your profile, Application status update, Company messages',
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
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        color: const Color(0xFF161616),
                        child: const TabBar(
                          indicatorColor: Color(0xFFFF9933),
                          indicatorWeight: 3,
                          labelColor: Color(0xFFFF9933),
                          unselectedLabelColor: Colors.white60,
                          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          tabs: [
                            Tab(text: 'Candidate Dashboard'),
                            Tab(text: 'Company Dashboard'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // ==================== CANDIDATE DASHBOARD ====================
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('candidates')
                                  .doc('current_user_id')
                                  .collection('alerts')
                                  .orderBy('time', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final docs = snapshot.data?.docs ?? [];

                                return ListView.builder(
                                  itemCount: docs.length + 2,
                                  padding: const EdgeInsets.all(8),
                                  itemBuilder: (_, i) {
                                    if (i == 0) {
                                      return Card(
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
                                          subtitle: Text(
                                            'Subscription: 349/Y Active - Alerts ON',
                                            style: TextStyle(
                                              color: Color(0xFFFF9933),
                                              fontSize: 11,
                                            ),
                                          ),
                                          trailing: Icon(Icons.check_circle, color: Colors.green),
                                        ),
                                      );
                                    }

                                    if (i == 1) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                                                      content: Text('Triggered: New Job Alert sent to subscribed candidates!'),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.send, size: 14),
                                                label: const Text(
                                                  'Test Candidate Alert',
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                side: const BorderSide(color: Colors.white24),
                                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => const CompanyPostJobScreen(),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.search, size: 14),
                                              label: const Text(
                                                'Explore Jobs',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    final doc = docs[i - 2].data() as Map<String, dynamic>? ?? {};
                                    final title = doc['title']?.toString() ?? 'New Job Alert - Company Payroll';
                                    final message = doc['message']?.toString() ?? 'Commercial Driver - Company FREE Posted - Apply Now';
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
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: Text(
                                          message,
                                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                                        ),
                                        trailing: Text(
                                          timeStr,
                                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),

                            // ==================== COMPANY DASHBOARD ====================
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('companies')
                                  .doc('current_company_id')
                                  .collection('alerts')
                                  .orderBy('time', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final docs = snapshot.data?.docs ?? [];

                                return ListView.builder(
                                  itemCount: docs.length + 2,
                                  padding: const EdgeInsets.all(8),
                                  itemBuilder: (_, i) {
                                    if (i == 0) {
                                      return Card(
                                        color: Colors.green[50],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const ListTile(
                                          title: Text(
                                            'Company Job Dashboard - FREE Posting',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1B5E20),
                                              fontSize: 14,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Alerts: New Application Received',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 11,
                                            ),
                                          ),
                                          trailing: Icon(Icons.notifications_active, color: Colors.green),
                                        ),
                                      );
                                    }

                                    if (i == 1) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                        child: Row(
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
                                                    MaterialPageRoute(
                                                      builder: (_) => const CompanyPostJobScreen(),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.add_circle_outline, size: 14),
                                                label: const Text(
                                                  '+ Post FREE Job',
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                ),
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
                                                await sendAlertToCompany(
                                                  'current_company_id',
                                                  'Rahul Sharma (Commercial Driver)',
                                                );
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    backgroundColor: Color(0xFF138808),
                                                    content: Text('Triggered: New Candidate Application alert sent to Company!'),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.person_add, size: 14),
                                              label: const Text(
                                                'Test Apply Alert',
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    final doc = docs[i - 2].data() as Map<String, dynamic>? ?? {};
                                    final title = doc['title']?.toString() ?? 'New Application';
                                    final message = doc['message']?.toString() ?? 'Candidate applied for your job - Check Dashboard';
                                    final timeStr = _formatTime(doc['time']);

                                    return Card(
                                      color: const Color(0xFF181818),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(color: Colors.white12),
                                      ),
                                      child: ListTile(
                                        leading: const Icon(Icons.person_pin, color: Color(0xFFFF9933)),
                                        title: Text(
                                          title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: Text(
                                          message,
                                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              timeStr,
                                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'Live Alert',
                                                style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
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
}
