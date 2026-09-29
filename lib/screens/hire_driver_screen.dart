import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';
import 'driver_list_screen.dart';
import 'become_driver_screen.dart';

class HireDriverScreen extends StatelessWidget {
  const HireDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text("hireDriver".tr()),
          backgroundColor: const Color(0xFF0F766E),
          foregroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Colors.amber,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "findDriver".tr()),
              Tab(text: "becomeDriver".tr()),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DriverListScreen(),
            BecomeDriverScreen(),
          ],
        ),
      ),
    );
  }
}
