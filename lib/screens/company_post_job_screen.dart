import 'package:flutter/material.dart';
import '../common_widgets.dart';
import '../models/job_model.dart';
import '../services/firestore_service.dart';
import '../services/alert_service.dart';

class CompanyPostJobScreen extends StatefulWidget {
  const CompanyPostJobScreen({super.key});

  @override
  State<CompanyPostJobScreen> createState() => _CompanyPostJobScreenState();
}

class _CompanyPostJobScreenState extends State<CompanyPostJobScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _customTitleController = TextEditingController();
  final TextEditingController _salaryController =
      TextEditingController(text: '₹18,000 - ₹24,000 / month');
  final TextEditingController _locationController =
      TextEditingController(text: 'Kolkata, West Bengal');
  final TextEditingController _contactPhoneController =
      TextEditingController();
  final TextEditingController _vacanciesController =
      TextEditingController(text: '2');
  final TextEditingController _descriptionController = TextEditingController(
      text: 'Immediate joining. Valid licence / experience required.');

  String _selectedJobTitle = 'Driver';
  String _selectedPayrollType = 'Company Payroll'; // 'Company Payroll' | 'Vendor Payroll' | 'Private'
  bool _isSubmitting = false;

  final List<String> _popularJobTitles = const [
    'Driver',
    'Plumber',
    'Sales',
    'Delivery Partner',
    'Electrician',
    'Carpenter',
    'Security Guard',
    'Mechanic',
    'Other',
  ];

  final List<String> _payrollTypes = const [
    'Company Payroll',
    'Vendor Payroll',
    'Private',
  ];

  // In-memory fallback sample jobs for instant display
  final List<JobModel> _sampleJobs = [
    JobModel(
      id: 'job_1',
      companyName: 'Apex City Logistics & Fleet',
      jobTitle: 'Commercial Driver',
      payrollType: 'Company Payroll',
      salary: '₹22,000 - ₹28,000 / month',
      location: 'Kolkata & Salt Lake',
      postedFree: true,
      contactPhone: '+91 98301 55667',
      description: 'Sedan & SUV city trips. Fuel and vehicle provided by company.',
      vacancies: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    JobModel(
      id: 'job_2',
      companyName: 'Metro Facility & Plumbing Services',
      jobTitle: 'Plumber',
      payrollType: 'Vendor Payroll',
      salary: '₹18,000 - ₹22,000 / month',
      location: 'Howrah & Newtown',
      postedFree: true,
      contactPhone: '+91 98302 77889',
      description: 'Residential maintenance, sanitary fittings. Tool allowance included.',
      vacancies: 3,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    JobModel(
      id: 'job_3',
      companyName: 'Bengal Retail & Distribution Hub',
      jobTitle: 'Sales Executive',
      payrollType: 'Company Payroll',
      salary: '₹20,000 + Incentives',
      location: 'Park Street & Central Kolkata',
      postedFree: true,
      contactPhone: '+91 98303 99001',
      description: 'B2B field sales, client relationship, local market outreach.',
      vacancies: 4,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    JobModel(
      id: 'job_4',
      companyName: 'Grand Royal Banquet & Tours',
      jobTitle: 'Private Chauffeur',
      payrollType: 'Private',
      salary: '₹25,000 / month',
      location: 'Alipore & Ballygunge',
      postedFree: true,
      contactPhone: '+91 98304 11223',
      description: 'VIP family chauffeur. 6 days a week, AC luxury car.',
      vacancies: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companyNameController.dispose();
    _customTitleController.dispose();
    _salaryController.dispose();
    _locationController.dispose();
    _contactPhoneController.dispose();
    _vacanciesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handlePostJob() async {
    if (!_formKey.currentState!.validate()) return;

    final company = _companyNameController.text.trim();
    final title = _selectedJobTitle == 'Other' &&
            _customTitleController.text.trim().isNotEmpty
        ? _customTitleController.text.trim()
        : _selectedJobTitle;
    final salary = _salaryController.text.trim();
    final location = _locationController.text.trim();
    final phone = _contactPhoneController.text.trim();
    final vacancies = int.tryParse(_vacanciesController.text.trim()) ?? 1;
    final desc = _descriptionController.text.trim();

    setState(() => _isSubmitting = true);

    final jobData = {
      'company_name': company,
      'job_title': title,
      'payroll_type': _selectedPayrollType,
      'salary': salary,
      'location': location,
      'posted_free': true,
      'contact_phone': phone,
      'vacancies': vacancies,
      'description': desc,
      'status': 'active',
    };

    try {
      await FirestoreService.instance.saveJob(jobData);
      await sendAlertToCandidates(title, _selectedPayrollType);

      // Also append to local sample list so user sees it instantly
      final newJob = JobModel(
        id: 'job_${DateTime.now().millisecondsSinceEpoch}',
        companyName: company,
        jobTitle: title,
        payrollType: _selectedPayrollType,
        salary: salary,
        location: location,
        postedFree: true,
        contactPhone: phone,
        vacancies: vacancies,
        description: desc,
        createdAt: DateTime.now(),
      );

      setState(() {
        _sampleJobs.insert(0, newJob);
        _isSubmitting = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF138808),
          content: Text(
            'Job for "$title" posted successfully for FREE! Visible to thousands of job seekers.',
          ),
        ),
      );

      // Clear form and switch to Explore Jobs tab
      _companyNameController.clear();
      _customTitleController.clear();
      _tabController.animateTo(1);
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Notice: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.business_center, color: Color(0xFFFF9933)),
            SizedBox(width: 8),
            Text(
              'Company Profile & Jobs',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF9933),
          indicatorWeight: 3,
          labelColor: const Color(0xFFFF9933),
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.add_circle_outline, size: 18), text: 'Post Job (FREE)'),
            Tab(icon: Icon(Icons.work_outline, size: 18), text: 'Explore Jobs'),
          ],
        ),
      ),
      body: Stack(
        children: [
          const CustomPaint(size: Size.infinite, painter: TricolorWatermarkPainter()),
          const BharatMitraWatermark(),
          TabBarView(
            controller: _tabController,
            children: [
              _buildPostJobTab(),
              _buildExploreJobsTab(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostJobTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FREE UNLIMITED BANNER
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B4D1B), Color(0xFF0D290D)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF138808)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: Color(0xFF4ADE80), size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '100% FREE & UNLIMITED JOB POSTING',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'No commission • No hidden charges • Hire Drivers, Plumbers, Sales staff directly',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Company Name
            _buildLabel('Company / Employer Name *'),
            TextFormField(
              controller: _companyNameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                hintText: 'e.g. Apex Fleet Solutions / Private Household',
                prefixIcon: Icons.apartment,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Company Name is required' : null,
            ),
            const SizedBox(height: 16),

            // Job Title Selector
            _buildLabel('Job Title (Driver, Plumber, Sales, etc.) *'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularJobTitles.map((title) {
                final isSel = _selectedJobTitle == title;
                return ChoiceChip(
                  label: Text(title),
                  selected: isSel,
                  selectedColor: const Color(0xFFFF9933),
                  backgroundColor: const Color(0xFF1E1E1E),
                  labelStyle: TextStyle(
                    color: isSel ? Colors.black : Colors.white,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSel ? const Color(0xFFFF9933) : Colors.white24,
                  ),
                  onSelected: (_) => setState(() => _selectedJobTitle = title),
                );
              }).toList(),
            ),

            if (_selectedJobTitle == 'Other') ...[
              const SizedBox(height: 10),
              TextFormField(
                controller: _customTitleController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  hintText: 'Specify custom job role',
                  prefixIcon: Icons.work,
                ),
                validator: (v) =>
                    _selectedJobTitle == 'Other' && (v == null || v.trim().isEmpty)
                        ? 'Please specify job title'
                        : null,
              ),
            ],
            const SizedBox(height: 16),

            // Payroll Type
            _buildLabel('Payroll Type *'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: _payrollTypes.map((type) {
                  final isSel = _selectedPayrollType == type;
                  return RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFFF9933),
                    title: Text(
                      type,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      type == 'Company Payroll'
                          ? 'Direct full-time company employee (PF / ESI eligible)'
                          : type == 'Vendor Payroll'
                              ? 'Contractual deployment via agency or vendor'
                              : 'Direct personal / household hire (Daily/Monthly)',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    value: type,
                    groupValue: _selectedPayrollType,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPayrollType = val);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Salary & Vacancies in Row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Salary / Pay *'),
                      TextFormField(
                        controller: _salaryController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          hintText: 'e.g. ₹20,000 / month',
                          prefixIcon: Icons.currency_rupee,
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Enter salary' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Vacancies'),
                      TextFormField(
                        controller: _vacanciesController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          hintText: 'e.g. 3',
                          prefixIcon: Icons.group,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location
            _buildLabel('Job Location *'),
            TextFormField(
              controller: _locationController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                hintText: 'e.g. Salt Lake Sector V, Kolkata',
                prefixIcon: Icons.location_on,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter location' : null,
            ),
            const SizedBox(height: 16),

            // Contact Phone / WhatsApp
            _buildLabel('Contact Phone / WhatsApp *'),
            TextFormField(
              controller: _contactPhoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                hintText: 'e.g. +91 98301 23456',
                prefixIcon: Icons.phone,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Contact phone is required'
                  : null,
            ),
            const SizedBox(height: 16),

            // Job Description / Requirements
            _buildLabel('Job Description / Eligibility'),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                hintText: 'Specify requirements (Licence type, experience, timings...)',
                prefixIcon: Icons.description,
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9933),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                onPressed: _isSubmitting ? null : _handlePostJob,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline, color: Colors.black),
                label: Text(
                  _isSubmitting ? 'Posting Job...' : '+ Publish Job for FREE',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreJobsTab() {
    return StreamBuilder<List<JobModel>>(
      stream: FirestoreService.instance.getJobsStream(),
      builder: (context, snapshot) {
        // Merge real-time firestore jobs with default sample jobs
        final firestoreJobs = snapshot.data ?? [];
        final allJobs = [
          ...firestoreJobs,
          ..._sampleJobs.where((s) => !firestoreJobs.any((f) => f.id == s.id)),
        ];

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF141414),
              child: Row(
                children: [
                  const Icon(Icons.work_history, color: Color(0xFFFF9933), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Active Opportunities (${allJobs.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF138808).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF138808)),
                    ),
                    child: const Text(
                      'Direct Hire • 0% Fee',
                      style: TextStyle(
                        color: Color(0xFF138808),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: allJobs.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (ctx, idx) {
                  final job = allJobs[idx];
                  return _buildJobCard(job);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJobCard(JobModel job) {
    Color payrollBadgeColor;
    if (job.payrollType == 'Company Payroll') {
      payrollBadgeColor = Colors.blue;
    } else if (job.payrollType == 'Vendor Payroll') {
      payrollBadgeColor = Colors.amber;
    } else {
      payrollBadgeColor = Colors.purple;
    }

    return Card(
      color: const Color(0xFF181818),
      elevation: 2,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFFF9933).withOpacity(0.18),
                  child: const Icon(Icons.work, color: Color(0xFFFF9933), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.jobTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.companyName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: payrollBadgeColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: payrollBadgeColor),
                  ),
                  child: Text(
                    job.payrollType,
                    style: TextStyle(
                      color: payrollBadgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 10),

            // Location & Salary
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.white54),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
                const Icon(Icons.currency_rupee, size: 14, color: Color(0xFFFF9933)),
                Text(
                  job.salary,
                  style: const TextStyle(
                    color: Color(0xFFFF9933),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            if (job.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                job.description,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${job.vacancies} ${job.vacancies == 1 ? "Vacancy" : "Vacancies"} • FREE Posted',
                    style: const TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                ),
                Row(
                  children: [
                    if (job.contactPhone.isNotEmpty)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.greenAccent,
                          side: const BorderSide(color: Colors.greenAccent),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: const Size(60, 32),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF138808),
                              content: Text('Calling employer ${job.companyName} at ${job.contactPhone}...'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.call, size: 14),
                        label: const Text('Call', style: TextStyle(fontSize: 11)),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9933),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: const Size(60, 32),
                      ),
                      onPressed: () async {
                        final companyId = job.companyId.isNotEmpty ? job.companyId : 'current_company_id';
                        await sendAlertToCompany(companyId, 'Rahul Sharma (Candidate)');
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF138808),
                            content: Text(
                              'Application submitted to ${job.companyName} for ${job.jobTitle}! Employer will reach out.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Apply Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFFFF9933), size: 20),
      filled: true,
      fillColor: const Color(0xFF161616),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF9933)),
      ),
    );
  }
}
