import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'common_widgets.dart';
import 'screens/service_provider_profile_screen.dart';
import 'services/location_service.dart';

class ProfessionalPage extends StatefulWidget {
  const ProfessionalPage({super.key});

  @override
  State<ProfessionalPage> createState() => _ProfessionalPageState();
}

class _ProfessionalPageState extends State<ProfessionalPage> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _subCategoryInputCtrl = TextEditingController();

  double _userLat = 22.6900; // Madhyamgram center default
  double _userLng = 88.4600;
  String _userArea = 'Madhyamgram';

  final List<String> _categories = const [
    'All',
    'Teacher',
    'Advocate',
    'CA',
    'Doctor',
    'Artist',
    'Beautician',
    'Photographer',
    'Cameraman',
  ];

  final List<Map<String, dynamic>> _professionals = const [
    {
      'name': 'Pooja Banerjee',
      'category': 'Teacher',
      'subCategory': 'Classical Music & Rabindra Sangeet',
      'exp': 'Music Teacher • 7 Yrs Exp',
      'lat': 22.6930,
      'lng': 88.4640,
      'rating': '4.9 ★ (140)',
      'services': 'Classical Vocal, Harmonium, Class 1-10 Tuition',
      'reviews': 'Very patient and skilled teacher. Highly recommended!',
      'status': 'Confirmed',
      'phone': '+91 98321 00055',
    },
    {
      'name': 'Sanjay Roy',
      'category': 'Teacher',
      'subCategory': 'Dance - Kathak & Folk',
      'exp': 'Choreographer & Instructor • 9 Yrs Exp',
      'lat': 22.6850,
      'lng': 88.4550,
      'rating': '4.8 ★ (92)',
      'services': 'Kathak, Bollywood Contemporary, Stage Performance',
      'reviews': 'Excellent choreography for school and family events.',
      'status': 'Confirmed',
      'phone': '+91 98321 00056',
    },
    {
      'name': 'Adv. Debasish Banerjee',
      'category': 'Advocate',
      'subCategory': 'High Court & Civil Matters',
      'exp': 'High Court Advocate • 14 Yrs Exp',
      'lat': 22.7010,
      'lng': 88.4680,
      'rating': '4.9 ★ (184)',
      'services': 'Property disputes, Corporate agreements, Bail & Civil',
      'reviews': 'Accurate legal counsel with clear guidance.',
      'status': 'Confirmed',
      'phone': '+91 98321 00011',
    },
    {
      'name': 'CA Meenakshi Sen',
      'category': 'CA',
      'subCategory': 'Corporate Tax & GST Filing',
      'exp': 'Chartered Accountant • 8 Yrs Exp',
      'lat': 22.6950,
      'lng': 88.4580,
      'rating': '4.9 ★ (210)',
      'services': 'ITR Returns, GST Audit, Company Incorporation',
      'reviews': 'Saved our firm significant tax penalties. Swift filing.',
      'status': 'Confirmed',
      'phone': '+91 98321 00022',
    },
    {
      'name': 'Dr. Arindam Mukherjee, MD',
      'category': 'Doctor',
      'subCategory': 'General Physician & Telehealth',
      'exp': 'Senior Physician • 11 Yrs Exp',
      'lat': 22.6880,
      'lng': 88.4620,
      'rating': '4.9 ★ (340)',
      'services': 'Family medicine, Diabetic care, Routine health checks',
      'reviews': 'Caring doctor with accurate diagnosis.',
      'status': 'Confirmed',
      'phone': '+91 98321 00033',
    },
    {
      'name': 'Pooja Glamour Salon & Bridal',
      'category': 'Beautician',
      'subCategory': 'Bridal & Party Makeover',
      'exp': 'Certified Aesthetician • 6 Yrs Exp',
      'lat': 22.6920,
      'lng': 88.4500,
      'rating': '4.9 ★ (175)',
      'services': 'HD Bridal makeup, Hair spa, Organic facials',
      'reviews': 'Flawless makeup that stayed throughout the wedding night.',
      'status': 'Confirmed',
      'phone': '+91 98321 00041',
    },
    {
      'name': 'Subrata Paul Photography',
      'category': 'Photographer',
      'subCategory': 'Wedding & Cinematic Candid',
      'exp': 'Visual Artist & Studio Owner • 8 Yrs Exp',
      'lat': 22.6960,
      'lng': 88.4700,
      'rating': '4.9 ★ (160)',
      'services': 'Pre-wedding shoots, 4K video, Drone cinematography',
      'reviews': 'Breathtaking photos and candid portraits.',
      'status': 'Confirmed',
      'phone': '+91 98321 00043',
    },
    {
      'name': 'Suman Video & Drone Media',
      'category': 'Cameraman',
      'subCategory': 'Live Event & Multi-Cam Streaming',
      'exp': 'Cinematographer • 5 Yrs Exp',
      'lat': 22.7050,
      'lng': 88.4750,
      'rating': '4.8 ★ (89)',
      'services': 'Live streaming, 4K multicam, Corporate coverage',
      'reviews': 'High technical mastery and reliable crew.',
      'status': 'Confirmed',
      'phone': '+91 98321 00042',
    },
    {
      'name': 'Shampa Dey Art Studio',
      'category': 'Artist',
      'subCategory': 'Portrait & Oil Canvas Painter',
      'exp': 'Fine Arts Graduate • 7 Yrs Exp',
      'lat': 22.6800,
      'lng': 88.4520,
      'rating': '4.9 ★ (72)',
      'services': 'Custom oil portraits, Acrylic murals, Charcoal sketching',
      'reviews': 'Beautiful life-like family portrait painting.',
      'status': 'Confirmed',
      'phone': '+91 98321 00057',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchRealLocation();
  }

  Future<void> _fetchRealLocation() async {
    try {
      final loc = await LocationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _userLat = loc.latitude;
          _userLng = loc.longitude;
          _userArea = loc.area.isNotEmpty ? loc.area : 'Madhyamgram';
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _subCategoryInputCtrl.dispose();
    super.dispose();
  }

  String _calculateDynamicDistance(double proLat, double proLng) {
    try {
      final meters = Geolocator.distanceBetween(_userLat, _userLng, proLat, proLng);
      final km = meters / 1000;
      if (km < 0.1) return 'Within 100m';
      return '${km.toStringAsFixed(1)} km away';
    } catch (_) {
      return '0.6 km away';
    }
  }

  void _callProfessional(Map<String, dynamic> pro) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF138808),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.call, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Calling ${pro['name']} (${pro['phone']}) - 100% Free Service Call ✅',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullProfile(Map<String, dynamic> pro) {
    final distanceText = _calculateDynamicDistance(
      pro['lat'] as double? ?? 22.69,
      pro['lng'] as double? ?? 88.46,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFFFF9933),
                        child: const Icon(Icons.person, size: 40, color: Colors.black),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pro['name'] as String,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              '${pro['category']} • ${pro['subCategory']}',
                              style: const TextStyle(color: Color(0xFFFF9933), fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(pro['rating'] as String, style: const TextStyle(color: Colors.amber, fontSize: 12)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                    pro['status'] as String,
                                    style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  const Text('Experience & Credentials', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(pro['exp'] as String, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 14),
                  const Text('Mandatory Distance via ISRO NavIC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.blueAccent),
                      const SizedBox(width: 4),
                      Text(
                        '$distanceText from $_userArea',
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Services Offered', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(pro['services'] as String, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 14),
                  const Text('Verified Client Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('"${pro['reviews']}"', style: const TextStyle(color: Colors.white60, fontStyle: FontStyle.italic, fontSize: 12)),
                  const SizedBox(height: 24),

                  // 100% FREE CALL NOW - NO LOCK ANYWHERE
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF138808),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _callProfessional(pro);
                      },
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text(
                        'Call Now - Free Service Call',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _professionals.where((p) {
      final matchesCat = _selectedCategory == 'All' || p['category'] == _selectedCategory;
      final q = _searchController.text.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          p['name']!.toString().toLowerCase().contains(q) ||
          p['category']!.toString().toLowerCase().contains(q) ||
          p['subCategory']!.toString().toLowerCase().contains(q);
      final subQ = _subCategoryInputCtrl.text.trim().toLowerCase();
      final matchesSub = subQ.isEmpty || p['subCategory']!.toString().toLowerCase().contains(subQ);

      return matchesCat && matchesQuery && matchesSub;
    }).toList();

    final showTypeYourCategoryField = _selectedCategory == 'Teacher' ||
        _selectedCategory == 'Doctor' ||
        _selectedCategory == 'Artist' ||
        _selectedCategory == 'Advocate';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Professionals',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '100% Free Open Platform • ISRO NavIC Connected',
              style: TextStyle(color: Color(0xFFFF9933), fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
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
              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search Advocate, CA, Doctor, Teacher, Artist...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFFF9933)),
                    filled: true,
                    fillColor: const Color(0xFF161616),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                  ),
                ),
              ),

              // CATEGORY CHIPS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: _categories.map((c) {
                    final isSel = _selectedCategory == c;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: ChoiceChip(
                        label: Text(c, style: TextStyle(color: isSel ? Colors.black : Colors.white70, fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                        selected: isSel,
                        selectedColor: const Color(0xFFFF9933),
                        backgroundColor: const Color(0xFF161616),
                        onSelected: (val) {
                          setState(() {
                            _selectedCategory = c;
                            _subCategoryInputCtrl.clear();
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // POINT 28: TEACHER / DOCTOR / ADVOCATE / ARTIST TYPE YOUR CATEGORY FIELD
              if (showTypeYourCategoryField)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
                  child: TextField(
                    controller: _subCategoryInputCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: _selectedCategory == 'Teacher'
                          ? 'What kind of Teacher? Type here - Dance / Music / Tuition'
                          : 'Type Your Category / Specialization...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                      prefixIcon: const Icon(Icons.edit_note, color: Color(0xFFFF9933), size: 18),
                      filled: true,
                      fillColor: const Color(0xFF1C1C1C),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white24)),
                    ),
                  ),
                ),

              // ACTION BUTTON
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9933),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ServiceProviderProfileScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_moderator, size: 16),
                    label: const Text('+ Create Professional Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ),

              // PROFESSIONALS LIST - NO LOCK ANYWHERE - BOTH VIEW & CALL OPEN
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final pro = filtered[i];
                    final dynamicDist = _calculateDynamicDistance(
                      pro['lat'] as double? ?? 22.69,
                      pro['lng'] as double? ?? 88.46,
                    );

                    return Card(
                      color: const Color(0xFF181818),
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFFF9933).withOpacity(0.2),
                                  child: const Icon(Icons.person, color: Color(0xFFFF9933)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pro['name'] as String,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        '${pro['category']} • ${pro['subCategory']}',
                                        style: const TextStyle(color: Color(0xFFFF9933), fontSize: 11),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.near_me, size: 12, color: Colors.blueAccent),
                                          const SizedBox(width: 4),
                                          Text(
                                            dynamicDist,
                                            style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.star, size: 12, color: Colors.amber),
                                          const SizedBox(width: 2),
                                          Text(
                                            pro['rating'] as String,
                                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // ACTION BUTTONS: VIEW PROFILE + CALL NOW (BOTH OPEN, NO LOCK)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                    side: const BorderSide(color: Colors.white24),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    minimumSize: const Size(80, 32),
                                  ),
                                  onPressed: () => _openFullProfile(pro),
                                  icon: const Icon(Icons.visibility, size: 13),
                                  label: const Text('View Profile', style: TextStyle(fontSize: 11)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF138808),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    minimumSize: const Size(80, 32),
                                  ),
                                  onPressed: () => _callProfessional(pro),
                                  icon: const Icon(Icons.call, size: 13),
                                  label: const Text('Call Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
