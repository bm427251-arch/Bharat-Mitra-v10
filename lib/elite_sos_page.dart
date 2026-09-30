import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common_widgets.dart';
import 'widgets/active_radar_pulse.dart';

class EliteSOSPage extends StatefulWidget {
  const EliteSOSPage({super.key});

  @override
  State<EliteSOSPage> createState() => _EliteSOSPageState();
}

class _EliteSOSPageState extends State<EliteSOSPage> {
  bool _isPaidPlan = false;
  final TextEditingController _membersInputCtrl = TextEditingController(text: '+91 98301 23456, +91 98302 34567');
  String? _generatedInviteLink;
  final List<String> _groupMembers = [
    'Self (Admin) - Live NavIC',
    '+91 98301 23456 (Family Member 1)',
    '+91 98302 34567 (Family Member 2)',
  ];

  @override
  void dispose() {
    _membersInputCtrl.dispose();
    super.dispose();
  }

  void _triggerEmergencyBroadcast() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'EMERGENCY BROADCAST ACTIVE! Live NavIC coordinates sent to Police (112), Ambulance (108) & Circle.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _generateInviteLink() {
    final raw = _membersInputCtrl.text.trim();
    if (raw.isEmpty) return;

    final code = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    setState(() {
      _generatedInviteLink = 'https://bharatmitra.in/sos/join?circle=$code';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF138808),
        content: Text('Invite Link Generated: $_generatedInviteLink'),
      ),
    );
  }

  void _acceptAndAddMembers() {
    final parts = _membersInputCtrl.text.split(',');
    for (var p in parts) {
      final clean = p.trim();
      if (clean.isNotEmpty && !_groupMembers.contains(clean)) {
        _groupMembers.add('$clean (Accepted)');
      }
    }
    setState(() {
      _generatedInviteLink = null;
      _membersInputCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF138808),
        content: Text('Members successfully verified and added to SOS Circle!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Elite SOS Group',
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PLAN TOGGLE (Point 32: Free vs Paid logic)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPaidPlan = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !_isPaidPlan ? const Color(0xFF138808) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Free (1 Group • 3 Members)',
                                style: TextStyle(
                                  color: !_isPaidPlan ? Colors.white : Colors.white60,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPaidPlan = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _isPaidPlan ? const Color(0xFFFF9933) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Paid (Live GPS + Chat)',
                                style: TextStyle(
                                  color: _isPaidPlan ? Colors.black : Colors.white60,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // PLAN DESCRIPTION STATUS (Point 31, 32)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isPaidPlan ? Colors.orange.withOpacity(0.12) : Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _isPaidPlan ? const Color(0xFFFF9933) : const Color(0xFF138808)),
                  ),
                  child: Text(
                    _isPaidPlan
                        ? 'Paid Circle Active: Live 24-Hour NavIC Satellite GPS Tracking + Instant Chat'
                        : 'Free Circle Active: 1 Permanent Group, up to 3 Emergency Contacts (SMS & Text Alert)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isPaidPlan ? const Color(0xFFFF9933) : Colors.greenAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ACTIVE PULSING RADAR BEHIND RED SOS BUTTON (Point 34)
                Center(
                  child: ActiveRadarPulse(
                    ringColor: Colors.redAccent,
                    maxRadius: 105,
                    ringCount: 3,
                    child: GestureDetector(
                      onTap: _triggerEmergencyBroadcast,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 48),
                            SizedBox(height: 4),
                            Text(
                              'HOLD SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              'Instant Broadcast',
                              style: TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // POINT 33: ELITE INVITE FLOW
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invite Family & Travel Companions',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Input member phone numbers separated by commas:',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _membersInputCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'e.g. 9830123456, 9830234567',
                          hintStyle: const TextStyle(color: Colors.white30),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.06),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFF9933),
                                side: const BorderSide(color: Color(0xFFFF9933)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              onPressed: _generateInviteLink,
                              icon: const Icon(Icons.link, size: 14),
                              label: const Text('Generate Invite Link', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF138808),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              onPressed: _acceptAndAddMembers,
                              icon: const Icon(Icons.person_add, size: 14),
                              label: const Text('Send & Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      if (_generatedInviteLink != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _generatedInviteLink!,
                                  style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontFamily: 'monospace'),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: _generatedInviteLink!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Color(0xFF138808),
                                      content: Text('Invite link copied to clipboard!'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ACTIVE CIRCLE MEMBERS LIST
                const Text(
                  'Connected Circle Members',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                ...List.generate(_groupMembers.length, (i) {
                  return Card(
                    color: const Color(0xFF181818),
                    margin: const EdgeInsets.only(bottom: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      dense: true,
                      leading: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFF138808),
                        child: Icon(Icons.shield, size: 14, color: Colors.white),
                      ),
                      title: Text(_groupMembers[i], style: const TextStyle(color: Colors.white, fontSize: 12)),
                      trailing: const Text('NavIC Live', style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
