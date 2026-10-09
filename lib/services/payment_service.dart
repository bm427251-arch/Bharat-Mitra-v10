import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  static String razorpayUrl = 'https://razorpay.me/@bharatmitrainfotech';
  static String activeKeyId = 'rzp_live_bharatmitra';
  static String activeUpiId = 'bharatmitra@razorpay';
  static String activeMerchantName = 'Bharat Mitra Infotech';

  static void updateRazorpayConfig({
    String? keyId,
    String? merchantName,
    String? upiId,
  }) {
    if (keyId != null && keyId.isNotEmpty) activeKeyId = keyId;
    if (merchantName != null && merchantName.isNotEmpty) activeMerchantName = merchantName;
    if (upiId != null && upiId.isNotEmpty) activeUpiId = upiId;
  }

  static Future<Map<String, String>> loadSafeRazorpayConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('razorpay_config');
      if (configJson != null && configJson.isNotEmpty) {
        final decoded = jsonDecode(configJson) as Map<String, dynamic>;
        updateRazorpayConfig(
          keyId: decoded['keyId']?.toString(),
          merchantName: decoded['merchantName']?.toString(),
          upiId: decoded['upiId']?.toString(),
        );
      }
    } catch (_) {}
    return {
      'keyId': activeKeyId,
      'upiId': activeUpiId,
      'merchantName': activeMerchantName,
    };
  }

  static Future<bool> openRazorpayPayment({int? amount}) async {
    try {
      final uri = Uri.parse(razorpayUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('Could not launch Razorpay URL: $razorpayUrl');
        return false;
      }
    } catch (e) {
      debugPrint('Error launching payment: $e');
      return false;
    }
  }
}

