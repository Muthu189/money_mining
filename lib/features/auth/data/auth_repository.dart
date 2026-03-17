import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_response.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/storage/storage_service.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepository(this._apiClient, this._storageService);

  Future<ApiResponse> createAccount({
    required String username,
    required String email,
    required String mobile,
    required String password,
    required String mailOtp,
    required String mobOtp,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.createAccount, data: {
        'username': username,
        'email': email,
        'mobile': mobile,
        'password': password,
        'mail_otp': mailOtp,
        'mob_otp': mobOtp,
      });
      final apiResponse = ApiResponse.fromResponse(response);
      if (!apiResponse.isSuccess) {
        throw ApiException.fromApiResponse(apiResponse);
      }
      return apiResponse;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw (e.error is ApiException)
          ? e.error as ApiException
          : ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<ApiResponse> sendEmailOtp(String email) async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.sendEmailOtp, data: {'email': email});
      final apiResponse = ApiResponse.fromResponse(response);
      if (!apiResponse.isSuccess) {
        throw ApiException.fromApiResponse(apiResponse);
      }
      return apiResponse;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw (e.error is ApiException)
          ? e.error as ApiException
          : ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<ApiResponse> sendMobileOtp(String mobile) async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.sendMobileOtp, data: {'mob_no': mobile});
      final apiResponse = ApiResponse.fromResponse(response);
      if (!apiResponse.isSuccess) {
        throw ApiException.fromApiResponse(apiResponse);
      }
      return apiResponse;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw (e.error is ApiException)
          ? e.error as ApiException
          : ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<ApiResponse> verifyEmailOtp(String email, String otp) async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.verifyEmailOtp, data: {'email': email, 'otp': otp});
      final apiResponse = ApiResponse.fromResponse(response);
      if (!apiResponse.isSuccess) {
        throw ApiException.fromApiResponse(apiResponse);
      }
      return apiResponse;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw (e.error is ApiException)
          ? e.error as ApiException
          : ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<ApiResponse> verifyMobileOtp(String mobile, String otp) async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.verifyMobileOtp, data: {'mob_no': mobile, 'otp': otp});
      final apiResponse = ApiResponse.fromResponse(response);
      if (!apiResponse.isSuccess) {
        throw ApiException.fromApiResponse(apiResponse);
      }
      return apiResponse;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw (e.error is ApiException)
          ? e.error as ApiException
          : ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.login, data: {
        'email': email,
        'password': password,
      });
      final apiResponse = ApiResponse.fromResponse(response);
      if (!apiResponse.isSuccess) {
        throw ApiException.fromApiResponse(apiResponse);
      }
      return apiResponse;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw (e.error is ApiException)
          ? e.error as ApiException
          : ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<ApiResponse> verifyOtp({
    required String token,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.loginVerify, data: {
        'token': token,
        'otp': otp,
      });
      final apiResponse = ApiResponse.fromResponse(response);
      if (!apiResponse.isSuccess) {
        throw ApiException.fromApiResponse(apiResponse);
      }

      // On success store jToken and token
      final data = apiResponse.raw;
      if (data != null && data is Map<String, dynamic>) {
        final jToken = data['jToken'];
        final secondaryToken = data['token'];

        if (jToken != null && secondaryToken != null) {
          await _storageService.saveAuthData(jToken, secondaryToken);
        }
      }
      return apiResponse;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw (e.error is ApiException)
          ? e.error as ApiException
          : ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  /// Forgot Password
  /// type=1 → send OTP to email
  /// type=2 → verify OTP + reset password
  Future<ApiResponse> forgotPassword({
    required String email,
    required int type,
    String? otp,
    String? newPassword,
    String? confirmPassword,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
        'type': type,
      };
      if (type == 2) {
        body['otp'] = otp;
        body['new_password'] = newPassword;
        body['confirm_password'] = confirmPassword;
      }
      final response = await _apiClient.dio.post(ApiConfig.forgotPassword, data: body);
      final apiResponse = ApiResponse.fromResponse(response);
      if (!apiResponse.isSuccess) {
        throw ApiException.fromApiResponse(apiResponse);
      }
      return apiResponse;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw (e.error is ApiException)
          ? e.error as ApiException
          : ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }
}
