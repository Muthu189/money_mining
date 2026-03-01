import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../routes.dart';

class DepositSuccessPage extends StatelessWidget {
  const DepositSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.successGreen.withOpacity(0.1),
                   border: Border.all(color: AppColors.successGreen, width: 2),
                ),
                child: const Icon(Icons.check, size: 60, color: AppColors.successGreen),
              ),
              const SizedBox(height: 24),
              const Text(
                'Deposit Successful',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Your funds have been added to your vault wallet manually.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildRow('Transaction ID', '#TRX889230'),
                    const Divider(color: Colors.white12),
                    _buildRow('Amount', '₹ 500.00'),
                    const Divider(color: Colors.white12),
                    _buildRow('Date', 'Jan 28, 2026'),
                  ],
                ),
              ),
              const Spacer(),
              GradientButton(
                text: 'BACK TO DASHBOARD',
                onPressed: () {
                   Navigator.pushNamedAndRemoveUntil(context, Routes.dashboard, (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
          Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
