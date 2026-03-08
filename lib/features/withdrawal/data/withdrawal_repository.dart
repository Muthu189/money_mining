import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_response.dart';

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
        final referenceId = apiResponse.raw?['reference_id']?.toString() ?? '';
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
}
