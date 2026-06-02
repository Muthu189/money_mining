import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_response.dart';

// ────────────────────────────────────────────────────────────
// Model: Single withdrawal record from /users/userWithdrawList
// ────────────────────────────────────────────────────────────
class WithdrawRecord {
  final int id;
  final double amount;
  final String status;
  final String referenceId;
  final String transactionId;
  final String proofImage;
  final String adminRemarks;
  final DateTime createdAt;

  WithdrawRecord({
    required this.id,
    required this.amount,
    required this.status,
    required this.referenceId,
    required this.transactionId,
    required this.proofImage,
    required this.adminRemarks,
    required this.createdAt,
  });

  factory WithdrawRecord.fromJson(Map<String, dynamic> json) {
    return WithdrawRecord(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? '',
      referenceId: json['reference_id']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString() ?? '',
      proofImage: json['proof_image']?.toString() ?? '',
      adminRemarks: json['admin_remarks']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  /// Display badge label for the status field
  static String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}

// ────────────────────────────────────────────────────────────
// Model: Paginated withdrawal list response
// ────────────────────────────────────────────────────────────
class WithdrawListResponse {
  final int pageNo;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final List<WithdrawRecord> data;

  WithdrawListResponse({
    required this.pageNo,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    required this.data,
  });

  factory WithdrawListResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    return WithdrawListResponse(
      pageNo: json['pageNo'] is int
          ? json['pageNo']
          : int.tryParse(json['pageNo']?.toString() ?? '1') ?? 1,
      pageSize: json['pageSize'] is int
          ? json['pageSize']
          : int.tryParse(json['pageSize']?.toString() ?? '10') ?? 10,
      totalRecords: json['totalRecords'] is int
          ? json['totalRecords']
          : int.tryParse(json['totalRecords']?.toString() ?? '0') ?? 0,
      totalPages: json['totalPages'] is int
          ? json['totalPages']
          : int.tryParse(json['totalPages']?.toString() ?? '1') ?? 1,
      data: rawList
          .map((e) => WithdrawRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Repository
// ────────────────────────────────────────────────────────────
class WithdrawalRepository {
  final ApiClient _apiClient;

  WithdrawalRepository(this._apiClient);

  /// Withdraw Capital – moves deposit earnings to main wallet (admin approval required)
  Future<String> requestMoveWalletAmount(String amount) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.requestMoveWalletAmount,
        data: {'amount': amount},
      );
      final apiResponse = ApiResponse.fromResponse(response);
      if (apiResponse.isSuccess) {
        return apiResponse.message;
      } else {
        throw Exception(apiResponse.message.isNotEmpty
            ? apiResponse.message
            : 'Failed to submit move wallet request');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Wallet Withdrawal – instant bank transfer from wallet balance
  /// Returns reference_id on success
  Future<Map<String, String>> userWithdrawRequest(String amount) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.userWithdrawRequest,
        data: {'amount': amount},
      );
      final apiResponse = ApiResponse.fromResponse(response);
      if (apiResponse.isSuccess) {
        final referenceId =
            apiResponse.raw?['reference_id']?.toString() ?? '';
        return {
          'message': apiResponse.message,
          'reference_id': referenceId,
        };
      } else {
        throw Exception(apiResponse.message.isNotEmpty
            ? apiResponse.message
            : 'Failed to submit withdrawal request');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches paginated withdrawal history from /users/userWithdrawList
  Future<WithdrawListResponse> getUserWithdrawList({
    int pageNo = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.userWithdrawList,
        data: {
          'pageNo': pageNo,
          'pageSize': pageSize,
        },
      );
      final apiResponse = ApiResponse.fromResponse(response);
      if (apiResponse.isSuccess && apiResponse.raw != null) {
        return WithdrawListResponse.fromJson(apiResponse.raw!);
      } else {
        throw Exception(apiResponse.message.isNotEmpty
            ? apiResponse.message
            : 'Failed to fetch withdrawal list');
      }
    } catch (e) {
      rethrow;
    }
  }
}
