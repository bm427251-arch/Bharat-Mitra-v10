import 'package:flutter/material.dart';
import 'common_widgets.dart';
import 'screens/service_provider_profile_screen.dart';

class ProfessionalPage extends StatefulWidget {
  const ProfessionalPage({super.key});

  @override
  State<ProfessionalPage> createState() => _ProfessionalPageState();
}

class _ProfessionalPageState extends State<ProfessionalPage> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'All',
    'Advocate',
    'CA',
    'Doctor',
    'Beautician',
    'Cameraman',
    'Photographer',
  ];

  final List<Map<String, dynamic>> _professionals = const [
    {
      'name': 'Adv. Debasish Banerjee',
      'category': 'Advocate',
      'exp': 'High Court Advocate • 14 Yrs Exp',
      'plan': 'Business 999',
      'fee': '₹499 Consult',
      'rating': '4.9 ★ (184)',
      'phone': '+91 98321 00011',
    },
    {
      'name': 'Adv. Ritu Mukherjee',
      'category': 'Advocate',
      'exp': 'Civil & Corporate Law • 9 Yrs Exp',
      'plan': 'Pro 499',
      'fee': '₹399 Consult',
      'rating': '4.8 ★ (120)',
      'phone': '+91 98321 00012',
    },
    {
      'name': 'CA Meenakshi Sen',
      'category': 'CA',
      'exp': 'Chartered Accountant & GST • 8 Yrs Exp',
      'plan': 'Business 999',
      'fee': '₹499 ITR/GST',
      'rating': '4.9 ★ (210)',
      'phone': '+91 98321 00022',
    },
    {
      'name': 'CA Rajesh Agrawal',
      'category': 'CA',
      'exp': 'Tax Consultant & Audit • 12 Yrs Exp',
      'plan': 'Pro 499',
      'fee': '₹450 Consult',
      'rating': '4.7 ★ (98)',
      'phone': '+91 98321 00023',
    },
    {
      'name': 'Dr. Arindam Mukherjee, MD',
      'category': 'Doctor',
      'exp': 'General Physician & Telehealth • 11 Yrs Exp',
      'plan': 'Business 999',
      'fee': '₹350 Fee',
      'rating': '4.9 ★ (340)',
      'phone': '+91 98321 00033',
    },
    {
      'name': 'Dr. Sunita Ghosh, MBBS',
      'category': 'Doctor',
      'exp': 'Gynecologist & Health Clinic • 7 Yrs Exp',
      'plan': 'Pro 499',
      'fee': '₹400 Fee',
      'rating': '4.8 ★ (156)',
      'phone': '+91 98321 00034',
    },
    {
      'name': 'Pooja Glamour Salon & Spa',
      'category': 'Beautician',
      'exp': 'Bridal Makeup & Skin Care • 6 Yrs Exp',
      'plan': 'Pro 499',
      'fee': '₹699 Package',
      'rating': '4.9 ★ (175)',
      'phone': '+91 98321 00041',
    },
    {
      'name': 'Suman Video & Drone Media',
      'category': 'Cameraman',
      'exp': 'Event Video & 4K Drone Operator • 5 Yrs Exp',
      'plan': 'Business 999',
      'fee': '₹1,499/Shift',
      'rating': '4.8 ★ (89)',
      'phone': '+91 98321 00042',
    },
    {
      'name': 'Subrata Paul Photography',
      'category': 'Photographer',
      'exp': 'Cinematic Wedding & Portrait • 7 Yrs Exp',
      'plan': 'Business 999',
      'fee': '₹1,999/Event',
      'rating': '4.9 ★ (220)',
      'phone': '+91 98321 00044',
    },
    {
      'name': 'Ananya Creative Clicks',
      'category': 'Photographer',
      'exp': 'Fashion, Baby & Pre-wedding • 4 Yrs Exp',
      'plan': 'Pro 499',
      'fee': '₹1,299/Event',
      'rating': '4.7 ★ (64)',
      'phone': '+91 98321 00045',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = _professionals.where((p) {
      final matchesCat =
          _selectedCategory == 'All' || p['category'] == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          p['name'].toString().toLowerCase().contains(query) ||
          p['category'].toString().toLowerCase().contains(query) ||
          p['exp'].toString().toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Professionals - Search Must',
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
              // Search Field with mic suffix
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText:
                        'Search Advocate, CA, Doctor, Beautician, Cameraman, Photographer...',
                    hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFFF9933)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.mic, color: Color(0xFFFF9933)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF1E3A8A),
                            content: Text('Listening... Voice search active for professionals!'),
                          ),
                        );
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: _categories.map((e) {
                    final isSel = _selectedCategory == e;
                    return Padding(
                      padding: const EdgeInsets.all(4),
                      child: ChoiceChip(
                        label: Text(e),
                        selected: isSel,
                        selectedColor: const Color(0xFFFF9933),
                        backgroundColor: const Color(0xFF1C1C1C),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.black : Colors.white,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: isSel ? const Color(0xFFFF9933) : Colors.white24,
                        ),
                        onSelected: (_) => setState(() => _selectedCategory = e),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Subscription & Profile Creation
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    const Text(
                      'Subscription: Free 0 | Pro 499 | Business 999 - 0% Comm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFFFF9933),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9933),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ServiceProviderProfileScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        '+ Create Professional Profile',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // List of Professionals
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No professionals found for "$_selectedCategory"',
                          style: const TextStyle(color: Colors.white60),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemBuilder: (_, i) {
                          final pro = filtered[i];
                          return Card(
                            color: const Color(0xFF181818),
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.white12),
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFFF9933).withOpacity(0.18),
                                child: Text(
                                  pro['name'].toString().substring(0, 1),
                                  style: const TextStyle(
                                    color: Color(0xFFFF9933),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      pro['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF138808).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFF138808)),
                                    ),
                                    child: Text(
                                      pro['plan'],
                                      style: const TextStyle(
                                        color: Color(0xFF138808),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(
                                    pro['exp'],
                                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Verified | Subscription Active | Top Listing',
                                    style: TextStyle(
                                      color: Color(0xFFFF9933),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  minimumSize: const Size(60, 32),
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFF138808),
                                      content: Text(
                                        'Connecting with ${pro['name']} (${pro['phone']}) - 0% Commission direct!',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Contact',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
