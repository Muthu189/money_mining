import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_response.dart';

class OrderModel {
  final String id;
  final int amount;
  final int amountDue;
  final int amountPaid;
  final String currency;
  final String receipt;
  final String status;
  final int createdAt;

  OrderModel({
    required this.id,
    required this.amount,
    required this.amountDue,
    required this.amountPaid,
    required this.currency,
    required this.receipt,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      amount: json['amount'] is int ? json['amount'] : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      amountDue: json['amount_due'] is int ? json['amount_due'] : int.tryParse(json['amount_due']?.toString() ?? '0') ?? 0,
      amountPaid: json['amount_paid'] is int ? json['amount_paid'] : int.tryParse(json['amount_paid']?.toString() ?? '0') ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      receipt: json['receipt']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at'] is int ? json['created_at'] : int.tryParse(json['created_at']?.toString() ?? '0') ?? 0,
    );
  }

  /// amount is in paise → convert to rupees
  double get amountInRupees => amount / 100;
}

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository(this._apiClient);

  Future<OrderModel> createOrder(int amountInRupees) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.createOrder,
        data: {'amount': amountInRupees},
      );
      final apiResponse = ApiResponse.fromResponse(response);
      if (apiResponse.isSuccess && apiResponse.data != null) {
        return OrderModel.fromJson(apiResponse.data as Map<String, dynamic>);
      } else {
        throw Exception(apiResponse.message.isNotEmpty ? apiResponse.message : 'Failed to create order');
      }
    } catch (e) {
      rethrow;
    }
  }
}
