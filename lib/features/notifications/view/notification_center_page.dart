import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class NotificationCenterPage extends StatelessWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: (){}, 
            child: Text('Clear All', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.luxuryGold))
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // No image placeholder as per screenshot, using icon instead for "empty" state if needed, 
            // // but screenshot shows list so we implement list.
            // Center(
            //   child: Container(
            //     width: 100, height: 100,
            //     margin: const EdgeInsets.only(bottom: 32, top: 16),
            //     decoration: BoxDecoration(
            //       color: const Color(0xFF2A2A2A),
            //       borderRadius: BorderRadius.circular(16),
            //     ),
            //     child: const Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Icon(Icons.spa, size: 32, color: Colors.white54),
            //         SizedBox(height: 8),
            //         Text('LUXURY', style: TextStyle(fontSize: 10, color: Colors.white24)),
            //         Text('MONEYMINING', style: TextStyle(fontSize: 8, color: Colors.white24)),
            //       ],
            //     ),
            //   ),
            // ),
            
            Padding(
               padding: const EdgeInsets.only(bottom: 16),
               child: Text('RECENT ACTIVITY', style: AppTextStyles.bodySmall.copyWith(letterSpacing: 1.5)),
            ),
            
            _buildNotificationCard(
              icon: Icons.account_balance_wallet,
              title: 'Deposit Successful',
              timeColor: AppColors.luxuryGold,
              body: 'Your deposit of ₹ 12,500.00 has been processed and is now active in your Mining Vault.',
              time: '2 hours ago',
              isRead: false,
            ),
            
            _buildNotificationCard(
              icon: Icons.trending_up, 
              title: 'Interest Credited', 
              time: '2H AGO', 
              timeColor: AppColors.luxuryGold,
              body: 'Weekly earnings of ₹ 428.12 have been added to your balance. Watch your wealth grow.'
            ),
            
             _buildNotificationCard(
              icon: Icons.verified_user, 
              title: 'Identity Verified', 
              time: 'YESTERDAY', 
              timeColor: AppColors.luxuryGold,
              body: 'Your KYC documentation has been approved. You now have full access to premium investment tiers.'
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: AppColors.matteBlack,
      //   currentIndex: 2, // Highlight Activity/Bell
      //   selectedItemColor: AppColors.luxuryGold,
      //   unselectedItemColor: Colors.white54,
      //   type: BottomNavigationBarType.fixed,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Home'),
      //     BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Assets'),
      //     BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Activity'),
      //     BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      //   ],
      //    onTap: (index) {
      //     if (index != 2) Navigator.pop(context);
      //   },
      // ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon, 
    required String title, 
    required String time, 
    required String body,
    Color timeColor = Colors.white54,
    bool isRead = false,
    String? highlightText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRead ? Colors.white10 : AppColors.luxuryGold.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: isRead ? Colors.white24 : AppColors.luxuryGold, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 16)),
                    Text(time, style: TextStyle(color: timeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(color: isRead ? Colors.white24 : Colors.white70),
                    children: [
                      TextSpan(text: highlightText == null ? body : body.split(highlightText)[0]),
                      if (highlightText != null)
                        TextSpan(text: highlightText, style: const TextStyle(color: AppColors.luxuryGold, fontWeight: FontWeight.bold)),
                      if (highlightText != null && body.split(highlightText).length > 1)
                        TextSpan(text: body.split(highlightText)[1]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
