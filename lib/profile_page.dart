import 'package:flutter/material.dart';
import 'screens/my_profiles_overview_screen.dart';

/// Profile Page Export & Wrapper
/// 
/// Central profile menu housing all services, account settings,
/// wallet, parcel service, and provider profile registration.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyProfilesOverviewScreen();
  }
}
