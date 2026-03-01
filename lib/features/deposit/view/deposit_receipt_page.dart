import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DepositReceiptPage extends StatelessWidget {
  const DepositReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.share, size: 20)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Success Icon
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.luxuryGold.withOpacity(0.1),
                   border: Border.all(color: AppColors.luxuryGold.withOpacity(0.2)),
                ),
                child: const Icon(Icons.check_circle, size: 40, color: AppColors.luxuryGold),
              ),
              const SizedBox(height: 24),
              Text('DEPOSIT SUCCESSFUL', style: AppTextStyles.bodySmall.copyWith(letterSpacing: 2, color: Colors.white54)),
              const SizedBox(height: 8),
              Text(
                '+₹ 50,000.00',
                style: AppTextStyles.headlineLarge.copyWith(color: AppColors.successGreen),
              ),
              const SizedBox(height: 8),
              const Text(
                'Success',
                style: TextStyle(
                  color: AppColors.successGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Details
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkGray,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Transaction ID', '#TX982347102'),
                    _buildDetailRow('Date', 'Nov 14, 2023'),
                    _buildDetailRow('Time', '10:42 AM'),
                    _buildDetailRow('Payment Method', 'USDT (TRC20)'),
                    const Divider(color: Colors.white12, height: 32),
                    _buildDetailRow('Network Fee', '₹ 0.00'),
                    
                    _buildDetailRow('Status', 'Completed', valueColor: AppColors.luxuryGold, showDot: true),
                    _buildDetailRow('Date', 'Oct 24, 2023, 10:45 AM'),
                    _buildDetailRow('Payment Method', 'Razorpay', icon: Icons.wallet),
                    _buildDetailRow('Transaction ID', 'MM-9823471056'),
                    _buildDetailRow('Network Fee', '₹0.00'),
                  ],
                ),
              ),
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: (){}, 
                  icon: const Icon(Icons.download, color: AppColors.luxuryGold),
                  label: const Text('Download Receipt', style: TextStyle(color: AppColors.luxuryGold, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.luxuryGold),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              Text(
                'MoneyMining Inc. is a licensed digital asset provider. This receipt is automatically generated and serves as official proof of deposit.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white24, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool showDot = false, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
          Row(
            children: [
              if (showDot)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: valueColor, shape: BoxShape.circle),
                ),
              if (icon != null)
                 Padding(
                   padding: const EdgeInsets.only(right: 8),
                   child: Icon(icon, size: 16, color: Colors.white70),
                 ),
              Text(value, style: AppTextStyles.bodyMedium.copyWith(color: valueColor ?? Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
