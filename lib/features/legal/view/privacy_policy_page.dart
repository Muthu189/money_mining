import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Privacy Policy', style: AppTextStyles.headlineMedium),
              Text('Effective Date: March 23, 2026', style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
              const SizedBox(height: 8),
              Container(height: 3, width: 40, color: AppColors.luxuryGold),
              const SizedBox(height: 24),
              
              _buildSection('1. Information Collection', 
                'We collect information you provide directly to us when you create an account, complete your KYC (Know Your Customer) verification, or communicate with us. This may include your name, email address, phone number, and official identification documents.'
              ),
              _buildSection('2. Use of Information', 
                'We use the information we collect to provide, maintain, and improve our services, including processing transactions, verifying your identity, and sending you technical notices and support messages.'
              ),
              _buildSection('3. Information Sharing', 
                'We do not share your personal information with third parties except as described in this policy, such as when required by law or to protect our rights.'
              ),
              _buildSection('4. Data Security', 
                'We implement enterprise-grade security measures to protect your personal information from unauthorized access, use, or disclosure.'
              ),
              _buildSection('5. Your Choices', 
                'You may update or correct your account information at any time by logging into your account or contacting our support team.'
              ),
              _buildSection('6. Contact Us', 
                'If you have any questions about this Privacy Policy, please contact us at support@moneymining.co.in.'
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.luxuryGold, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}
