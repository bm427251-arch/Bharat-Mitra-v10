import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/payment_service.dart';

class RazorpayConnectScreen extends StatefulWidget {
  const RazorpayConnectScreen({super.key});

  @override
  State<RazorpayConnectScreen> createState() => _RazorpayConnectScreenState();
}

class _RazorpayConnectScreenState extends State<RazorpayConnectScreen> {
  // Safe mounted lifecycle flag
  bool _isComponentMounted = false;

  final TextEditingController _keyIdCtrl = TextEditingController();
  final TextEditingController _keySecretCtrl = TextEditingController();
  final TextEditingController _merchantNameCtrl = TextEditingController();
  final TextEditingController _upiIdCtrl = TextEditingController();

  String? _keyIdError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Do NOT access storage directly in render. Load safely in post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConfigSafely();
    });
  }

  @override
  void dispose() {
    _keyIdCtrl.dispose();
    _keySecretCtrl.dispose();
    _merchantNameCtrl.dispose();
    _upiIdCtrl.dispose();
    super.dispose();
  }

  // Safe getter for localStorage / SharedPreferences
  Future<void> _loadConfigSafely() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('razorpay_config');

      Map<String, dynamic> config = {};
      if (configJson != null && configJson.isNotEmpty) {
        try {
          config = jsonDecode(configJson) as Map<String, dynamic>;
        } catch (_) {}
      }

      final keyId = config['keyId']?.toString() ?? prefs.getString('razorpay_key_id') ?? '';
      final keySecret = config['keySecret']?.toString() ?? prefs.getString('razorpay_key_secret') ?? '';
      final merchant = config['merchantName']?.toString() ?? 'Bharat Mitra Infotech';
      final upi = config['upiId']?.toString() ?? 'bharatmitra@razorpay';

      if (mounted) {
        setState(() {
          _keyIdCtrl.text = keyId;
          _keySecretCtrl.text = keySecret;
          _merchantNameCtrl.text = merchant;
          _upiIdCtrl.text = upi;
          _isComponentMounted = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _merchantNameCtrl.text = 'Bharat Mitra Infotech';
          _upiIdCtrl.text = 'bharatmitra@razorpay';
          _isComponentMounted = true;
        });
      }
    }
  }

  void _validateKeyId(String val) {
    final trimmed = val.trim();
    if (trimmed.isNotEmpty &&
        !trimmed.startsWith('rzp_live_') &&
        !trimmed.startsWith('rzp_test_')) {
      setState(() {
        _keyIdError = 'Key ID must start with "rzp_live_" or "rzp_test_"';
      });
    } else {
      setState(() {
        _keyIdError = null;
      });
    }
  }

  Future<void> _handleSave() async {
    final keyId = _keyIdCtrl.text.trim();

    // Inline validation: do NOT throw exception
    if (keyId.isEmpty ||
        (!keyId.startsWith('rzp_live_') && !keyId.startsWith('rzp_test_'))) {
      setState(() {
        _keyIdError = 'Key ID must start with "rzp_live_" or "rzp_test_"';
      });
      return;
    }

    setState(() {
      _keyIdError = null;
      _isSaving = true;
    });

    try {
      final formData = {
        'keyId': keyId,
        'keySecret': _keySecretCtrl.text.trim(),
        'merchantName': _merchantNameCtrl.text.trim(),
        'upiId': _upiIdCtrl.text.trim(),
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('razorpay_config', jsonEncode(formData));
      await prefs.setString('razorpay_key_id', keyId);
      await prefs.setString('razorpay_key_secret', _keySecretCtrl.text.trim());

      // Update static config in PaymentService without reload
      PaymentService.updateRazorpayConfig(
        keyId: keyId,
        merchantName: _merchantNameCtrl.text.trim(),
        upiId: _upiIdCtrl.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      // Show toast / snackbar without reloading page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF138808),
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Razorpay configuration saved safely!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Notice saving config: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If !mounted return loading skeleton - Prevents internal render error
    if (!_isComponentMounted) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: const Text('Razorpay Connect Setup'),
          backgroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 24, width: 180, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 16),
              Container(height: 52, width: double.infinity, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8))),
              const SizedBox(height: 16),
              Container(height: 52, width: double.infinity, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8))),
              const SizedBox(height: 24),
              Container(height: 48, width: 140, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8))),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          'Razorpay Connect Setup',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFO BANNER
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF9933).withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.payment, color: Color(0xFFFF9933), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Direct Gateway Configuration',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Configure your Razorpay Live or Test keys for instant ride and service collections.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // OFFICIAL VERIFIED LINK (READONLY)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF142416),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF138808)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified, color: Color(0xFF138808), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Razorpay.me Link: https://razorpay.me/@bharatmitrainfotech [Verified ✅]',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: SelectableText(
                            'https://razorpay.me/@bharatmitrainfotech',
                            style: TextStyle(
                              color: Color(0xFF138808),
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Color(0xFFFF9933), size: 16),
                          tooltip: 'Copy Official Link',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: 'https://razorpay.me/@bharatmitrainfotech'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFF138808),
                                content: Text('Copied: https://razorpay.me/@bharatmitrainfotech'),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_new, color: Colors.blueAccent, size: 16),
                          tooltip: 'Open in Browser',
                          onPressed: () async {
                            await PaymentService.openRazorpayPayment();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bharat Mitra Infotech verified link (Readonly). All customer collections go directly here.',
                    style: TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // FORM FIELDS
            const Text(
              'Razorpay Key ID *',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _keyIdCtrl,
              onChanged: _validateKeyId,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'rzp_live_... or rzp_test_...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF181818),
                prefixIcon: const Icon(Icons.vpn_key, color: Color(0xFFFF9933), size: 18),
                errorText: _keyIdError,
                errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF9933))),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Razorpay Key Secret *',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _keySecretCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter Razorpay Key Secret',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF181818),
                prefixIcon: const Icon(Icons.password, color: Colors.blueAccent, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF9933))),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Merchant Business Name',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _merchantNameCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Bharat Mitra Infotech',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF181818),
                prefixIcon: const Icon(Icons.store, color: Colors.green, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF9933))),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Settlement UPI ID',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _upiIdCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'bharatmitra@razorpay',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF181818),
                prefixIcon: const Icon(Icons.qr_code, color: Colors.purpleAccent, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF9933))),
              ),
            ),
            const SizedBox(height: 24),

            // SAVE BUTTON (Does not reload page, shows toast)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9933),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.save, size: 18),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save Razorpay Config',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
