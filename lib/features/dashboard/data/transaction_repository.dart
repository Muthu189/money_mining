import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_response.dart';
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

  Future<TransactionPageResult> fetchTransactions(int type, int pageNo, {int pageSize = 10}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.transactionHistory,
        data: {
          'type': type,
          'pageNo': pageNo,
          'pageSize': pageSize,
        },
      );

      // We need to parse custom response formats since type == 1 uses "success" not "status" = 1
      final data = response.data;
      
      if (data is Map<String, dynamic>) {
        final isSuccess = data['status'] == 1 || data['success'] == true;
        
        if (isSuccess) {
          final items = (data['data'] as List<dynamic>?) ?? [];
          final transactions = items.map((item) => TransactionModel.fromJson(item as Map<String, dynamic>, type)).toList();
          
          final totalRecords = data['totalRecords'] ?? data['total'] ?? 0;
          final totalPages = data['totalPages'] ?? ((totalRecords / pageSize).ceil());

          return TransactionPageResult(
            transactions: transactions,
            totalRecords: totalRecords is int ? totalRecords : int.tryParse(totalRecords.toString()) ?? 0,
            totalPages: totalPages is int ? totalPages : int.tryParse(totalPages.toString()) ?? 0,
          );
        } else {
          throw Exception(data['message']?.toString() ?? 'Failed to load transactions');
        }
      }
      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }
}
