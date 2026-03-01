import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';

class ReferralPage extends StatelessWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer & Earn'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 3D Gift Png Placeholder
              Container(
                height: 250,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xFF2A2205), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                ),
                child: const Icon(Icons.card_giftcard, size: 120, color: AppColors.luxuryGold), // Placeholder
              ),
              
              const SizedBox(height: 24),
              const Text('Invite Friends,', style: AppTextStyles.headlineMedium),
              Text('Earn Rewards', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.luxuryGold, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'Share the wealth. For every friend who joins MoneyMining, you both receive exclusive gold bonuses.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54, height: 1.5),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Code Card
              Container(
                 margin: const EdgeInsets.symmetric(horizontal: 24),
                 padding: const EdgeInsets.all(24),
                 decoration: BoxDecoration(
                   color: AppColors.darkGray,
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: Colors.white10),
                 ),
                 child: Row(
                   children: [
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('YOUR UNIQUE CODE', style: AppTextStyles.bodySmall.copyWith(letterSpacing: 1.5)),
                           const SizedBox(height: 8),
                           Text('MINER777', style: AppTextStyles.displayLarge.copyWith(fontSize: 28, color: AppColors.luxuryGold)),
                           const SizedBox(height: 16),
                           GradientButton(text: 'Copy Code', onPressed: (){}, icon: Icons.copy, height: 40),
                         ],
                       ),
                     ),
                     const SizedBox(width: 24),
                     // QR Code Placeholder
                     Container(
                       width: 80, height: 80,
                       decoration: BoxDecoration(
                         border: Border.all(color: AppColors.luxuryGold.withValues(alpha: 0.3)),
                         borderRadius: BorderRadius.circular(8),
                         color: Colors.black,
                       ),
                       child: const Icon(Icons.qr_code_2, size: 50, color: AppColors.luxuryGold),
                     ),
                   ],
                 ),
              ),
              
              const SizedBox(height: 32),
              
              Text('QUICK SHARE', style: AppTextStyles.bodySmall.copyWith(letterSpacing: 1.5)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   _buildShareButton(Icons.send, 'Telegram'),
                   const SizedBox(width: 24),
                   _buildShareButton(Icons.chat_bubble, 'WhatsApp'),
                   const SizedBox(width: 24),
                   _buildShareButton(Icons.email, 'Email'),
                   const SizedBox(width: 24),
                   _buildShareButton(Icons.more_horiz, 'More'),
                ],
              ),
              
              const SizedBox(height: 32),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Friends Referred', style: AppTextStyles.titleMedium),
                     Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Text('12 Total', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildReferralItem('Julianne Deaton', 'Joined Nov 12, 2023', '+₹ 50 Gold', 'EARNED', true),
              _buildReferralItem('Trevor Beach', 'Joined Nov 08, 2023', 'Pending', 'PENDING', false),
              _buildReferralItem('Sarah Hughes', 'Joined Oct 28, 2023', '+₹ 50 Gold', 'EARNED', true),
              
              const SizedBox(height: 24),
              const Text('View All Activity', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildShareButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.luxuryGold.withOpacity(0.5)),
            color: Colors.black,
          ),
          child: Icon(icon, color: AppColors.luxuryGold, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildReferralItem(String name, String date, String status, String statusLabel, bool isEarned) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isEarned ? AppColors.luxuryGold : Colors.white10,
            backgroundImage: null, // Initials for now
            child: Text(name.substring(0, 2).toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                 const SizedBox(height: 4),
                 Text(date, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               Text(status, style: TextStyle(color: isEarned ? AppColors.luxuryGold : Colors.white54, fontWeight: FontWeight.bold)),
               const SizedBox(height: 4),
               Text(statusLabel, style: TextStyle(color: isEarned ? AppColors.successGreen : Colors.amber, fontSize: 8, fontWeight: FontWeight.bold)),
             ],
          )
        ],
      ),
    );
  }
}
