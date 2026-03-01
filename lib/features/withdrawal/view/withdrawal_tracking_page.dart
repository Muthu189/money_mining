import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';

class WithdrawalTrackingPage extends StatelessWidget {
  const WithdrawalTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawal Tracking'),
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
              Text('Transaction ID: #MM-90214-XW', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
              const SizedBox(height: 24),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.darkGray,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AMOUNT TO WITHDRAW', style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('₹ 25,000.00', style: AppTextStyles.displayLarge),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.luxuryGold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('MAX', style: AppTextStyles.bodySmall.copyWith(color: AppColors.luxuryGold, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Available: ₹ 124,500.00', style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
                        Row(
                          children: [
                             const Icon(Icons.account_balance, size: 16, color: Colors.white54),
                             const SizedBox(width: 8),
                             Text('Chase **** 1234', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Timeline', style: AppTextStyles.headlineMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('IN PROGRESS', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildTimelineItem(
                isLast: false,
                isCompleted: true,
                title: 'Withdrawal Requested',
                subtitle: 'Your request for ₹ 25,000.00 has been received and is waiting for internal review.',
                date: 'Oct 24, 2023 • 09:41 AM',
              ),
              _buildTimelineItem(
                isLast: false,
                isCompleted: true,
                title: 'Admin Approved',
                subtitle: 'Compliance team has verified your request and destination account.',
                date: 'Oct 24, 2023 • 02:15 PM',
              ),
              _buildTimelineItem(
                isLast: false,
                isCompleted: false,
                isCurrent: true,
                title: 'Processing Funds',
                subtitle: 'Funds are being transferred to your linked bank account. This usually takes 1-3 business days.',
                date: 'Expected by Oct 26, 2023',
                dateColor: AppColors.luxuryGold,
              ),
              _buildTimelineItem(
                isLast: true,
                isCompleted: false,
                title: 'Completed',
                subtitle: 'Funds successfully arrived in your account.',
                date: '',
              ),

              const SizedBox(height: 32),
              GradientButton(text: 'CONFIRM WITHDRAWAL', onPressed: (){}),
              const SizedBox(height: 16),
              const Center(
                child: Text('SECURELY PROCESSED BY MONEYMINING SYSTEMS', style: TextStyle(fontSize: 10, color: Colors.white24, letterSpacing: 1.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required bool isLast,
    required bool isCompleted,
    bool isCurrent = false,
    required String title,
    required String subtitle,
    required String date,
    Color? dateColor,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                 width: 24, height: 24,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: isCompleted ? AppColors.luxuryGold : (isCurrent ? Colors.transparent : Colors.grey.withValues(alpha: 0.2)),
                   border: isCurrent ? Border.all(color: AppColors.luxuryGold, width: 2) : null,
                 ),
                 child: isCompleted 
                   ? const Icon(Icons.check, size: 16, color: Colors.black)
                   : (isCurrent ? Container(margin: const EdgeInsets.all(6), decoration: const BoxDecoration(color: AppColors.luxuryGold, shape: BoxShape.circle)) : const Icon(Icons.wallet, size: 12, color: Colors.white24)),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? AppColors.luxuryGold : Colors.white10,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium.copyWith(color: isCompleted || isCurrent ? Colors.white : Colors.white24)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: isCompleted || isCurrent ? Colors.white70 : Colors.white24)),
                  if (date.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(date, style: AppTextStyles.bodySmall.copyWith(color: dateColor ?? (isCompleted ? AppColors.luxuryGold : Colors.white24))),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
