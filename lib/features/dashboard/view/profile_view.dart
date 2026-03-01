import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../routes.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_back_ios, size: 20)),
              const Spacer(),
              const Text('PROFILE', style: AppTextStyles.titleMedium),
              const Spacer(),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 24),
          
          // Avatar with Edit
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.luxuryGold, width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.luxuryGold.withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                  backgroundColor: Colors.grey,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.luxuryGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.matteBlack, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Alexander Sterling', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user, color: AppColors.luxuryGold, size: 16),
              const SizedBox(width: 8),
              Text('VERIFIED INVESTOR', style: AppTextStyles.bodySmall.copyWith(color: AppColors.luxuryGold, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 16),
          
          // KYC Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.luxuryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.luxuryGold.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield, color: AppColors.luxuryGold, size: 16),
                const SizedBox(width: 8),
                Text('KYC VERIFIED', style: AppTextStyles.bodySmall.copyWith(color: AppColors.luxuryGold, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Align(alignment: Alignment.centerLeft, child: Text('PERSONAL INFORMATION', style: AppTextStyles.bodySmall.copyWith(color: AppColors.luxuryGold))),
          const SizedBox(height: 16),
          
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildListItem(Icons.email, 'EMAIL ADDRESS', 'a.sterling@moneymining.io'),
                const Divider(color: Colors.white12, height: 1),
                _buildListItem(Icons.phone_android, 'MOBILE NUMBER', '+1 (555) 888-0099'),
              ],
            ),
          ),
          
           const SizedBox(height: 32),
          
          Align(alignment: Alignment.centerLeft, child: Text('SECURITY & SETTINGS', style: AppTextStyles.bodySmall.copyWith(color: AppColors.luxuryGold))),
          const SizedBox(height: 16),
          
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Refer & Earn Dropdown
                _buildExpansionItem(
                  Icons.card_giftcard, 
                  'Refer & Earn', 
                  'Get Gold Bonuses',
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.qr_code_2, size: 150, color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      Text('Your Promo Code', style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.luxuryGold),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('GOLD2024', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.luxuryGold, fontSize: 18)),
                            const SizedBox(width: 16),
                            const Icon(Icons.copy, color: AppColors.luxuryGold, size: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: (){}, 
                            icon: const Icon(Icons.share, size: 16), 
                            label: const Text('Share Code'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.luxuryGold,
                              foregroundColor: AppColors.matteBlack,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  )
                ),
                
                const Divider(color: Colors.white12, height: 1),
                _buildListItem(Icons.history, 'Change Password', '', showArrow: true),
                const Divider(color: Colors.white12, height: 1),
                
                // Security Dropdown
                 _buildExpansionItem(
                  Icons.security, 
                  'Security & Biometrics', 
                  'FaceID, 2FA, PIN',
                  Column(
                    children: [
                      _buildToggleItem(Icons.fingerprint, 'Biometric Login', true),
                      _buildToggleItem(Icons.lock, 'Two-Factor Auth', false),
                      _buildToggleItem(Icons.dialpad, 'Transaction PIN', true),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: OutlinedButton(
                          onPressed: (){},
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.luxuryGold)),
                          child: const Text('Change Transaction PIN', style: TextStyle(color: AppColors.luxuryGold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  )
                ),
                
                const Divider(color: Colors.white12, height: 1),
                _buildListItem(Icons.privacy_tip, 'Privacy Policy', '', showArrow: true, onTap: () => Navigator.pushNamed(context, Routes.terms)),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Align(alignment: Alignment.centerLeft, child: Text('LOGIN ACTIVITY', style: AppTextStyles.bodySmall.copyWith(color: AppColors.luxuryGold))),
          const SizedBox(height: 16),
           Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.smartphone, color: Colors.white54),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('iPhone 14 Pro Max', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Today, 08:30 AM • Mumbai, IN', style: AppTextStyles.bodySmall.copyWith(color: Colors.white38)),
                  ],
                ),
                const Spacer(),
                const Text('Active', style: TextStyle(color: AppColors.successGreen, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          GradientButton(text: 'Logout from Account', onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, Routes.auth, (route) => false);
          }, icon: Icons.logout),
          
          const SizedBox(height: 16),
          
          OutlinedButton.icon(
             onPressed: (){}, 
             icon: const Icon(Icons.delete_forever, color: AppColors.dangerRed),
             label: const Text('Delete Account', style: TextStyle(color: AppColors.dangerRed)),
             style: OutlinedButton.styleFrom(
               side: const BorderSide(color: Colors.white12),
               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
               minimumSize: const Size(double.infinity, 50),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
             ),
          ),
          
          const SizedBox(height: 24),
          
          Text('MONEYMINING FINTECH V2.4.0', style: AppTextStyles.bodySmall.copyWith(color: Colors.white24)),
        ],
      ),
    );
  }

  Widget _buildExpansionItem(IconData icon, String title, String subtitle, Widget child) {
    return Theme(
      data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.luxuryGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.luxuryGold, size: 20),
        ),
        title: Text(title, style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: AppTextStyles.bodyMedium) : null,
        children: [child],
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, String subtitle, {bool showArrow = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // Hit test behavior
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.luxuryGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.luxuryGold, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: AppTextStyles.bodyMedium),
              ],
            ),
            const Spacer(),
            if (showArrow)
               const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, bool value) {
     return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.luxuryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.luxuryGold, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
          Switch(
            value: value, 
            onChanged: (v){},
            activeColor: AppColors.luxuryGold,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}
