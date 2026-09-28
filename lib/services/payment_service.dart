import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static const String razorpayUrl = 'https://razorpay.me/@bharatmitrainfotech';

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
