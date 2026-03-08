class UserModel {
  final int id;
  final String username;
  final String email;
  final String mblno;
  final int isKycVerified;
  final int isBankVerified;
  final String referralCode;

  final double mainWallet;
  final double wallet;
  final double hold;

  final double totalDeposit;
  final double totalWithdraw;

  final double totalRoiByMainWallet;
  final double totalRefRoi;

  final double todayRoiByMainWallet;
  final double todayRefRoi;

  final double totalRoi;
  final double todayRoi;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.mblno,
    required this.isKycVerified,
    required this.isBankVerified,
    required this.referralCode,
    required this.mainWallet,
    required this.wallet,
    required this.hold,
    required this.totalDeposit,
    required this.totalWithdraw,
    required this.totalRoiByMainWallet,
    required this.totalRefRoi,
    required this.todayRoiByMainWallet,
    required this.todayRefRoi,
    required this.totalRoi,
    required this.todayRoi,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return 0.0;
    }

    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      mblno: json['mblno'] ?? '',
      isKycVerified: json['is_kyc_verified'] ?? 0,
      isBankVerified: json['is_bank_verified'] ?? 0,
      referralCode: json['referral_code'] ?? '',

      mainWallet: parseDouble(json['main_wallet']),
      wallet: parseDouble(json['wallet']),
      hold: parseDouble(json['hold']),

      totalDeposit: parseDouble(json['total_deposit']),
      totalWithdraw: parseDouble(json['total_withdraw']),

      totalRoiByMainWallet: parseDouble(json['total_roi_by_his_main_wallet']),
      totalRefRoi: parseDouble(json['total_ref_roi']),

      todayRoiByMainWallet: parseDouble(json['today_roi_by_his_main_wallet']),
      todayRefRoi: parseDouble(json['today_ref_roi']),

      totalRoi: parseDouble(json['TOTAL_ROI']),
      todayRoi: parseDouble(json['TODAY_ROI']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'mblno': mblno,
      'is_kyc_verified': isKycVerified,
      'is_bank_verified': isBankVerified,
      'referral_code': referralCode,
      'main_wallet': mainWallet,
      'wallet': wallet,
      'hold': hold,
      'total_deposit': totalDeposit,
      'total_withdraw': totalWithdraw,
      'total_roi_by_his_main_wallet': totalRoiByMainWallet,
      'total_ref_roi': totalRefRoi,
      'today_roi_by_his_main_wallet': todayRoiByMainWallet,
      'today_ref_roi': todayRefRoi,
      'TOTAL_ROI': totalRoi,
      'TODAY_ROI': todayRoi,
    };
  }
}