import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: AppColors.matteBlack,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.luxuryGold.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.luxuryGold.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.luxuryGold.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.build_circle_outlined, size: 80, color: AppColors.luxuryGold),
                ),
                const SizedBox(height: 48),
                Text(
                  'Under Maintenance',
                  style: AppTextStyles.headlineMedium.copyWith(color: AppColors.luxuryGold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We are currently upgrading MoneyMining to serve you better. The app will be back online shortly.',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                CircularProgressIndicator(
                  color: AppColors.luxuryGold,
                  strokeWidth: 2,
                ),
                const SizedBox(height: 24),
                Text(
                  'Thank you for your patience.',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
