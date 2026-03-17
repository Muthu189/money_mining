import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../view_model/auth_view_model.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _otpSent = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.dangerRed : AppColors.successGreen,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MONEYMINING', style: TextStyle(color: AppColors.luxuryGold, fontSize: 14, letterSpacing: 1.5)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                _otpSent ? 'Reset Password' : 'Forgot Password?',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                _otpSent
                    ? 'Enter the OTP sent to your email along with your new password.'
                    : 'Enter the email address associated with your MoneyMining account and we\'ll send an OTP to reset your password.',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54, height: 1.5),
              ),
              const SizedBox(height: 48),

              // EMAIL FIELD (always visible)
              const Text('EMAIL ADDRESS', style: AppTextStyles.bodySmall),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _emailController,
                labelText: '',
                hintText: 'e.g. investor@moneymining.com',
                readOnly: _otpSent,
                suffixIcon: const Icon(Icons.email, color: AppColors.luxuryGold),
              ),

              if (_otpSent) ...[
                const SizedBox(height: 24),
                const Text('OTP', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _otpController,
                  labelText: '',
                  hintText: 'Enter OTP',
                  keyboardType: TextInputType.number,
                  suffixIcon: const Icon(Icons.lock_clock, color: AppColors.luxuryGold),
                ),

                const SizedBox(height: 24),
                const Text('NEW PASSWORD', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _newPasswordController,
                  labelText: '',
                  hintText: 'Enter new password',
                  obscureText: _obscureNew,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: AppColors.luxuryGold),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),

                const SizedBox(height: 24),
                const Text('CONFIRM PASSWORD', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: '',
                  hintText: 'Confirm new password',
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: AppColors.luxuryGold),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              GradientButton(
                text: _otpSent ? 'RESET PASSWORD' : 'SEND OTP',
                isLoading: authVM.isLoading,
                onPressed: authVM.isLoading
                    ? null
                    : () async {
                        if (!_otpSent) {
                          // Step 1: Send OTP
                          final email = _emailController.text.trim();
                          if (email.isEmpty) {
                            _showSnack('Please enter your email address', isError: true);
                            return;
                          }
                          final success = await authVM.sendForgotPasswordOtp(email);
                          if (success) {
                            setState(() => _otpSent = true);
                            _showSnack(authVM.successMessage ?? 'OTP sent to email');
                          } else {
                            _showSnack(authVM.error ?? 'Failed to send OTP', isError: true);
                          }
                        } else {
                          // Step 2: Verify OTP + Reset Password
                          final otp = _otpController.text.trim();
                          final newPass = _newPasswordController.text.trim();
                          final confirmPass = _confirmPasswordController.text.trim();

                          if (otp.isEmpty) {
                            _showSnack('Please enter the OTP', isError: true);
                            return;
                          }
                          if (newPass.isEmpty) {
                            _showSnack('Please enter new password', isError: true);
                            return;
                          }
                          if (newPass != confirmPass) {
                            _showSnack('Passwords do not match', isError: true);
                            return;
                          }

                          final success = await authVM.verifyAndResetPassword(
                            email: _emailController.text.trim(),
                            otp: otp,
                            newPassword: newPass,
                            confirmPassword: confirmPass,
                          );
                          if (success) {
                            _showSnack(authVM.successMessage ?? 'Password updated successfully');
                            if (mounted) Navigator.pop(context);
                          } else {
                            _showSnack(authVM.error ?? 'Failed to reset password', isError: true);
                          }
                        }
                      },
              ),

              if (_otpSent) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: authVM.isLoading
                        ? null
                        : () async {
                            final success = await authVM.sendForgotPasswordOtp(_emailController.text.trim());
                            if (success) {
                              _showSnack('OTP resent to email');
                            } else {
                              _showSnack(authVM.error ?? 'Failed to resend', isError: true);
                            }
                          },
                    child: Text('Resend OTP', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.luxuryGold)),
                  ),
                ),
              ],

              const SizedBox(height: 32),
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
