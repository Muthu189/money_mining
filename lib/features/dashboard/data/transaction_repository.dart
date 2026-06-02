import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import 'transaction_model.dart';

class TransactionPageResult {
  final List<TransactionModel> transactions;
  final int totalRecords;
  final int totalPages;

  TransactionPageResult({
    required this.transactions,
    required this.totalRecords,
    required this.totalPages,
  });
}

class TransactionRepository {
  final ApiClient _apiClient;

  TransactionRepository(this._apiClient);

  Future<TransactionPageResult> fetchTransactions(
    int type,
    int pageNo, {
    int pageSize = 10,
  }) async {
    try {
      // type 1 → /users/userDepositList  (new manual-deposit endpoint)
      // type 2 → /users/userWithdrawList (new withdrawal-list endpoint)
      // types 3-5 → legacy /users/transactionHistory
      if (type == 1) {
        return _fetchDepositList(pageNo, pageSize);
      } else if (type == 2) {
        return _fetchWithdrawList(pageNo, pageSize);
      } else {
        return _fetchLegacy(type, pageNo, pageSize);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── Deposit list (/users/userDepositList) ─────────────────
  Future<TransactionPageResult> _fetchDepositList(
      int pageNo, int pageSize) async {
    final response = await _apiClient.dio.post(
      ApiConfig.userDepositList,
      data: {
        'pageNo': pageNo.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    final data = response.data as Map<String, dynamic>? ?? {};
    final isSuccess = data['status'] == 1;
    if (!isSuccess) {
      throw Exception(
          data['message']?.toString() ?? 'Failed to load deposit history');
    }

    final items = (data['data'] as List<dynamic>?) ?? [];
    final transactions = items
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>, 1))
        .toList();

    final total = _parseInt(data['total'] ?? data['totalRecords'] ?? 0);
    final totalPages = _parseInt(data['totalPages'] ??
        ((total / pageSize).ceil()));

    return TransactionPageResult(
      transactions: transactions,
      totalRecords: total,
      totalPages: totalPages,
    );
  }

  // ── Withdrawal list (/users/userWithdrawList) ─────────────
  Future<TransactionPageResult> _fetchWithdrawList(
      int pageNo, int pageSize) async {
    final response = await _apiClient.dio.post(
      ApiConfig.userWithdrawList,
      data: {
        'pageNo': pageNo,
        'pageSize': pageSize,
      },
    );

    final data = response.data as Map<String, dynamic>? ?? {};
    final isSuccess = data['status'] == 1;
    if (!isSuccess) {
      throw Exception(
          data['message']?.toString() ?? 'Failed to load withdrawal history');
    }

    final items = (data['data'] as List<dynamic>?) ?? [];
    final transactions = items
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>, 2))
        .toList();

    final totalRecords =
        _parseInt(data['totalRecords'] ?? data['total'] ?? 0);
    final totalPages = _parseInt(data['totalPages'] ??
        ((totalRecords / pageSize).ceil()));

    return TransactionPageResult(
      transactions: transactions,
      totalRecords: totalRecords,
      totalPages: totalPages,
    );
  }

  // ── Legacy: ROI / Refer / Wallet (/users/transactionHistory) ─
  Future<TransactionPageResult> _fetchLegacy(
      int type, int pageNo, int pageSize) async {
    final response = await _apiClient.dio.post(
      ApiConfig.transactionHistory,
      data: {
        'type': type,
        'pageNo': pageNo,
        'pageSize': pageSize,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final isSuccess = data['status'] == 1 || data['success'] == true;
      if (isSuccess) {
        final items = (data['data'] as List<dynamic>?) ?? [];
        final transactions = items
            .map((e) =>
                TransactionModel.fromJson(e as Map<String, dynamic>, type))
            .toList();

        final totalRecords =
            _parseInt(data['totalRecords'] ?? data['total'] ?? 0);
        final totalPages = _parseInt(data['totalPages'] ??
            ((totalRecords / pageSize).ceil()));

        return TransactionPageResult(
          transactions: transactions,
          totalRecords: totalRecords,
          totalPages: totalPages,
        );
      } else {
        throw Exception(
            data['message']?.toString() ?? 'Failed to load transactions');
      }
    }
    throw Exception('Invalid response format');
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }
}
