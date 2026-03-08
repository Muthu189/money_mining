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

  //profile
  static const String getUserInfo = '/users/info';

  // Payment
  static const String createOrder = '/payments/createOrder';

  // Withdrawal
  static const String requestMoveWalletAmount = '/users/requestMoveWalletAmount';
  static const String userWithdrawRequest = '/users/userWithdrawRequest';

  // Transaction History
  static const String transactionHistory = '/users/transactionHistory';

  // Support Ticket Endpoints
  static const String createTicket = '/users/createTicket';
  static const String replyTicket = '/users/replyTicket';
  static const String userTicketList = '/users/userTicketList';
  static const String ticketDetails = '/users/ticketDetails';
}
