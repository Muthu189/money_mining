import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MONEYMINING', style: TextStyle(color: AppColors.luxuryGold, fontSize: 14, letterSpacing: 1.5)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
             icon: const Icon(Icons.info_outline),
             onPressed: (){},
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text('Forgot Password?', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 16),
              Text(
                'Enter the email address associated with your MoneyMining account and we\'ll send a secure link to reset your password.',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54, height: 1.5),
              ),
              const SizedBox(height: 48),
              
              const Text('EMAIL ADDRESS', style: AppTextStyles.bodySmall),
              const SizedBox(height: 8),
              const CustomTextField(
                labelText: '',
                hintText: 'e.g. investor@moneymining.com',
                suffixIcon: Icon(Icons.email, color: AppColors.luxuryGold),
              ),
              
              const SizedBox(height: 32),
              
              GradientButton(
                text: 'SEND RESET LINK',
                onPressed: () {
                   // Navigate back or show snackbar
                   Navigator.pop(context);
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset link sent!')));
                },
              ),
              
              const Spacer(),
              
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Still having trouble? ', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
                    Text('Contact Support', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.luxuryGold, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
