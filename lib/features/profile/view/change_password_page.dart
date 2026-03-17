import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../profile/view_model/profile_view_model.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
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
    final profileVM = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CHANGE PASSWORD'),
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
              const SizedBox(height: 16),

              // Header icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.luxuryGold.withOpacity(0.1),
                    border: Border.all(color: AppColors.luxuryGold.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.lock_outline, color: AppColors.luxuryGold, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Update Your Password',
                  style: AppTextStyles.headlineMedium,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Enter your current password and choose a new one.',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // Old Password
              const Text('CURRENT PASSWORD', style: AppTextStyles.bodySmall),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _oldPasswordController,
                labelText: '',
                hintText: 'Enter current password',
                obscureText: _obscureOld,
                suffixIcon: IconButton(
                  icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility, color: AppColors.luxuryGold),
                  onPressed: () => setState(() => _obscureOld = !_obscureOld),
                ),
              ),

              const SizedBox(height: 24),

              // New Password
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

              // Confirm Password
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

              const SizedBox(height: 40),

              GradientButton(
                text: 'UPDATE PASSWORD',
                isLoading: profileVM.isLoading,
                onPressed: profileVM.isLoading
                    ? null
                    : () async {
                        final oldPass = _oldPasswordController.text.trim();
                        final newPass = _newPasswordController.text.trim();
                        final confirmPass = _confirmPasswordController.text.trim();

                        if (oldPass.isEmpty) {
                          _showSnack('Please enter current password', isError: true);
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

                        final success = await profileVM.changePassword(
                          oldPassword: oldPass,
                          newPassword: newPass,
                          confirmPassword: confirmPass,
                        );

                        if (mounted) {
                          _showSnack(
                            success
                                ? (profileVM.successMessage ?? 'Password updated successfully')
                                : (profileVM.error ?? 'Failed to update password'),
                            isError: !success,
                          );
                          if (success) Navigator.pop(context);
                        }
                      },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
