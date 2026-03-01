import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_back_ios, size: 20)),
               const Spacer(),
               const Text('SUPPORT', style: AppTextStyles.titleMedium),
               const Spacer(),
               const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 24),
          const Text('How can we help?', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Access our premium concierge services',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 32),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildSupportCard(Icons.chat_bubble, 'Live Chat', 'Instant Response'),
              _buildSupportCard(Icons.phone, 'Priority Call', '24/7 Dedicated Line'),
              _buildSupportCard(Icons.email, 'Email', 'Official Support'),
            ],
          ),
          
          const SizedBox(height: 32),
          const Text('Frequently Asked Questions', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 16),
          

          _buildAccordionFaq(context, 'How do I withdraw my earnings?', 'Withdrawals can be made via "Wallet Withdraw" for instant interest withdrawals or "Deposit Withdraw" for capital. Requests are processed within 24 hours.'),
          _buildAccordionFaq(context, 'What is the minimum deposit amount?', 'The minimum deposit to start mining is ₹1,000. Higher tiers offer better ROI rates.'),
          _buildAccordionFaq(context, 'Is my capital safe?', 'Yes, MoneyMining uses enterprise-grade encryption and stores assets in secured cold wallets.'),
          _buildAccordionFaq(context, 'How does the referral program work?', 'Share your invite code with friends. You earn 5% of their initial deposit instantly upon their successful KYC verification.'),
          _buildAccordionFaq(context, 'What are the KYC requirements?', 'You need a valid PAN Card, Aadhaar Card, and Bank Account details linked to your identity.'),
          _buildAccordionFaq(context, 'How long do deposits take?', 'Deposits via UPI/Razorpay are usually instant. Bank transfers may take up to 2-4 hours to reflect in your vault.'),
          
          const SizedBox(height: 32),
          Center(
            child: Text(
              'We\'re here to help you 24/7',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.luxuryGold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.luxuryGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.luxuryGold, size: 24),
          ),
          const Spacer(),
          Text(title, style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.luxuryGold)),
        ],
      ),
    );
  }

  Widget _buildAccordionFaq(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // Remove default divider
        child: ExpansionTile(
          title: Text(question, style: AppTextStyles.bodyLarge.copyWith(fontSize: 14)),
          iconColor: AppColors.luxuryGold,
          collapsedIconColor: Colors.white54,
          childrenPadding: const EdgeInsets.only(bottom: 16),
          children: [
            Text(
              answer,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54, height: 1.5, fontSize: 13),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
