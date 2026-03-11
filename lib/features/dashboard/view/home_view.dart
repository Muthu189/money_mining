import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../routes.dart';
import '../../kyc/view_model/kyc_view_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../view_model/transaction_view_model.dart';

class HomeView extends StatefulWidget {
  final Function(int) onSwitchTab;

  const HomeView({super.key, required this.onSwitchTab});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isBalanceVisible = true;
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  final List<String> _sliderImages = [
    'assets/images/slider1.jpeg',
    'assets/images/slider2.jpeg',
    'assets/images/slider3.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProfileViewModel>().fetchUserInfo();
      context.read<TransactionViewModel>().loadInitialData(3);
      context.read<KycViewModel>().fetchKycStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, model, child) {
        if (model.isLoading && model.user == null) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.luxuryGold));
        }

        final user = model.user;

        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, color: AppColors.luxuryGold, size: 64),
                const SizedBox(height: 24),
                const Text('Profile Unavailable', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 8),
                Text('Could not load your information at this time.',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: buildGradientButton(
                    text: 'Tap to Retry',
                    onPressed: () => model.fetchUserInfo(),
                    icon: Icons.refresh,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildHeader(context, user.username),

              const SizedBox(height: 24),

              Column(
                children: [
                  CarouselSlider(
                    carouselController: _controller,
                    options: CarouselOptions(
                      height: 160,
                      viewportFraction: 0.92,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      },
                    ),
                    items: _sliderImages.map((assetPath) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: AssetImage(assetPath),
                                fit: BoxFit.cover,
                              ),
                              color: AppColors.darkGray,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _sliderImages.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => _controller.animateToPage(entry.key),
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.luxuryGold.withOpacity(
                              _current == entry.key ? 0.9 : 0.2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildBalanceCard(context, user.mainWallet, user.todayRoi),

              const SizedBox(height: 24),

              _buildWalletBox(context, user.wallet),

              const SizedBox(height: 24),

              _buildActionButtons(context),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _buildBonusCard(
                        'Referral Bonus',
                        '₹ ${user.totalRefRoi.toStringAsFixed(2)}',
                        Icons.people_outline,"0.10%"),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBonusCard(
                        'Daily ROI',
                        '₹ ${user.todayRoi.toStringAsFixed(2)}',
                        Icons.trending_up,"0.30%"),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('RECENT INTEREST CREDITED',
                      style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          letterSpacing: 1.5,
                          color: Colors.white54)),
                  GestureDetector(
                    onTap: () => widget.onSwitchTab(1),
                    child: const Text('View All',
                        style: TextStyle(
                            color: AppColors.luxuryGold, fontSize: 12)),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Consumer<TransactionViewModel>(
                builder: (context, txModel, child) {
                  final state = txModel.getCategoryState(3);
                  
                  if (state.isLoading && state.transactions.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(color: AppColors.luxuryGold),
                      ),
                    );
                  }

                  if (state.transactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'No recent interest credited yet',
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
                        ),
                      ),
                    );
                  }

                  // Take only the first 3 transactions for the home view
                  final count = state.transactions.length > 3 ? 3 : state.transactions.length;
                  return Column(
                    children: state.transactions.take(count).map((tx) {
                      return _buildTransactionItem(
                        tx.title,
                        tx.status,
                        tx.date,
                        '+ ₹ ${tx.amount.toStringAsFixed(2)}',
                        tx.status.toLowerCase() == 'success' || tx.status.toLowerCase() == 'approved',
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String username) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => widget.onSwitchTab(3),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                  Border.all(color: AppColors.luxuryGold, width: 1.5),
                ),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundImage:
                  NetworkImage('https://i.pravatar.cc/150?img=11'),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WELCOME BACK',
                      style:
                      TextStyle(color: Colors.white54, fontSize: 10)),
                  Text('Hi, ${username[0].toUpperCase()}${username.substring(1)}',
                      style: AppTextStyles.headlineMedium.copyWith(
                          fontSize: 20, color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () =>
              Navigator.pushNamed(context, Routes.notifications),
          icon: const Icon(Icons.notifications_none,
              color: AppColors.luxuryGold),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(
      BuildContext context, double balance, double todayRoi) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF1A1A1D),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
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
                    Text('MINING VAULT BALANCE',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.luxuryGold,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Total Asset Value',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.white54)),
                  ],
                ),
                InkWell(
                  onTap: () =>
                      setState(() => _isBalanceVisible = !_isBalanceVisible),
                  child: Icon(
                      _isBalanceVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.luxuryGold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              _isBalanceVisible
                  ? '₹ ${balance.toStringAsFixed(2)}'
                  : '₹ ••••••••',
              style: AppTextStyles.headlineLarge.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.trending_up,
                    color: AppColors.successGreen, size: 16),
                const SizedBox(width: 6),
                Text(
                  '₹ ${todayRoi.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletBox(BuildContext context, double wallet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.luxuryGold.withOpacity(0.15),
            AppColors.luxuryGold.withOpacity(0.05)
          ],
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
              const Text('WALLET BALANCE',
                  style: TextStyle(
                      color: AppColors.luxuryGold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                _isBalanceVisible
                    ? '₹ ${wallet.toStringAsFixed(2)}'
                    : '₹ ••••',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Available for Instant Withdraw',
                  style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.withdrawal,
                  arguments: {'type': 'wallet'});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.luxuryGold,
              foregroundColor: AppColors.matteBlack,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: const Text('Withdraw'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final kycViewModel = context.watch<KycViewModel>();

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
              label: 'Deposit Funds',
              icon: Icons.add_circle_outline,
              color: AppColors.luxuryGold,
              textColor: AppColors.matteBlack,
              onTap: () {
                if (kycViewModel.kycStatus?.toLowerCase() != 'approved') {
                  _showKycDialog(context, kycViewModel.kycStatus ?? 'Not Verified');
                } else {
                  Navigator.pushNamed(context, Routes.depositAmount);
                }
              }),
        ),
        const SizedBox(width: 12),
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
                  Navigator.pushNamed(context, Routes.withdrawal,
                      arguments: {'type': 'deposit'});
                }
              }),
        ),
      ],
    );
  }

  Widget _buildBonusCard(String title, String amount, IconData icon ,String rate) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white54, size: 20),

              Row(
                children: [
                  const Icon(Icons.trending_up,
                      color: AppColors.successGreen, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '$rate',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),

            ],
          ),
          const SizedBox(height: 12),
          Text(title,
              style:
              const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(amount,
              style: const TextStyle(
                  color: AppColors.luxuryGold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
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
    required VoidCallback onTap,
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
            Text(label,
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showKycDialog(BuildContext context, String status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: const Text('KYC Required',
            style: TextStyle(color: AppColors.luxuryGold)),
        content: const Text(
          'You need to complete KYC verification to perform this action.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.kycVerification);
            },
            child: const Text('Verify Now',
                style: TextStyle(color: AppColors.luxuryGold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String title, String status,
      String subtitle, String amount, bool isSuccess) {
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
            child: const Icon(Icons.token,
                color: AppColors.luxuryGold, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                Text(_formatDate(subtitle),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white38)),
              ],
            ),
          ),
          Text(amount,
              style: const TextStyle(
                  color: AppColors.luxuryGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ],
      ),
    );
  }
}

String _formatDate(String isoDate) {
  try {
    final date = DateTime.parse(isoDate).toLocal();
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  } catch (e) {
    return isoDate;
  }
}

Widget buildGradientButton(
    {required String text,
      required VoidCallback onPressed,
      required IconData icon}) {
  return GradientButton(text: text, onPressed: onPressed, icon: icon);
}