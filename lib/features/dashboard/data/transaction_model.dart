class TransactionModel {
  final int id;
  final double amount;
  final String date;
  final String status;
  final String title;
  final String type; // Deposit, Withdraw, ROI, Refer, Wallet

  // Deposit-specific
  final String? orderId;
  final String? utrId;
  final String? proofImage;
  final String? paymentId;

  // Withdraw-specific
  final String? referenceId;
  final String? transactionId;
  final String? adminRemarks;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    required this.title,
    required this.type,
    this.orderId,
    this.utrId,
    this.proofImage,
    this.paymentId,
    this.referenceId,
    this.transactionId,
    this.adminRemarks,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, int apiType) {
    switch (apiType) {
      case 1: // Deposit — /users/userDepositList
        return TransactionModel(
          id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
          amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
          date: json['created_at']?.toString() ?? '',
          status: json['order_status']?.toString() ?? 'pending',
          title: 'Deposit',
          type: 'Deposit',
          orderId: json['order_id']?.toString(),
          utrId: json['utr_id']?.toString(),
          proofImage: json['proof_image']?.toString(),
          paymentId: json['payment_id']?.toString(),
        );
      case 2: // Withdraw — /users/userWithdrawList
        return TransactionModel(
          id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
          amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
          date: json['created_at']?.toString() ?? '',
          status: json['status']?.toString() ?? 'pending',
          title: 'Capital Withdrawal',
          type: 'Withdraw',
          referenceId: json['reference_id']?.toString(),
          transactionId: json['transaction_id']?.toString(),
          proofImage: json['proof_image']?.toString(),
          adminRemarks: json['admin_remarks']?.toString(),
        );
      case 3: // Daily ROI profit
        return TransactionModel(
          id: json['id'] ?? 0,
          amount: (json['profit_amount'] as num?)?.toDouble() ?? 0.0,
          date: json['profit_date']?.toString() ?? '',
          status: 'completed',
          title: 'Daily ROI',
          type: 'ROI',
        );
      case 4: // Referral bonus
        return TransactionModel(
          id: json['id'] ?? 0,
          amount: (json['referral_bonus'] as num?)?.toDouble() ?? 0.0,
          date: json['bonus_date']?.toString() ?? '',
          status: 'completed',
          title: 'Referral Bonus',
          type: 'Refer',
        );
      case 5: // Wallet withdrawal request list
        return TransactionModel(
          id: json['id'] ?? 0,
          amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
          date: json['created_at']?.toString() ?? '',
          status: json['status']?.toString() ?? 'pending',
          title: 'Wallet Withdrawal',
          type: 'Wallet',
        );
      default:
        return TransactionModel(
          id: 0,
          amount: 0.0,
          date: '',
          status: 'unknown',
          title: 'Unknown Transaction',
          type: 'Unknown',
        );
    }
  }

  bool get isCredit => type == 'Deposit' || type == 'ROI' || type == 'Refer';

  /// Human-readable status badge label
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'credited':
      case 'approved':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  /// Badge colour for status
  bool get isStatusSuccess =>
      status.toLowerCase() == 'paid' ||
      status.toLowerCase() == 'completed' ||
      status.toLowerCase() == 'credited' ||
      status.toLowerCase() == 'approved';

  bool get isStatusPending => status.toLowerCase() == 'pending';
}
