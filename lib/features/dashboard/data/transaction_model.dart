class TransactionModel {
  final int id;
  final double amount;
  final String date;
  final String status;
  final String title;
  final String type; // Deposit, Withdraw, ROI, Refer, Wallet

  TransactionModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    required this.title,
    required this.type,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, int apiType) {
    switch (apiType) {
      case 1: // Deposit history
        return TransactionModel(
          id: json['id'] ?? 0,
          amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
          date: json['created_at'] ?? '',
          status: json['order_status'] ?? 'pending',
          title: 'Deposit',
          type: 'Deposit',
        );
      case 2: // Withdraw history
        return TransactionModel(
          id: json['id'] ?? 0,
          amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
          date: json['razorpay_payout_id'] ?? '', // API maps date here
          status: json['status'] ?? 'pending',
          title: 'Capital Withdrawal',
          type: 'Withdraw',
        );
      case 3: // Daily ROI profit
        return TransactionModel(
          id: json['id'] ?? 0, // Not explicitly provided
          amount: (json['wallet_profit'] as num?)?.toDouble() ?? 0.0,
          date: json['profit_date'] ?? '',
          status: 'completed', // ROI is always completed
          title: 'Daily ROI',
          type: 'ROI',
        );
      case 4: // Referral ROI
        return TransactionModel(
          id: json['id'] ?? 0,
          amount: (json['referral_bonus'] as num?)?.toDouble() ?? 0.0,
          date: json['bonus_date'] ?? '',
          status: 'completed',
          title: 'Referral Bonus',
          type: 'Refer',
        );
      case 5: // Wallet request list
        return TransactionModel(
          id: json['id'] ?? 0,
          amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
          date: json['created_at'] ?? '',
          status: json['status'] ?? 'pending',
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

  bool get isCredit {
    return type == 'Deposit' || type == 'ROI' || type == 'Refer';
  }
}
