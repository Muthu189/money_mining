import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_response.dart';
import 'user_model.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<UserModel> fetchUserInfo() async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.getUserInfo);
      final apiResponse = ApiResponse.fromResponse(response);
      
      if (apiResponse.isSuccess && apiResponse.data != null) {
        return UserModel.fromJson(apiResponse.data);
      } else {
        throw Exception(apiResponse.message.isNotEmpty ? apiResponse.message : 'Failed to fetch user info');
      }
    } catch (e) {
      rethrow;
    }
  }
}
