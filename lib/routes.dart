import 'package:flutter/material.dart';
import 'features/splash/view/splash_page.dart';
import 'features/onboarding/view/onboarding_page.dart';  
import 'features/auth/view/auth_page.dart';              
import 'features/kyc/view/kyc_verification_page.dart'; 
import 'features/kyc/view/kyc_selfie_page.dart';
import 'features/dashboard/view/dashboard_page.dart';
import 'features/deposit/view/deposit_amount_page.dart';
import 'features/deposit/view/deposit_success_page.dart';
import 'features/withdrawal/view/withdrawal_page.dart';
import 'features/withdrawal/view/withdrawal_success_page.dart';
import 'features/withdrawal/view/withdrawal_tracking_page.dart';
import 'features/deposit/view/deposit_receipt_page.dart';
import 'features/auth/view/forgot_password_page.dart';
import 'features/notifications/view/notification_center_page.dart';
import 'features/referral/view/referral_page.dart';
import 'features/profile/view/security_page.dart';
import 'features/profile/view/change_password_page.dart';
import 'features/legal/view/terms_conditions_page.dart';
import 'features/auth/view/otp_verification_page.dart';
import 'features/splash/view/maintenance_page.dart';
import 'features/auth/view/app_lock_page.dart';
import 'features/legal/view/privacy_policy_page.dart';

class Routes {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String forgotPassword = '/forgot_password';
  static const String otpVerification = '/otp_verification';
  static const String kycVerification = '/kyc_verification';
  static const String kycSelfie = '/kyc_selfie';
  static const String dashboard = '/dashboard';
  static const String notifications = '/notifications';
  static const String depositAmount = '/deposit_amount';
  static const String depositSuccess = '/deposit_success';
  static const String depositReceipt = '/deposit_receipt';
  static const String withdrawal = '/withdrawal';
  static const String withdrawalSuccess = '/withdrawal_success';
  static const String withdrawalTracking = '/withdrawal_tracking';
  static const String referral = '/referral';
  static const String security = '/security';
  static const String changePassword = '/change_password';
  static const String terms = '/terms';
  static const String privacyPolicy = '/privacy_policy';
  static const String maintenance = '/maintenance';
  static const String appLock = '/app_lock';

  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      splash: (context) => const SplashPage(),
      onboarding: (context) => const OnboardingPage(),
      auth: (context) => const AuthPage(),
      forgotPassword: (context) => const ForgotPasswordPage(),
      kycVerification: (context) => const KycVerificationPage(),
      kycSelfie: (context) => const KycSelfiePage(),
      dashboard: (context) => const DashboardPage(),
      notifications: (context) => const NotificationCenterPage(),
      depositAmount: (context) => const DepositAmountPage(),
      depositSuccess: (context) => const DepositSuccessPage(),
      depositReceipt: (context) => const DepositReceiptPage(),
      withdrawal: (context) => const WithdrawalPage(),
      withdrawalSuccess: (context) => const WithdrawalSuccessPage(),
      withdrawalTracking: (context) => const WithdrawalTrackingPage(),
      referral: (context) => const ReferralPage(),
      security: (context) => const SecurityPage(),
      changePassword: (context) => const ChangePasswordPage(),
      terms: (context) => const TermsConditionsPage(),
      privacyPolicy: (context) => const PrivacyPolicyPage(),
      otpVerification: (context) => const OtpVerificationPage(),
      maintenance: (context) => const MaintenancePage(),
      appLock: (context) => const AppLockPage(),
    };
  }
}
