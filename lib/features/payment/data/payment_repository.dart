import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_response.dart';

// ────────────────────────────────────────────────────────────
// Model: Manual order response from /payments/createOrder
// ────────────────────────────────────────────────────────────
class ManualOrderModel {
  final String orderId;
  final String message;

  ManualOrderModel({required this.orderId, required this.message});

  factory ManualOrderModel.fromJson(Map<String, dynamic> json, String msg) {
    return ManualOrderModel(
      orderId: json['order_id']?.toString() ?? '',
      message: msg,
    );
  }
}

// ────────────────────────────────────────────────────────────
// Model: Single deposit record from /users/userDepositList
// ────────────────────────────────────────────────────────────
class DepositRecord {
  final int id;
  final int userId;
  final double amount;
  final String currency;
  final String receipt;
  final String orderId;
  final String orderStatus;
  final DateTime orderCreatedAt;
  final DateTime createdAt;
  final String paymentId;
  final String utrId;
  final String proofImage;

  DepositRecord({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.receipt,
    required this.orderId,
    required this.orderStatus,
    required this.orderCreatedAt,
    required this.createdAt,
    required this.paymentId,
    required this.utrId,
    required this.proofImage,
  });

  factory DepositRecord.fromJson(Map<String, dynamic> json) {
    return DepositRecord(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      currency: json['currency']?.toString() ?? 'INR',
      receipt: json['receipt']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      orderStatus: json['order_status']?.toString() ?? '',
      orderCreatedAt: DateTime.tryParse(json['order_created_at']?.toString() ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      paymentId: json['payment_id']?.toString() ?? '',
      utrId: json['utr_id']?.toString() ?? '',
      proofImage: json['proof_image']?.toString() ?? '',
    );
  }

  /// Maps numeric/string status values to a display label
  static String statusLabel(String orderStatus) {
    switch (orderStatus.toLowerCase()) {
      case 'paid':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return orderStatus;
    }
  }
}

// ────────────────────────────────────────────────────────────
// Model: Paginated deposit list response
// ────────────────────────────────────────────────────────────
class DepositListResponse {
  final int pageNo;
  final int pageSize;
  final int total;
  final int totalPages;
  final List<DepositRecord> data;

  DepositListResponse({
    required this.pageNo,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  factory DepositListResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    return DepositListResponse(
      pageNo: json['pageNo'] is int ? json['pageNo'] : int.tryParse(json['pageNo']?.toString() ?? '1') ?? 1,
      pageSize: json['pageSize'] is int ? json['pageSize'] : int.tryParse(json['pageSize']?.toString() ?? '6') ?? 6,
      total: json['total'] is int ? json['total'] : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      totalPages: json['totalPages'] is int ? json['totalPages'] : int.tryParse(json['totalPages']?.toString() ?? '1') ?? 1,
      data: rawList.map((e) => DepositRecord.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Repository
// ────────────────────────────────────────────────────────────
class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository(this._apiClient);

  /// Submits a manual deposit:
  ///  1. Uploads the screenshot → gets proof_image URL from /upload.
  ///  2. Calls /payments/createOrder with { amount, utr_id, proof_image }.
  Future<ManualOrderModel> createManualDeposit({
    required int amount,
    required String utrId,
    required String imagePath,
  }) async {
    // ── Step 1: upload screenshot ──────────────────────────
    // /upload returns {"url": "https://..."} with NO status wrapper.
    // Read the URL directly from the raw Dio response body.
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath),
    });

    final uploadResponse = await _apiClient.dio.post(
      ApiConfig.uploadImage,
      data: formData,
    );

    // Extract URL from the raw body — try common key names at root + inside data
    final proofImageUrl = _extractUrl(uploadResponse.data);
    if (proofImageUrl.isEmpty) {
      throw Exception('Failed to get image URL from upload response');
    }

    // ── Step 2: create order ───────────────────────────────
    final response = await _apiClient.dio.post(
      ApiConfig.createOrder,
      data: {
        'amount': amount,
        'utr_id': utrId,
        'proof_image': proofImageUrl,
      },
    );

    final apiResponse = ApiResponse.fromResponse(response);
    if (apiResponse.isSuccess && apiResponse.raw != null) {
      // order_id is at the root level of the response, not inside 'data'
      return ManualOrderModel.fromJson(
        apiResponse.raw!,
        apiResponse.message,
      );
    } else {
      throw Exception(apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Failed to submit deposit request');
    }
  }

  /// Walks a response body (Map or nested Map under 'data') looking for
  /// a URL string under any common key name.
  String _extractUrl(dynamic body) {
    if (body is! Map) return '';
    const keys = ['url', 'file_url', 'image_url', 'path', 'link', 'secure_url'];
    // Check root level first
    for (final k in keys) {
      final v = body[k];
      if (v is String && v.isNotEmpty) return v;
    }
    // Then check inside 'data' if it's a Map
    final nested = body['data'];
    if (nested is Map) {
      for (final k in keys) {
        final v = nested[k];
        if (v is String && v.isNotEmpty) return v;
      }
    }
    return '';
  }


  /// Fetches paginated deposit history.
  /// [statusFilter] — 0: pending, 1: completed/credited, 2: rejected. Pass null for all.
  Future<DepositListResponse> getUserDepositList({
    int pageNo = 1,
    int pageSize = 6,
    int? statusFilter,
    String? search,
  }) async {
    final Map<String, dynamic> payload = {
      'pageNo': pageNo.toString(),
      'pageSize': pageSize.toString(),
    };
    if (statusFilter != null) payload['status'] = statusFilter;
    if (search != null && search.isNotEmpty) payload['search'] = search;

    final response = await _apiClient.dio.post(
      ApiConfig.userDepositList,
      data: payload,
    );

    final apiResponse = ApiResponse.fromResponse(response);
    if (apiResponse.isSuccess && apiResponse.raw != null) {
      return DepositListResponse.fromJson(apiResponse.raw!);
    } else {
      throw Exception(apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Failed to fetch deposit list');
    }
  }
}
