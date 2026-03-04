class ApiConfig {
  // Base URL provided by user
  static const String baseUrl = 'https://werner-desertic-lorinda.ngrok-free.dev';

  // Auth Endpoints
  static const String createAccount = '/users/createAccount';
  static const String login = '/users/login';
  static const String loginVerify = '/users/loginVerify';
  static const String sendEmailOtp = '/users/send_mail_otp_register';
  static const String sendMobileOtp = '/users/send_mob_otp_register';
  static const String verifyEmailOtp = '/users/verify_mail_otp_register';
  static const String verifyMobileOtp = '/users/verify_mobile_otp_register';

  // KYC Endpoints
  static const String uploadKycDetails = '/kyc/upload_kyc_details';
  static const String addBankDetails = '/kyc/addBankDetails';
  static const String getSingleKycDetail = '/kyc/getSingleKycDetail';
  static const String saveKycAndBankDetails = '/kyc/saveKycAndBankDetails';
  static const String uploadImage = '/upload';
}
