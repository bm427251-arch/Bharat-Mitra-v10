import 'package:flutter/material.dart';

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
  final TextEditingController _passCtrl = TextEditingController();
  bool _obscureText = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (email == 'bm427251@gmail.com' && pass == 'Bharat@123') {
      Navigator.pop(context);
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        Navigator.pushNamed(context, '/admin');
      }
    } else {
      setState(() {
        _errorMessage = 'Invalid Credentials! Use bm427251@gmail.com / Bharat@123';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3A6E).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.admin_panel_settings, color: Color(0xFF1A3A6E)),
          ),
          const SizedBox(width: 12),
          const Text(
            'Admin Portal Login',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Authorized master administrator access only.',
            style: TextStyle(fontSize: 12.5, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Admin Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'Master Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() => _obscureText = !_obscureText);
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onSubmitted: (_) => _handleLogin(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A3A6E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          onPressed: _handleLogin,
          child: const Text('Login to Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
