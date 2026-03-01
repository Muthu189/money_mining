import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Faster load
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );
    
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _controller.forward().whenComplete(() async {
      final storageService = context.read<StorageService>();
      final isOnboardingComplete = await storageService.isOnboardingComplete();
      final isLoggedIn = await storageService.isLoggedIn();

      if (mounted) {
        if (isLoggedIn) {
          Navigator.pushReplacementNamed(context, Routes.dashboard);
        } else if (isOnboardingComplete) {
          Navigator.pushReplacementNamed(context, Routes.auth);
        } else {
          Navigator.pushReplacementNamed(context, Routes.onboarding);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Logo Section (Gears)
            ScaleTransition(
              scale: _logoScaleAnimation,
              child: FadeTransition(
                opacity: _logoFadeAnimation,
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Title
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.luxuryGold, AppColors.goldHighlight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'MoneyMining',
                style: AppTextStyles.displayLarge,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'GROW YOUR MONEY DAILY',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.luxuryGold,
                letterSpacing: 2.0,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            // Secure Auth Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SECURE AUTHENTICATION',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.white54,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _controller,
                         builder: (context, child) {
                          return Text(
                            '${(_controller.value * 100).toInt()}%',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 10,
                              color: AppColors.luxuryGold,
                            ),
                          );
                        }
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: AppColors.darkGray,
                        color: AppColors.luxuryGold,
                        minHeight: 2,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 12, color: Colors.white38),
                const SizedBox(width: 8),
                Text(
                  'ENCRYPTED & SECURE INVESTMENT PLATFORM',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 10,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'v2.4.0 • Enterprise Grade',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 10,
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
