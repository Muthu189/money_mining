import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_mining/features/profile/data/user_model.dart';
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
  bool _isVaultBalanceVisible = true;
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();
  bool _isPinPromptShowing = false;

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
      context.read<TransactionViewModel>().loadInitialData(4);
      context.read<KycViewModel>().fetchKycStatus();
    });
  }

  void _checkAndPromptPin(ProfileViewModel model) {
    final user = model.user;
    if (user != null && (user.loginPinStatus == 0 || user.loginPin == null)) {
      if (!_isPinPromptShowing) {
        _isPinPromptShowing = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSetupPinDialog(model);
        });
      }
    }
  }

  Future<void> _showSetupPinDialog(ProfileViewModel model) async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        String? localError;
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async => false, // Disable physical back button
              child: AlertDialog(
                backgroundColor: AppColors.darkGray,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text(
                  'Set Security PIN',
                  style: TextStyle(
                    color: AppColors.luxuryGold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'To secure your account, please set a 4-digit PIN. You will need to enter this PIN every time you open the app.',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(letterSpacing: 12),
                      decoration: InputDecoration(
                        labelText: 'New 4-Digit PIN',
                        labelStyle: const TextStyle(color: Colors.white54, letterSpacing: 0),
                        hintText: '••••',
                        hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 12),
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.matteBlack,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.luxuryGold),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.luxuryGold, width: 2),
                        ),
                      ),
                      onChanged: (_) {
                        if (localError != null) {
                          setState(() => localError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(letterSpacing: 12),
                      decoration: InputDecoration(
                        labelText: 'Confirm PIN',
                        labelStyle: const TextStyle(color: Colors.white54, letterSpacing: 0),
                        hintText: '••••',
                        hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 12),
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.matteBlack,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.luxuryGold),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.luxuryGold, width: 2),
                        ),
                      ),
                      onChanged: (_) {
                        if (localError != null) {
                          setState(() => localError = null);
                        }
                      },
                    ),
                    if (localError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        localError!,
                        style: const TextStyle(color: AppColors.dangerRed, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
                actions: [
                  isSaving
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(color: AppColors.luxuryGold),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final pin = pinController.text.trim();
                              final confirmPin = confirmController.text.trim();

                              if (pin.length != 4 || confirmPin.length != 4) {
                                setState(() => localError = 'Please enter a 4-digit PIN.');
                                return;
                              }

                              if (pin != confirmPin) {
                                setState(() => localError = 'PINs do not match.');
                                return;
                              }

                              setState(() {
                                isSaving = true;
                                localError = null;
                              });

                              final success = await model.enablePin(pin);

                              if (success) {
                                if (mounted) {
                                  Navigator.pop(dialogCtx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(model.successMessage ?? 'PIN set successfully!'),
                                      backgroundColor: AppColors.successGreen,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                                _isPinPromptShowing = false;
                              } else {
                                setState(() {
                                  isSaving = false;
                                  localError = model.error ?? 'Failed to set PIN. Please try again.';
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.luxuryGold,
                              foregroundColor: AppColors.matteBlack,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Confirm & Save PIN', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
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

        _checkAndPromptPin(model);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
              child: _buildHeader(context, user),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.luxuryGold,
                onRefresh: () async {
                  await Future.wait([
                    context.read<ProfileViewModel>().fetchUserInfo(),
                    context.read<TransactionViewModel>().loadInitialData(3),
                    context.read<TransactionViewModel>().loadInitialData(4),
                    context.read<KycViewModel>().fetchKycStatus(),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

              Column(
                children: [
                  CarouselSlider(
                    carouselController: _controller,
                    options: CarouselOptions(
                      height: 160,
                      viewportFraction: 0.93,
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
                            margin: const EdgeInsets.symmetric(horizontal: 1.0),
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

                _buildWalletBox(context, user.mainWallet),

              const SizedBox(height: 24),

              _buildBalanceCard(context, user.wallet, user.todayRoi),



              const SizedBox(height: 24),


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
                  final roiState = txModel.getCategoryState(3);
                  final referState = txModel.getCategoryState(4);
                  
                  final isLoading = roiState.isLoading || referState.isLoading;
                  
                  // Combine transactions from Daily ROI (category 3) and Referral Bonus (category 4)
                  final allTransactions = [
                    ...roiState.transactions,
                    ...referState.transactions,
                  ];
                  
                  // Sort by date descending
                  allTransactions.sort((a, b) {
                    try {
                      final dateA = DateTime.parse(a.date);
                      final dateB = DateTime.parse(b.date);
                      return dateB.compareTo(dateA);
                    } catch (_) {
                      return 0;
                    }
                  });
                  
                  if (isLoading && allTransactions.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(color: AppColors.luxuryGold),
                      ),
                    );
                  }

                  if (allTransactions.isEmpty) {
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

                  final count = allTransactions.length > 3 ? 3 : allTransactions.length;
                  return Column(
                    children: allTransactions.take(count).map((tx) {
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
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
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
                child: CircleAvatar(
                  radius: 20,
                    child: ClipOval(
                      child: (user.profileImg != null && user.profileImg!.isNotEmpty)
                          ?  Image.network(
                        user.profileImg!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/logo_new.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.luxuryGold,
                            ),
                          );
                        },
                      )
                          :  Image.asset(
                        'assets/images/logo_new.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WELCOME BACK',
                      style:
                      TextStyle(color: Colors.white54, fontSize: 10)),
                  Text('Hi, ${user.username[0].toUpperCase()}${user.username.substring(1)}',
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
                    Text('WALLET BALANCE',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.luxuryGold,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Available for Instant Withdraw',
                        style: TextStyle(color: Colors.white38, fontSize: 10)),
                    // Text('Total Asset Value',
                    //     style: AppTextStyles.bodyMedium
                    //         .copyWith(color: Colors.white54)),
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

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
      child: Column(
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

                ],
              ),
              InkWell(
                onTap: () => setState(() => _isVaultBalanceVisible = !_isVaultBalanceVisible),
                child: Icon(
                  _isVaultBalanceVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: AppColors.luxuryGold,
                  // size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    _isVaultBalanceVisible
                        ? '₹ ${wallet.toStringAsFixed(2)}'
                        : '₹ ••••',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),

                ],
              ),



            ],
          ),
          SizedBox(height: 14,),
          _buildActionButtons(context),

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
              label: 'Move Wallet',
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
                Text(_formatDate(subtitle, true),
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

String _formatDate(String isoDate, [bool dateOnly = false]) {
  try {
    final date = DateTime.parse(isoDate).toLocal();
    if (dateOnly) {
      return DateFormat('MMM dd, yyyy').format(date);
    }
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