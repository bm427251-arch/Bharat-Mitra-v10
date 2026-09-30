import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/payment_service.dart';

class RazorpayConnectScreen extends StatefulWidget {
  const RazorpayConnectScreen({super.key});

  @override
  State<RazorpayConnectScreen> createState() => _RazorpayConnectScreenState();
}

class _RazorpayConnectScreenState extends State<RazorpayConnectScreen> {
  bool _isComponentMounted = false;
  bool _showDeveloperSettings = false;

  final TextEditingController _optKeyIdCtrl = TextEditingController();
  final TextEditingController _optKeySecretCtrl = TextEditingController();

  static const String officialLink = 'https://razorpay.me/@bharatmitrainfotech';
  static const String merchantName = 'Bharat Mitra Infotech';
  static const String upiId = 'bharatmitra@razorpay';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isComponentMounted = true);
      }
    });
  }

  @override
  void dispose() {
    _optKeyIdCtrl.dispose();
    _optKeySecretCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isComponentMounted) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: const Text('Razorpay Payment Settings'),
          backgroundColor: Colors.black,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF9933)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          'Razorpay Payment Settings',
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
            // AUTO CONNECTED VERIFIED BADGE
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF138808).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF138808)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF138808), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Auto Connected - All customer collections go directly here [Verified ✅]',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // HARDCODED VERIFIED AUTO - READONLY GREEN BOX
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF122415),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF138808), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF138808).withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified, color: Color(0xFF138808), size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Razorpay.me Link: [Verified ✅]',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: SelectableText(
                            officialLink,
                            style: TextStyle(
                              color: Color(0xFF138808),
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Color(0xFFFF9933), size: 18),
                          tooltip: 'Copy Link',
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: officialLink));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFF138808),
                                content: Text('Copied: $officialLink'),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_new, color: Colors.blueAccent, size: 18),
                          tooltip: 'Open in Browser',
                          onPressed: () async {
                            await PaymentService.openRazorpayPayment();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 8),

                  // AUTO BUSINESS DETAILS
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Merchant Business Name:',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        merchantName,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Settlement UPI ID:',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        upiId,
                        style: TextStyle(color: Color(0xFFFF9933), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // DIRECT PAY NOW TEST BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF138808),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await PaymentService.openRazorpayPayment();
                },
                icon: const Icon(Icons.payment, size: 18),
                label: const Text(
                  'Test Pay via Official Link (razorpay.me/@bharatmitrainfotech)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // OPTIONAL DEVELOPER API SETTINGS (HIDDEN BY DEFAULT)
            GestureDetector(
              onTap: () {
                setState(() => _showDeveloperSettings = !_showDeveloperSettings);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Advanced Developer API Keys (Optional)',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    Icon(
                      _showDeveloperSettings ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white60,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            if (_showDeveloperSettings) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Razorpay Key ID (Optional)',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _optKeyIdCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'rzp_live_... (Optional)',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Razorpay Key Secret (Optional)',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _optKeySecretCtrl,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Key Secret (Optional)',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
