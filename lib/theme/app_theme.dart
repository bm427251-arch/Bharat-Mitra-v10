import 'package:flutter/material.dart';

class AppColors {
  // Primary brand palette
  static const Color primary = Color(0xFF0B2E6E); // Deep Royal Blue
  static const Color primaryLight = Color(0xFF1E4BB8); // Royal Blue Accent
  static const Color secondary = Color(0xFFFF7A00); // Saffron Orange
  static const Color secondaryLight = Color(0xFFFF9E42);
  
  // Neutral backgrounds & surfaces
  static const Color background = Color(0xFFF5F7FF); // Soft premium white-blue
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEEF2FB);
  
  // Typography colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  
  // Functional colors
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color successBg = Color(0xFFE8FDF3);
  static const Color border = Color(0xFFE2E8F0);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient commissionBannerGradient = LinearGradient(
    colors: [Color(0xFFE6F9F0), Color(0xFFE8F1FD)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // Premium Card Box Decoration
  static BoxDecoration premiumCardDecoration({
    Color color = Colors.white,
    double radius = 20,
    bool isSelected = false,
  }) {
    if (isSelected) {
      return BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x400B2E6E),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      );
    }
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000), // 8% opacity black
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
      border: Border.all(
        color: AppColors.border.withOpacity(0.6),
        width: 1,
      ),
    );
  }

  // 56px Height Primary Action Button
  static Widget primaryGradientButton({
    required String text,
    required VoidCallback onPressed,
    Widget? icon,
    bool isLoading = false,
  }) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330B2E6E),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        icon,
                        const SizedBox(width: 10),
                      ],
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
