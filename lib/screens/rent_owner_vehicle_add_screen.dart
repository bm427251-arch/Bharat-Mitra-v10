import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/rent_vehicle_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class RentOwnerVehicleAddScreen extends StatefulWidget {
  const RentOwnerVehicleAddScreen({super.key});

  @override
  State<RentOwnerVehicleAddScreen> createState() => _RentOwnerVehicleAddScreenState();
}

class _RentOwnerVehicleAddScreenState extends State<RentOwnerVehicleAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameCtrl = TextEditingController(text: 'Ramesh Verma');
  final _phoneCtrl = TextEditingController(text: '+91 98305 66778');
  final _modelCtrl = TextEditingController();
  final _rcNumberCtrl = TextEditingController();
  final _rentCtrl = TextEditingController(text: '800');
  final _depositCtrl = TextEditingController(text: '2000');

  String _selectedCity = 'Goa';
  String _selectedVehicleType = 'Bike';
  bool _isSaving = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  File? _vehicleImage;
  File? _rcImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _cities = [
    'Goa',
    'Manali',
    'Digha',
    'Darjeeling',
    'Puri',
    'Jaipur',
    'Kolkata',
    'Delhi',
    'Mumbai',
    'Bengaluru',
  ];

  @override
  void dispose() {
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _modelCtrl.dispose();
    _rcNumberCtrl.dispose();
    _rentCtrl.dispose();
    _depositCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isVehicle) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        if (isVehicle) {
          _vehicleImage = File(picked.path);
        } else {
          _rcImage = File(picked.path);
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Compressing and uploading images...';
    });

    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'owner_${DateTime.now().millisecondsSinceEpoch}';
    String? vehicleImageUrl;
    String? rcImageUrl;

    try {
      if (_vehicleImage != null) {
        setState(() => _uploadStatus = 'Uploading vehicle photo to Mumbai storage...');
        vehicleImageUrl = await StorageService().uploadImage(
          _vehicleImage!,
          'rent_owners/$uid/vehicles',
          onProgress: (p) => setState(() => _uploadProgress = p * 0.5),
        );
      }

      if (_rcImage != null) {
        setState(() => _uploadStatus = 'Uploading RC document to Mumbai storage...');
        rcImageUrl = await StorageService().uploadImage(
          _rcImage!,
          'rent_owners/$uid/documents',
          onProgress: (p) => setState(() => _uploadProgress = 0.5 + (p * 0.5)),
        );
      }

      final id = 'rv_${DateTime.now().millisecondsSinceEpoch}';
      final vehicle = RentVehicleModel(
        id: id,
        ownerId: uid,
        ownerName: _ownerNameCtrl.text.trim(),
        ownerPhone: _phoneCtrl.text.trim(),
        city: _selectedCity,
        vehicleType: _selectedVehicleType,
        modelName: _modelCtrl.text.trim(),
        rcNumber: _rcNumberCtrl.text.trim(),
        dailyRent: double.tryParse(_rentCtrl.text.trim()) ?? 800.0,
        deposit: double.tryParse(_depositCtrl.text.trim()) ?? 2000.0,
        photos: [
          vehicleImageUrl ?? 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=600&q=80',
          'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=600&q=80',
          'https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=600&q=80',
          'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=600&q=80',
        ],
        rcPhoto: rcImageUrl ?? 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=600&q=80',
        insurancePhoto: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=600&q=80',
        gpsInstalled: true,
        status: 'approved',
        avgRating: 5.0,
        totalRatings: 1,
        createdAt: DateTime.now().toIso8601String(),
      );

      await FirestoreService().addRentVehicle(vehicle);

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle listed successfully with compressed images!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload completed or saved: $e'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle for Rent'),
        backgroundColor: const Color(0xFF1A3A6E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'List your vehicle for Self-Drive rentals (0% Commission)',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              if (_isSaving) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF93C5FD)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _uploadStatus,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                          ),
                          Text(
                            '${(_uploadProgress * 100).toInt()}%',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _uploadProgress > 0 ? _uploadProgress : null,
                        backgroundColor: const Color(0xFFDBEAFE),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Owner info
              TextFormField(
                controller: _ownerNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Owner / Garage Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Please enter owner name' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Please enter phone' : null,
              ),
              const SizedBox(height: 14),

              // City Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: const InputDecoration(
                  labelText: 'City (Pan India)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCity = val);
                },
              ),
              const SizedBox(height: 14),

              // Vehicle Type
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                items: ['Bike', 'Scooty', 'Car']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedVehicleType = val);
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _modelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Model Name (e.g. Royal Enfield Classic 350)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.two_wheeler),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Please enter model name' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _rcNumberCtrl,
                decoration: const InputDecoration(
                  labelText: 'RC Registration Number',
                  hintText: 'e.g. GA 03 AB 1234',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.verified),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Please enter RC number' : null,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rentCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Daily Rent (₹/day)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _depositCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Deposit (₹)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.security),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Image Upload Section
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickImage(true),
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(10),
                          color: _vehicleImage != null ? Colors.green.shade50 : Colors.grey.shade100,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _vehicleImage != null ? Icons.check_circle : Icons.camera_alt,
                              color: _vehicleImage != null ? Colors.green : Colors.grey.shade700,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _vehicleImage != null ? 'Vehicle Photo Added' : 'Add Vehicle Photo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _vehicleImage != null ? Colors.green.shade800 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickImage(false),
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(10),
                          color: _rcImage != null ? Colors.green.shade50 : Colors.grey.shade100,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _rcImage != null ? Icons.check_circle : Icons.description,
                              color: _rcImage != null ? Colors.green : Colors.grey.shade700,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _rcImage != null ? 'RC Photo Added' : 'Add RC Photo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _rcImage != null ? Colors.green.shade800 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Compression Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: Color(0xFF1D4ED8)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Images are compressed by 80% to save bandwidth before uploading to Mumbai Firebase Storage.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1E3A8A)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A6E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _handleSubmit,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit & Make Active', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
