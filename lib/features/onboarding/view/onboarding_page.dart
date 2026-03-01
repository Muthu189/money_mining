import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Earn 0.3% Daily Bonus',
      'description': 'Start mining instantly and earn 0.3% daily on your invested balance.',
      'bg': 'assets/images/onboarding_bg_1.png', // Placeholder
    },
    {
      'title': 'Refer & Earn 0.1% Bonus',
      'description': 'Invite friends and earn extra 0.1% bonus on every referral.',
      'bg': 'assets/images/onboarding_bg_2.png',
    },
    {
      'title': 'Withdraw Unlimited Instantly',
      'description': 'Enjoy fast and unlimited withdrawals anytime.',
      'bg': 'assets/images/onboarding_bg_3.png',
    },
    {
      'title': '24/7 Premium Support',
      'description': 'Our expert team is available around the clock.',
      'bg': 'assets/images/onboarding_bg_4.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image / Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.matteBlack, 
              ),
              child: Container(
                // Overlay to darken background for text readability
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.matteBlack.withValues(alpha: 0.3),
                      AppColors.matteBlack.withValues(alpha: 0.8),
                      AppColors.matteBlack,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                   // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MONEYMINING',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.luxuryGold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, Routes.auth);
                        },
                        child: Text(
                          'SKIP',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _onboardingData.length,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Placeholder for specific themed image if we had them, 
                            // for now just using text and consistent styling.
                            // Ideally, we'd render the specific 'bg' image or an icon here.
                            Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                color: AppColors.luxuryGold.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getIconForPage(index),
                                size: 80,
                                color: AppColors.luxuryGold,
                              ),
                            ),
                            const SizedBox(height: 48),
                            Text(
                              _onboardingData[index]['title']!,
                              style: AppTextStyles.displayLarge.copyWith(fontSize: 32),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _onboardingData[index]['description']!,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_onboardingData.length, (index) {
                      final isActive = index == _currentPage; 
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.luxuryGold : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Next Button
                  GradientButton(
                    text: _currentPage == _onboardingData.length - 1 ? 'GET STARTED' : 'NEXT',
                    icon: Icons.arrow_forward,
                    onPressed: () {
                      if (_currentPage < _onboardingData.length - 1) {
                         _pageController.nextPage(
                           duration: const Duration(milliseconds: 300),
                           curve: Curves.easeInOut,
                         );
                      } else {
                        Navigator.pushReplacementNamed(context, Routes.auth);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForPage(int index) {
    switch (index) {
      case 0: return Icons.trending_up; // Earn
      case 1: return Icons.card_giftcard; // Refer
      case 2: return Icons.account_balance_wallet; // Withdraw
      case 3: return Icons.support_agent; // Support
      default: return Icons.star;
    }
  }
}
