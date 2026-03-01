import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes.dart';
import '../../kyc/view_model/kyc_view_model.dart';

class HomeView extends StatefulWidget {
  final Function(int) onSwitchTab;

  const HomeView({super.key, required this.onSwitchTab});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isBalanceVisible = true;
  final double _miningBalance = 1250000.00;
  final double _walletBalance = 4520.00; // Withdrawable

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),
          
          const SizedBox(height: 24),

          // Banner Ads Section
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage('https://placeholder.com/banner'), // Placeholder
                fit: BoxFit.cover,
              ),
              color: AppColors.darkGray,
            ),
             child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.luxuryGold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('PROMO', style: TextStyle(color: AppColors.matteBlack, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      const Text('Get 10% Extra on Standard Tier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Balance Card
          _buildBalanceCard(context),
          
          const SizedBox(height: 24),

          // Wallet Box (Withdrawable)
          _buildWalletBox(),

          const SizedBox(height: 24),
          
          // Action Buttons
          _buildActionButtons(context),

          const SizedBox(height: 24),
          
          // Bonus Sections
          Row(
            children: [
              Expanded(child: _buildBonusCard('Referral Bonus', '₹ 1,250', Icons.people_outline)),
              const SizedBox(width: 16),
              Expanded(child: _buildBonusCard('Daily ROI', '₹ 450', Icons.trending_up)),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recent Activity Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RECENT INTEREST CREDITED', style: AppTextStyles.bodySmall.copyWith(fontSize: 12, letterSpacing: 1.5, color: Colors.white54)),
              GestureDetector(
                onTap: () => widget.onSwitchTab(1), // Switch to Transactions Tab
                child: const Text('View All', style: TextStyle(color: AppColors.luxuryGold, fontSize: 12)),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Transactions List (Only Interest Credits)
          _buildTransactionItem('Daily Interest', 'Received', 'Today, 12:00 PM', '+ ₹ 6,250.00', true),
          _buildTransactionItem('Daily Interest', 'Received', 'Yesterday, 12:00 PM', '+ ₹ 6,120.00', true),
          _buildTransactionItem('Referral Bonus', 'Received', 'Yesterday, 10:30 AM', '+ ₹ 500.00', true),
          
          const SizedBox(height: 80), // Bottom padding for nav bar
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => widget.onSwitchTab(3), // Navigate to Profile Tab
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.luxuryGold, width: 1.5),
                ),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'), // Placeholder
                  backgroundColor: Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WELCOME BACK', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.0)),
                  Text('Hi, Abdul', style: AppTextStyles.headlineMedium.copyWith(fontSize: 20, color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => Navigator.pushNamed(context, Routes.notifications),
            icon: const Icon(Icons.notifications_none, color: AppColors.luxuryGold),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(10),
            iconSize: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF1A1A1D), // Dark Card Bg
        border: Border.all(color: Colors.white10),
        boxShadow: const [
           BoxShadow(
            color: Colors.black45,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
           // Background mesh/gradient (subtle)
           Positioned.fill(
             child: Container(
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(24),
                 gradient: LinearGradient(
                   begin: Alignment.topLeft,
                   end: Alignment.bottomRight,
                   colors: [
                     Colors.white.withOpacity(0.05),
                     Colors.transparent,
                   ],
                 ),
               ),
             ),
           ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MINING VAULT BALANCE',
                           style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.luxuryGold,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                         Text(
                          'Total Asset Value',
                           style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.luxuryGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _isBalanceVisible ? Icons.visibility : Icons.visibility_off, 
                          color: AppColors.luxuryGold, 
                          size: 20
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Text(
                  _isBalanceVisible ? '₹ 12,50,000.00' : '₹ ••••••••', 
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Today\'s Growth', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                             const Icon(Icons.trending_up, color: AppColors.successGreen, size: 16),
                             const SizedBox(width: 4),
                             Text(
                               '₹ 3,750.00 (0.3%)',
                               style: AppTextStyles.bodyMedium.copyWith(
                                 color: AppColors.successGreen,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.luxuryGold.withOpacity(0.15), AppColors.luxuryGold.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.luxuryGold.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('WALLET BALANCE', style: TextStyle(color: AppColors.luxuryGold, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                _isBalanceVisible ? '₹ 4,520.00' : '₹ ••••',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Available for Instant Withdraw', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // Instant Wallet Withdraw Flow
              Navigator.pushNamed(
                context, 
                Routes.withdrawal,
                arguments: {'type': 'wallet'},
              ); 
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.luxuryGold,
              foregroundColor: AppColors.matteBlack,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              minimumSize: const Size(0, 40),
            ),
            child: const Text('Withdraw', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Watch KYC ViewModel
    final kycViewModel = context.watch<KycViewModel>();
    
    return Row(
      children: [
        // Deposit Fund (Add Money)
        Expanded(
          child: _buildActionButton(
            label: 'Deposit Funds',
            icon: Icons.add_circle_outline,
            color: AppColors.luxuryGold,
            textColor: AppColors.matteBlack,
            onTap: () {
               if (kycViewModel.kycStatus != 'approved') {
                  _showKycDialog(context, kycViewModel.kycStatus);
              } else {
                 Navigator.pushNamed(context, Routes.depositAmount);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        // Deposit Withdraw (Request to Admin)
        Expanded(
          child: _buildActionButton(
            label: 'Withdraw Capital',
            icon: Icons.logout,
            color: AppColors.darkGray,
            textColor: AppColors.luxuryGold,
            borderColor: AppColors.luxuryGold,
            onTap: () {
               if (kycViewModel.kycStatus != 'approved') {
                  _showKycDialog(context, kycViewModel.kycStatus);
              } else {
                 // Navigate to withdrawal page with type 'Deposit'
                 Navigator.pushNamed(
                   context, 
                   Routes.withdrawal, 
                   arguments: {'type': 'deposit'}
                 );
              }
            },
          ),
        ),
      ],
    );
  }

  void _showKycDialog(BuildContext context, String status) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: const Text('KYC Required', style: TextStyle(color: AppColors.luxuryGold)),
        content: Text(
          status == 'pending' 
          ? 'Your KYC is currently under review. Please wait for approval.'
          : 'You need to complete KYC verification to perform this action.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          if (status != 'pending')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.kycVerification);
              },
              child: const Text('Verify Now', style: TextStyle(color: AppColors.luxuryGold)),
            ),
        ],
      )
    );
  }
  
  Widget _buildBonusCard(String title, String amount, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(amount, style: const TextStyle(color: AppColors.luxuryGold, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label, 
    required IconData icon, 
    required Color color, 
    required Color textColor, 
    Color? borderColor,
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String title, String status, String subtitle, String amount, bool isSuccess, {bool isNegative = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.luxuryGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.token, // Hexagon/Token icon style
              color: AppColors.luxuryGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: Colors.white38)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(color: AppColors.luxuryGold, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
