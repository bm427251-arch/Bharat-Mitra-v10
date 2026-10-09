import 'package:flutter/material.dart';

class DualModeSwitchBar extends StatelessWidget {
  final bool isCustomerMode;
  final VoidCallback? onCustomerTap;
  final VoidCallback? onProviderTap;
  final Color primaryColor;

  const DualModeSwitchBar({
    super.key,
    this.isCustomerMode = true,
    this.onCustomerTap,
    this.onProviderTap,
    this.primaryColor = const Color(0xFF1A3A6E),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: isCustomerMode
                  ? ElevatedButton.icon(
                      icon: const Icon(Icons.person, size: 18),
                      label: const Text(
                        'I am Customer',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: onCustomerTap,
                    )
                  : OutlinedButton.icon(
                      icon: const Icon(Icons.person, size: 18),
                      label: const Text(
                        'I am Customer',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor, width: 1.5),
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: onCustomerTap ??
                          () => Navigator.pushReplacementNamed(context, '/home'),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: !isCustomerMode
                  ? ElevatedButton.icon(
                      icon: const Icon(Icons.handyman, size: 18),
                      label: const Text(
                        'I am Provider',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: onProviderTap,
                    )
                  : OutlinedButton.icon(
                      icon: const Icon(Icons.handyman, size: 18),
                      label: const Text(
                        'I am Provider',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor, width: 1.5),
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: onProviderTap,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
