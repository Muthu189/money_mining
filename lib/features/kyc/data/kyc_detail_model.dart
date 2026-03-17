class KycDetailModel {
  final String? username;
  final String? email;
  final String? mobileNumber;

  // Aadhaar
  final String? aadhaarNumber;
  final String? aadhaarFrontImage;
  final String? aadhaarBackImage;
  final int aadhaarStatus; // 0=pending, 1=verified, 2=rejected
  final String? aadhaarRejectReason;

  // PAN
  final String? panNumber;
  final String? panImage;
  final int panStatus; // 0=pending, 1=verified, 2=rejected
  final String? panRejectReason;

  // Bank
  final String? accNo;
  final String? ifscCode;
  final int bankStatus; // 0=pending, 1=verified, 2=rejected
  final String? bankRejectReason;

  // Overall
  final int isKycVerified;  // 0=not verified, 1=verified, 2=rejected overall
  final int isBankVerified; // 0=not verified, 1=verified

  KycDetailModel({
    this.username,
    this.email,
    this.mobileNumber,
    this.aadhaarNumber,
    this.aadhaarFrontImage,
    this.aadhaarBackImage,
    this.aadhaarStatus = 0,
    this.aadhaarRejectReason,
    this.panNumber,
    this.panImage,
    this.panStatus = 0,
    this.panRejectReason,
    this.accNo,
    this.ifscCode,
    this.bankStatus = 0,
    this.bankRejectReason,
    this.isKycVerified = 0,
    this.isBankVerified = 0,
  });

  factory KycDetailModel.fromMap(Map<String, dynamic> map) {
    return KycDetailModel(
      username: map['username']?.toString(),
      email: map['email']?.toString(),
      mobileNumber: map['mblno']?.toString(),
      aadhaarNumber: map['aadhaar_number']?.toString(),
      aadhaarFrontImage: map['aadhaar_front_image']?.toString(),
      aadhaarBackImage: map['aadhaar_back_image']?.toString(),
      aadhaarStatus: _parseInt(map['aadhaar_status']),
      aadhaarRejectReason: map['aadhaar_reject_reason']?.toString(),
      panNumber: map['pan_number']?.toString(),
      panImage: map['pan_image']?.toString(),
      panStatus: _parseInt(map['pan_status']),
      panRejectReason: map['pan_reject_reason']?.toString(),
      accNo: map['acc_no']?.toString(),
      bankStatus: _parseInt(map['bank_status']),
      bankRejectReason: map['bank_reject_reason']?.toString(),
      isKycVerified: _parseInt(map['is_kyc_verified']),
      isBankVerified: _parseInt(map['is_bank_verified']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  bool get hasAadhaarData => aadhaarNumber != null && aadhaarNumber!.isNotEmpty;
  bool get hasPanData => panNumber != null && panNumber!.isNotEmpty;
  bool get hasBankData => accNo != null && accNo!.isNotEmpty;

  bool get isAadhaarVerified => aadhaarStatus == 1;
  bool get isAadhaarRejected => aadhaarStatus == 2;
  bool get isAadhaarPending => hasAadhaarData && aadhaarStatus == 0;

  bool get isPanVerified => panStatus == 1;
  bool get isPanRejected => panStatus == 2;
  bool get isPanPending => hasPanData && panStatus == 0;

  bool get isBankVerifiedStatus => bankStatus == 1;
  bool get isBankRejected => bankStatus == 2;
  bool get isBankPending => hasBankData && bankStatus == 0;

  bool get isFullyVerified => isKycVerified == 1 && isBankVerified == 1;
  bool get hasAnyRejection =>
      isAadhaarRejected || isPanRejected || isBankRejected;
  bool get isFirstSubmission =>
      !hasAadhaarData && !hasPanData && !hasBankData;
}
