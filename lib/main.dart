import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/admin_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hi'), Locale('bn')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const BharatMitraApp(),
    ),
  );
}

class BharatMitraApp extends StatelessWidget {
  const BharatMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bharat Mitra',
      theme: AppTheme.lightTheme,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/admin-login') {
          final args = settings.arguments as Map<String, dynamic>?;
          final email = args?['admin_email'] as String? ?? 'bm427251@gmail.com';
          return MaterialPageRoute(
            builder: (_) => AdminLoginScreen(adminEmail: email),
          );
        }
        return null;
      },
    );
  }
}
