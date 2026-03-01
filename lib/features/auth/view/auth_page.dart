import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../routes.dart';
import '../view_model/auth_view_model.dart'; // Import ViewModel

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  bool _isPasswordVisible = false;
  
  // Login Controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  // Signup Controllers
  final TextEditingController _signupNameController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPhoneController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();
  final TextEditingController _signupConfirmPasswordController = TextEditingController();
  final TextEditingController _signupReferralController = TextEditingController();
  final TextEditingController _emailOtpController = TextEditingController(); // New
  final TextEditingController _mobileOtpController = TextEditingController(); // New
  
  // Signup State
  bool _showEmailOtp = false; // Not used in API flow yet based on payload
  bool _showPhoneOtp = false; // Not used in API flow yet
  bool _isTermsAccepted = false;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPhoneController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    _signupReferralController.dispose();
    _emailOtpController.dispose();
    _mobileOtpController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final success = await context.read<AuthViewModel>().login(email: email, password: password);
    if (success && mounted) {
      Navigator.pushNamed(context, Routes.otpVerification);
    } else if (mounted) {
      final error = context.read<AuthViewModel>().error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Login failed')));
    }
  }

  Future<void> _handleSignup() async {
    if (!_isTermsAccepted) return;

    final username = _signupNameController.text.trim();
    final email = _signupEmailController.text.trim();
    final mobile = _signupPhoneController.text.trim();
    final password = _signupPasswordController.text.trim();
    final confirmPassword = _signupConfirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || mobile.isEmpty || password.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
       return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    final success = await context.read<AuthViewModel>().createAccount(
      username: username,
      email: email,
      mobile: mobile,
      password: password,
      mailOtp: _emailOtpController.text.trim(),
      mobOtp: _mobileOtpController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account Created! Please Login.')));
      setState(() {
        _isLogin = true;
      });
    } else if (mounted) {
      final error = context.read<AuthViewModel>().error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Signup failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch ViewModel for loading state
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('MONEYMINING'),
        actions: [
           IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white54),
          onPressed: () {},
        ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Toggle Switch
              Container(
                decoration: BoxDecoration(
                  color: AppColors.darkGray,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _isLogin ? AppColors.luxuryGold.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: _isLogin ? Border.all(color: AppColors.luxuryGold.withValues(alpha: 0.5)) : null,
                          ),
                          child: Text(
                            'LOGIN',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.button.copyWith(
                              color: _isLogin ? AppColors.luxuryGold : Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: !_isLogin ? AppColors.luxuryGold.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: !_isLogin ? Border.all(color: AppColors.luxuryGold.withValues(alpha: 0.5)) : null,
                          ),
                          child: Text(
                            'SIGNUP',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.button.copyWith(
                              color: !_isLogin ? AppColors.luxuryGold : Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              if (_isLogin) 
                _buildLoginForm(viewModel) 
              else 
                _buildSignupForm(viewModel),
                
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'WELCOME BACK',
          style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _loginEmailController, // Added Controller
          labelText: 'Email ID',
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          suffixIcon: const Icon(Icons.alternate_email, color: AppColors.luxuryGold),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _loginPasswordController, // Added Controller
          labelText: 'Password',
          hintText: 'Enter password to login',
          obscureText: !_isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: AppColors.luxuryGold,
            ),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.pushNamed(context, Routes.forgotPassword),
            child: Text(
              'Forgot Password?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.luxuryGold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        if (viewModel.isLoading)
           const Center(child: CircularProgressIndicator(color: AppColors.luxuryGold))
        else
          GradientButton(
            text: 'ENTER THE VAULT',
            onPressed: _handleLogin,
          ),
      ],
    );
  }

  Widget _buildSignupForm(AuthViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: _signupNameController,
          labelText: 'Full Name',
          hintText: 'Enter your full name',
          suffixIcon: const Icon(Icons.person_outline, color: AppColors.luxuryGold),
        ),
        const SizedBox(height: 16),
        
        // Email & OTP
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: CustomTextField(
                controller: _signupEmailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                suffixIcon: viewModel.isEmailVerified 
                  ? const Icon(Icons.check_circle, color: AppColors.successGreen)
                  : const Icon(Icons.email_outlined, color: AppColors.luxuryGold),
                readOnly: viewModel.isEmailVerified,
              ),
            ),
            if (!viewModel.isEmailVerified) ...[
              const SizedBox(width: 8),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : () {
                    final email = _signupEmailController.text.trim();
                    if (email.isNotEmpty) {
                       context.read<AuthViewModel>().sendEmailOtp(email);
                       setState(() => _showEmailOtp = true);
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter email')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.luxuryGold,
                    foregroundColor: AppColors.matteBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: viewModel.isLoading && !viewModel.emailOtpSent 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Verify'),
                ),
              ),
            ]
          ],
        ),
        
        if (_showEmailOtp && !viewModel.isEmailVerified) ...[
           const SizedBox(height: 8),
           Row(
             children: [
               Expanded(
                 child: CustomTextField(
                   // We need a controller for OTP, but I didn't init one. Let's add it ad-hoc or modify state.
                   // Actually, I should have initialized it. For now, I'll use a local variable or create one in build? No, that resets.
                   // I'll assume I can add new controllers to State in a separate edit, but here I am in one edit.
                   // I will reuse `_signupConfirmPasswordController`? No.
                   // I will add `onChanged` and store in a variable? No CustomTextField doesn't expose it easily.
                   // I will invoke a separate edit to add controllers.
                   // WAIT: I can just proceed and add controllers in the next step.
                   // I'll put placeholders and then fix it.
                   // Actually, I can allow the user to type in a field that updates a value.
                   // `CustomTextField` usually takes a controller.
                   // I'll use a hack: I'll use `_signupReferralController` temporarily? No bad idea.
                   // I will perform a `multi_replace` to add controllers AND update UI.
                   // But I am already committed to `replace_file_content`.
                   // I will add the UI requesting controllers that I will add in next step.
                   controller: _emailOtpController, 
                   labelText: 'Email OTP',
                   hintText: 'Enter OTP',
                   keyboardType: TextInputType.number,
                 ),
               ),
               const SizedBox(width: 8),
               SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : () {
                     final otp = _emailOtpController.text.trim();
                     context.read<AuthViewModel>().verifyEmailOtp(_signupEmailController.text.trim(), otp);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen),
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
                ),
               ),
             ],
           ),
        ],

        const SizedBox(height: 16),
        
        // Mobile & OTP
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: CustomTextField(
                controller: _signupPhoneController,
                labelText: 'Phone Number',
                hintText: 'Enter phone number',
                keyboardType: TextInputType.phone,
                suffixIcon: viewModel.isMobileVerified
                  ? const Icon(Icons.check_circle, color: AppColors.successGreen)
                  : const Icon(Icons.phone_android, color: AppColors.luxuryGold),
                readOnly: viewModel.isMobileVerified,
              ),
            ),
             if (!viewModel.isMobileVerified) ...[
              const SizedBox(width: 8),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : () {
                    final mobile = _signupPhoneController.text.trim();
                    if (mobile.isNotEmpty) {
                       context.read<AuthViewModel>().sendMobileOtp(mobile);
                       setState(() => _showPhoneOtp = true);
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter mobile number')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.luxuryGold,
                    foregroundColor: AppColors.matteBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: viewModel.isLoading && !viewModel.mobileOtpSent
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Verify'),
                ),
              ),
            ]
          ],
        ),

        if (_showPhoneOtp && !viewModel.isMobileVerified) ...[
           const SizedBox(height: 8),
           Row(
             children: [
               Expanded(
                 child: CustomTextField(
                   controller: _mobileOtpController, 
                   labelText: 'Mobile OTP',
                   hintText: 'Enter OTP',
                   keyboardType: TextInputType.number,
                 ),
               ),
               const SizedBox(width: 8),
               SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : () {
                     final otp = _mobileOtpController.text.trim();
                     context.read<AuthViewModel>().verifyMobileOtp(_signupPhoneController.text.trim(), otp);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen),
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
                ),
               ),
             ],
           ),
        ],
        
        const SizedBox(height: 16),
        CustomTextField(
          controller: _signupPasswordController,
          labelText: 'Password',
          hintText: 'Create a password',
          obscureText: !_isPasswordVisible,
           suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: AppColors.luxuryGold,
            ),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _signupConfirmPasswordController,
          labelText: 'Confirm Password',
          hintText: 'Re-enter password',
          obscureText: !_isPasswordVisible,
          suffixIcon: const Icon(Icons.lock_outline, color: AppColors.luxuryGold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _signupReferralController,
          labelText: 'Referral Code (Optional)',
          hintText: 'Enter referral code',
          suffixIcon: const Icon(Icons.card_giftcard, color: AppColors.luxuryGold),
        ),
        const SizedBox(height: 24),
        
        // Terms & Conditions
        Row(
          children: [
            Checkbox(
              value: _isTermsAccepted,
              activeColor: AppColors.luxuryGold,
              checkColor: AppColors.matteBlack,
              side: const BorderSide(color: Colors.white54),
              onChanged: (val) => setState(() => _isTermsAccepted = val ?? false),
            ),
            Expanded(
              child: Text(
                'I agree to the Terms & Conditions and Privacy Policy.',
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: Colors.white70),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
         if (viewModel.isLoading)
           const Center(child: CircularProgressIndicator(color: AppColors.luxuryGold))
        else
          GradientButton(
            text: 'CREATE VAULT',
            onPressed: (_isTermsAccepted && viewModel.isEmailVerified && viewModel.isMobileVerified)
              ? _handleSignup
              : null, // Disabled until verified
          ),
      ],
    );
  }
}
