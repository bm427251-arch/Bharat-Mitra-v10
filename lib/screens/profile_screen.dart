import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart' as ez;
import '../theme/app_theme.dart';
import '../l10n/app_translations.dart';
import '../models/sebak_model.dart';
import '../services/payment_service.dart';
import '../services/firestore_service.dart';
import '../widgets/admin_login_dialog.dart';
import 'become_driver_screen.dart';
import 'become_sebak_screen.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _activePlan = 'None (Free Rider)';
  bool _isPartnerActive = false;
  int _versionTapCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openPaymentAndVerify(SubscriptionPlan plan) async {
    await PaymentService.openRazorpayPayment(amount: plan.price);
    if (mounted) _showTransactionDialog(plan);
  }

  void _showTransactionDialog(SubscriptionPlan plan) {
    final txController = TextEditingController();
    bool isSaving = false;
    showDialog(context: context, barrierDismissible: false, builder: (dialogCtx) {
      return StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Activate ${plan.name}'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Plan: ${plan.name} (₹${plan.price} / ${plan.duration})', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            SizedBox(height: 12),
            TextField(controller: txController, decoration: InputDecoration(labelText: 'Transaction ID / UTR', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text('Cancel')),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (txController.text.trim().isEmpty) return;
                setDialogState(() => isSaving = true);
                await FirestoreService().recordSubscription(planId: plan.id, transactionId: txController.text.trim(), amount: plan.price, duration: plan.duration);
                if (mounted) {
                  setState(() { _activePlan = '${plan.name} (Active)'; _isPartnerActive = true; });
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${plan.name} Activated!'), backgroundColor: Colors.green));
                }
              },
              child: isSaving ? SizedBox(width:20,height:20,child: CircularProgressIndicator(strokeWidth:2)) : Text('Verify & Activate'),
            ),
          ],
        );
      });
    });
  }

  void _showLanguageSelector() {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (ctx) {
      return Container(padding: EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))), child: Column(mainAxisSize: MainAxisSize.min, children: [
        ...AppTranslations.supportedLanguages.map((lang) {
          final isSelected = AppTranslations.currentLanguage == lang.code;
          return ListTile(
            title: Text('${lang.name} (${lang.nativeName})', style: TextStyle(fontWeight: isSelected? FontWeight.bold: FontWeight.w500, color: isSelected? AppColors.primary: Colors.black)),
            trailing: isSelected? Icon(Icons.check_circle, color: AppColors.primary): null,
            onTap: () {
              AppTranslations.setLanguage(lang.code);
              try { ez.EasyLocalization.of(context)?.setLocale(Locale(lang.code)); } catch (_){}
              setState(() {}); Navigator.pop(ctx);
            },
          );
        }),
      ]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Profile & Membership'),
        automaticallyImplyLeading: false,
        actions: [IconButton(icon: Icon(Icons.language_rounded), onPressed: _showLanguageSelector)],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(icon: Icon(Icons.directions_car), text: 'Driver'),
            Tab(icon: Icon(Icons.handyman), text: 'Technician'),
            Tab(icon: Icon(Icons.workspace_premium), text: 'Pro'),
            Tab(icon: Icon(Icons.car_rental), text: 'Vehicle'),
            Tab(icon: Icon(Icons.work), text: 'Jobs'),
            Tab(icon: Icon(Icons.person_pin), text: 'My Profiles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. DRIVER TAB
          _buildTabContainer([
            _buildUserCard(),
            SizedBox(height: 16),
            InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BecomeDriverScreen())), child: Container(height: 120, padding: EdgeInsets.all(16), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 32), SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('Become a Driver', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), Text('Bike, Toto, Auto, Car - 0% Commission', style: TextStyle(color: Colors.white70, fontSize: 12))])]))),
            SizedBox(height: 16),
            Text('Driver Subscriptions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            ...SubscriptionPlan.plans.map((plan) => _buildPlanCard(plan)),
          ]),

          // 2. TECHNICIAN TAB
          _buildTabContainer([
            InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BecomeSebakScreen())), child: Container(height: 120, padding: EdgeInsets.all(16), decoration: BoxDecoration(gradient: AppColors.orangeGradient, borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(Icons.home_repair_service_rounded, color: Colors.white, size: 32), SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('Become Technician', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), Text('Electrician, Plumber, AC, Sevak', style: TextStyle(color: Colors.white70, fontSize: 12))])]))),
            SizedBox(height: 16),
            Text('Technician Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
            Card(child: ListTile(leading: Icon(Icons.work), title: Text('No active jobs'), subtitle: Text('Join as Sevak to get bookings'))),
          ]),

          // 3. PRO TAB
          _buildTabContainer([
            Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)), child: Column(children: [Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 40), SizedBox(height: 10), Text('Bharat Mitra Pro', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), Text('Get priority bookings & verified badge', style: TextStyle(color: Colors.white70)) ])),
            SizedBox(height: 16),
            Card(child: ListTile(title: Text('Pro Badge - ₹199 / month'), subtitle: Text('Top ranking + Verified tick'), trailing: ElevatedButton(onPressed: (){}, child: Text('Buy')))),
          ]),

          // 4. VEHICLE TAB
          _buildTabContainer([
            Card(child: ListTile(leading: Icon(Icons.two_wheeler), title: Text('My Bike - WB 02 BB 1024'), subtitle: Text('Active - Documents Verified'))),
            Card(child: ListTile(leading: Icon(Icons.directions_car), title: Text('Add New Vehicle'), trailing: Icon(Icons.add_circle, color: AppColors.primary), onTap: (){})),
            SizedBox(height: 10),
            ElevatedButton.icon(onPressed: (){}, icon: Icon(Icons.upload_file), label: Text('Upload RC, Insurance, PUC')),
          ]),

          // 5. JOBS TAB
          _buildTabContainer([
            Card(child: ListTile(title: Text('My Bookings'), subtitle: Text('12 Completed - ₹4,500 Earned'), leading: Icon(Icons.history, color: AppColors.primary))),
            Card(child: ListTile(title: Text('Pending Requests - 2'), subtitle: Text('Bike ride + Home service'), trailing: Icon(Icons.arrow_forward_ios, size: 16))),
            Card(child: ListTile(title: Text('Earnings Report'), subtitle: Text('This Month: ₹12,340'), trailing: Icon(Icons.bar_chart, color: Colors.green))),
          ]),

          // 6. MY PROFILES TAB
          _buildTabContainer([
            _buildUserCard(),
            SizedBox(height: 16),
            Card(child: ListTile(leading: CircleAvatar(child: Text('D')), title: Text('Driver Profile'), subtitle: Text('Active - 4.8 Rating'), trailing: Switch(value: _isPartnerActive, onChanged: (v){setState(()=>_isPartnerActive=v);}))),
            Card(child: ListTile(leading: CircleAvatar(child: Text('T')), title: Text('Technician Profile'), subtitle: Text('Electrician - Inactive'), trailing: Switch(value: false, onChanged: (v){}))),
            SizedBox(height: 16),
            ListTile(
              title: const Text('My Wallet'),
              subtitle: const Text('Balance, transaction history & recharge'),
              leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/wallet'),
            ),
            ListTile(
              title: const Text('Parcel Service'),
              subtitle: const Text('Doorstep parcel delivery & express courier'),
              leading: const Icon(Icons.local_shipping, color: Colors.orange),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/parcel'),
            ),
            ListTile(title: Text('Edit All Profiles'), leading: Icon(Icons.edit), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileEditScreen()))),
            ListTile(title: Text('Language'), subtitle: Text(AppTranslations.currentLanguage.toUpperCase()), leading: Icon(Icons.language), onTap: _showLanguageSelector),
            Center(child: GestureDetector(onTap: (){ _versionTapCount++; if(_versionTapCount>=5){_versionTapCount=0; AdminLoginDialog.show(context);}}, child: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Bharat Mitra v1.0.0 - 0% Commission - 5-Tap Admin', style: TextStyle(fontSize: 11, color: Colors.grey))))),
          ]),
        ],
      ),
    );
  }

  Widget _buildTabContainer(List<Widget> children) {
    return SingleChildScrollView(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));
  }

  Widget _buildUserCard() {
    return Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(24)), child: Row(children: [
      Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle), child: Center(child: Text('BM', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)))),
      SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Bharat Mitra User', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text('+91 98765 43210', style: TextStyle(color: Colors.white70, fontSize: 13)),
        SizedBox(height: 6),
        Row(children: [Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Text(_activePlan, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))])
      ])),
      IconButton(icon: Icon(Icons.edit_note_rounded, color: Colors.white, size: 26), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileEditScreen()))),
    ]));
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    return Container(margin: EdgeInsets.only(bottom: 14), padding: EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: plan.isPopular? AppColors.secondary: AppColors.border, width: plan.isPopular?2:1)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(plan.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), if(plan.isPopular) Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(gradient: AppColors.orangeGradient, borderRadius: BorderRadius.circular(10)), child: Text('POPULAR', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))]),
      SizedBox(height: 4),
      Text('₹${plan.price} / ${plan.duration}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
      SizedBox(height: 4),
      Text(plan.description, style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
      SizedBox(height: 12),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: plan.isPopular? AppColors.secondary: AppColors.primary, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () => _openPaymentAndVerify(plan), child: Text('Pay ₹${plan.price} via Razorpay ✅', style: TextStyle(fontWeight: FontWeight.bold))),
    ]));
  }
}
