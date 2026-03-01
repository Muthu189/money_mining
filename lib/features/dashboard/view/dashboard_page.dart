import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes.dart';
import 'home_view.dart';
import 'transactions_view.dart';
import 'support_view.dart';
import 'profile_view.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _views = [
    HomeView(onSwitchTab: _switchTab),
    const TransactionsView(),
    const SupportView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _views,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.luxuryGold, width: 0.2)),
          boxShadow: [
             BoxShadow(color: Colors.black, blurRadius: 20, offset: Offset(0, -5)),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 70,
            indicatorColor: AppColors.luxuryGold,
            backgroundColor: AppColors.matteBlack,
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
               if (states.contains(MaterialState.selected)) {
                 return AppTextStyles.bodyMedium.copyWith(
                   fontSize: 12,
                   color: AppColors.luxuryGold,
                   fontWeight: FontWeight.bold
                 );
               }
               return AppTextStyles.bodyMedium.copyWith(
                   fontSize: 12,
                   color: Colors.white38,
                 );
            }),
            iconTheme: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const IconThemeData(color: AppColors.matteBlack, size: 26);
              }
              return const IconThemeData(color: Colors.white54, size: 24);
            }),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: _buildGlowingIcon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: _buildGlowingIcon(Icons.receipt_long),
                label: 'Transactions',
              ),
              NavigationDestination(
                icon: const Icon(Icons.headset_mic_outlined),
                selectedIcon: _buildGlowingIcon(Icons.headset_mic),
                label: 'Support',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: _buildGlowingIcon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildGlowingIcon(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.luxuryGold.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.matteBlack, size: 26),
    );
  }
}
