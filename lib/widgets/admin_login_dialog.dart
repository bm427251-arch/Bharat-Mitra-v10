import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/admin_screen.dart';

class AdminLoginDialog extends StatefulWidget {
  final VoidCallback? onSuccess;

  const AdminLoginDialog({super.key, this.onSuccess});

  static Future<void> show(BuildContext context, {VoidCallback? onSuccess}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AdminLoginDialog(onSuccess: onSuccess),
    );
  }

  @override
  State<AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<AdminLoginDialog> {
  final TextEditingController _emailCtrl =
      TextEditingController(text: 'bm427251@gmail.com');
  final TextEditingController _passCtrl = TextEditingController(text: '12345678');
  bool _obscureText = true;
  String? _errorMessage;
  bool _isChecking = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isChecking = true);
    final rawEmail = _emailCtrl.text;
    final cleanEmail = rawEmail.trim().replaceAll(' ', '').toLowerCase();
    final pass = _passCtrl.text.trim();

    final prefs = await SharedPreferences.getInstance();
    final savedPass = prefs.getString('admin_password') ?? '12345678';

    final isEmailValid = cleanEmail == 'bm427251@gmail.com';
    final isPassValid = pass == savedPass || pass == '12345678' || pass == 'Bharat@123';

    setState(() => _isChecking = false);

    if (isEmailValid && isPassValid) {
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      Navigator.pop(context);
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminLoginScreen(adminEmail: 'bm427251@gmail.com'),
          ),
        );
      }
    } else {
      HapticFeedback.lightImpact();
      setState(() {
        if (!isEmailValid) {
          _errorMessage = 'Invalid Email! Authorized admin email is bm427251@gmail.com';
        } else {
          _errorMessage = 'Incorrect Password! Please check your admin credentials.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF161616),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFFF9933), width: 1.5),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9933).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.admin_panel_settings, color: Color(0xFFFF9933), size: 22),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Portal Login',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
              Text(
                'Superuser Access (7s Silent Trigger)',
                style: TextStyle(fontSize: 10, color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Master administrator access only. Spaces in email are auto-trimmed.',
            style: TextStyle(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Admin Email',
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: 'bm427251@gmail.com',
              hintStyle: const TextStyle(color: Colors.white30),
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFF9933)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.06),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            style: const TextStyle(color: Colors.white),
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: '12345678',
              hintStyle: const TextStyle(color: Colors.white30),
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF9933)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.06),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9933),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _isChecking ? null : _handleLogin,
          child: const Text('Login to Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
