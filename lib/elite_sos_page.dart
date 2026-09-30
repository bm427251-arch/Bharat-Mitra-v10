import 'package:flutter/material.dart';
import 'common_widgets.dart';

class EliteSOSPage extends StatefulWidget {
  const EliteSOSPage({super.key});

  @override
  State<EliteSOSPage> createState() => _EliteSOSPageState();
}

class _EliteSOSPageState extends State<EliteSOSPage> {
  int _membersCount = 10;
  final TextEditingController _memberController = TextEditingController(text: '10');

  int calcPrice(int members) => members * 29; // FINAL - 29 Taka Per Person - 24H

  @override
  void dispose() {
    _memberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Elite SOS - 29/member/24H',
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // FREE Permanent Banner
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: const Text(
                    'FREE Permanent: 1 Group, 3 Member, Only Text Alert - Free',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // PAID 24 Hours Validity Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'PAID - 24 Hours Validity - Special Need',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '29 Taka / Person / 24 Hours - Live GPS + SOS + Chat',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Example: 10 Cars Marriage = 10x29=290 Rs | 5 Bikers=145 Rs | 24H Auto Expire - Renew Again 29',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Members Count TextField
                TextField(
                  controller: _memberController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black87),
                  onChanged: (val) {
                    final parsed = int.tryParse(val.trim());
                    setState(() {
                      _membersCount = (parsed != null && parsed > 0) ? parsed : 0;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Add Members Count',
                    labelStyle: const TextStyle(color: Color(0xFFFF9933), fontWeight: FontWeight.bold),
                    hintText: 'e.g. 10',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFFF9933)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Dynamic Total Calculation
                Text(
                  'Total: ₹${calcPrice(_membersCount)} for $_membersCount Members - 24H',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFFFF9933),
                  ),
                ),
                const SizedBox(height: 20),

                // Large Circular SOS Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(180, 180),
                      shape: const CircleBorder(),
                      elevation: 8,
                      shadowColor: Colors.redAccent.withOpacity(0.5),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 4),
                          content: Text(
                            'EMERGENCY SOS TRIGGERED! Broadcasting live GPS coordinates and distress signal to 112 & active group members!',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'SOS',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Description of use cases
                const Text(
                  'Use: Marriage 10 Cars, Bike Ride Group, Family Tour - Tracking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),

                // Create 24H Group Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9933),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF138808),
                        content: Text(
                          'Elite 24H Group Created! Total: ₹${calcPrice(_membersCount)} for $_membersCount members. Live GPS tracking initialized.',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Create 24H Group',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
