import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'theme/app_theme.dart';
import 'bharat_mitra_home.dart';
import 'screens/home_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/become_driver_screen.dart';
import 'screens/become_sebak_screen.dart';
import 'screens/rent_drive_screen.dart';
import 'screens/driver_home_screen.dart';
import 'screens/sevak_home_screen.dart';
import 'screens/rent_owner_home_screen.dart';
import 'screens/owner_add_vehicle_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/my_trips_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/sebak_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/hire_driver_screen.dart';
import 'screens/become_rent_owner_screen.dart';
import 'screens/company_post_job_screen.dart';
import 'job_dashboard_page.dart';
import 'screens/splash_screen.dart';
import 'splash_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/parcel_screen.dart';
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
      supportedLocales: const [
        Locale('en'),
        Locale('bn'),
        Locale('hi'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bharat Mitra',
      theme: AppTheme.lightTheme,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const SplashScreen(),
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/home': (_) => const BharatMitraHome(),
        '/rent-drive': (_) => const RentDriveScreen(),
        '/driver-home': (_) => const DriverHomeScreen(),
        '/sevak-home': (_) => const SevakHomeScreen(),
        '/rent-owner-home': (_) => const RentOwnerHomeScreen(),
        '/owner-add-vehicle': (_) => const OwnerAddVehicleScreen(),
        '/my-trips': (_) => const MyTripsScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/wallet': (_) => const WalletScreen(),
        '/parcel': (_) => const ParcelScreen(),
        '/sebak-list': (_) => const SebakListScreen(),
        '/login': (_) => const LoginScreen(),
        '/hire-driver': (_) => const HireDriverScreen(),
        '/become-owner': (_) => const BecomeRentOwnerScreen(),
        '/post-job': (_) => const CompanyPostJobScreen(),
        '/job-dashboard': (_) => const JobDashboardPage(),
        '/admin': (_) => const AdminLoginScreen(adminEmail: 'bm427251@gmail.com'),
        '/admin-login': (_) => const AdminLoginScreen(adminEmail: 'bm427251@gmail.com'),
        '/tracking': (_) => const TrackingScreen(
          serviceType: 'book_ride',
          partnerId: 'd1',
          partnerName: 'Rajesh Das',
          partnerPhone: '+91 98301 23456',
          vehicleInfo: 'Bike • WB 02 BB 1024',
          pickupAddress: 'Howrah Station, Kolkata',
          dropAddress: 'Park Street, Kolkata',
          fare: 45.0,
        ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/admin' || settings.name == '/admin-login') {
          final args = settings.arguments as Map<String, dynamic>?;
          final email = args?['admin_email'] as String? ?? 'bm427251@gmail.com';
          return MaterialPageRoute(
            builder: (_) => AdminLoginScreen(adminEmail: email),
          );
        }
        if (settings.name == '/driver-register') {
          return MaterialPageRoute(
            builder: (_) => const BecomeDriverScreen(),
          );
        }
        if (settings.name == '/sevak-register') {
          return MaterialPageRoute(
            builder: (_) => const BecomeSebakScreen(),
          );
        }
        return null;
      },
    );
  }
}

typedef BharatMitraApp = MyApp;
