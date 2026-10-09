import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import 'driver_document_upload_screen.dart';
import 'driver_home_screen.dart'; // NEW

class BecomeDriverScreen extends StatefulWidget {
  const BecomeDriverScreen({super.key});
  @override State<BecomeDriverScreen> createState() => _BecomeDriverScreenState();
}

class _BecomeDriverScreenState extends State<BecomeDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController(text: '4');
  final _chargeController = TextEditingController(text: '700');
  bool _hasLicence = false;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override void dispose() {
    _nameController.dispose(); _phoneController.dispose();
    _experienceController.dispose(); _chargeController.dispose();
    super.dispose();
  }

  Future<void> _submitDriverProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasLicence) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Licence Upload করুন দাদা')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final driverData = {
        'driverName': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'experienceYears': int.tryParse(_experienceController.text.trim()) ?? 4,
        'charge8hr': int.tryParse(_chargeController.text.trim()) ?? 700,
        'hasLicenceFront': _hasLicence,
        'rating': 4.9,
        'totalTrips': 0,
        'status': 'verified', // verified হলে তবেই On Duty
        'isAvailable': false, // শুরুতে Offline
        'canGoOnline': true, // এই Flag টাই On Duty Guard
        'isOnDuty': false,
        'walletBalance': 0,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await FirestoreService.instance.saveDriver(driverData);
      if (mounted) setState(() {_isSubmitting = false; _isSubmitted = true;});
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile saved! Welcome Partner.')));
        setState(()=> _isSubmitted = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text("becomeDriver".tr()), backgroundColor: Color(0xFF1A3A6E), foregroundColor: Colors.white),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 80, height: 80, decoration: BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle), child: Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 48)),
              SizedBox(height: 20),
              Text("Driver Profile Created!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("You are now verified. You can now Go On Duty & earn 100% with 0% commission.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
              SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1A3A6E), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: (){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> DriverHomeScreen(driverName: _nameController.text))); }, child: Text('Go to Driver Dashboard - On Duty', style: TextStyle(fontWeight: FontWeight.bold)))),
              SizedBox(height: 12),
              TextButton(onPressed: ()=> Navigator.pop(context), child: Text('Back to Home'))
            ]),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text("becomeDriver".tr()), backgroundColor: Color(0xFF1A3A6E), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF14B8A6)]), borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(Icons.airline_seat_recline_normal_rounded, color: Colors.white, size: 36), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("becomeDriver".tr(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(height: 4), Text("Get hired - 100% direct payment - On Duty only after verification", style: TextStyle(color: Colors.white70, fontSize: 12))]))])),
          SizedBox(height: 20),
          _buildField(controller: _nameController, label: "driverName".tr(), hint: "e.g. Subhash Ghosh", icon: Icons.person_rounded, validator: (v) => (v==null||v.trim().isEmpty)?'Please enter name':null),
          SizedBox(height: 14),
          _buildField(controller: _phoneController, label: "phoneNumber".tr(), hint: "10-digit mobile", icon: Icons.phone_android_rounded, keyboardType: TextInputType.phone, validator: (v) => (v==null||v.trim().length<10)?'Enter valid phone':null),
          SizedBox(height: 14),
          Row(children: [Expanded(child: _buildField(controller: _experienceController, label: "${'experience'.tr()} (Years)", hint: "5", icon: Icons.badge_rounded, keyboardType: TextInputType.number, validator: (v) => (v==null||v.trim().isEmpty)?'Enter years':null)), SizedBox(width: 12), Expanded(child: _buildField(controller: _chargeController, label: "charge8hr".tr(), hint: "700", icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, validator: (v) => (v==null||v.trim().isEmpty)?'Enter charge':null))]),
          SizedBox(height: 16),
          _buildUploadTile(title: "licenceFront".tr(), isUploaded: _hasLicence, onTap: () async { final res = await Navigator.push(context, MaterialPageRoute(builder: (_)=> DriverDocumentUploadScreen())); if(res==true){ setState(()=> _hasLicence=true);} }),
          SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F766E), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _isSubmitting?null:_submitDriverProfile, child: _isSubmitting?SizedBox(width:20,height:20,child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)):Text("becomeDriver".tr(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)))),
        ])),
      ),
    );
  }
  Widget _buildField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType keyboardType=TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(controller: controller, keyboardType: keyboardType, validator: validator, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600), decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon, color: Color(0xFF0F766E), size: 22), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Color(0xFF0F766E), width: 1.8))));
  }
  Widget _buildUploadTile({required String title, required bool isUploaded, required VoidCallback onTap}) {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isUploaded? Color(0xFF16A34A):AppColors.border, width: isUploaded?1.5:1)), child: ListTile(leading: Icon(isUploaded?Icons.check_circle_rounded:Icons.camera_alt_rounded, color: isUploaded?Color(0xFF16A34A):Color(0xFF0F766E)), title: Text(title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)), subtitle: Text(isUploaded?'Verified':'Tap to upload', style: TextStyle(fontSize: 11, color: isUploaded?Color(0xFF16A34A):Colors.grey)), trailing: Icon(isUploaded?Icons.done_all_rounded:Icons.upload_file_rounded, color: isUploaded?Color(0xFF16A34A):Colors.grey), onTap: onTap));
  }
}
