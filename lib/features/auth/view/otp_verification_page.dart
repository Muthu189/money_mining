import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../routes.dart';
import '../view_model/auth_view_model.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const int otpLength = 6;

  final List<TextEditingController> _controllers =
  List.generate(otpLength, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
  List.generate(otpLength, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto submit when last digit entered
    if (index == otpLength - 1 && value.isNotEmpty) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length != otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
        ),
      );
      return;
    }

    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.verifyOtp(otp);

    if (!mounted) return;

    if (success) {
      if (viewModel.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.dashboard,
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.error ?? 'Verification failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 43,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      // decoration: BoxDecoration(
      //   color: AppColors.darkGray,
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(color: AppColors.luxuryGold),
      // ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) => _onOtpChanged(value, index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('VERIFY OTP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            Text(
              'Enter Verification Code',
              style: AppTextStyles.headlineMedium
                  .copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              'We sent a 6-digit code to your email/phone.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.white54),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                otpLength,
                    (index) => _buildOtpBox(index),
              ),
            ),

            const SizedBox(height: 40),

            if (viewModel.isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.luxuryGold,
                ),
              )
            else
              GradientButton(
                text: 'VERIFY & PROCEED',
                onPressed: _verifyOtp,
              ),
          ],
        ),
      ),
    );
  }
}