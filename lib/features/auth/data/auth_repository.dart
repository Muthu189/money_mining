import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/storage/storage_service.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepository(this._apiClient, this._storageService);

  Future<void> createAccount({
    required String username,
    required String email,
    required String mobile,
    required String password,
    required String mailOtp,
    required String mobOtp,
  }) async {
    try {
      await _apiClient.dio.post(ApiConfig.createAccount, data: {
        'username': username,
        'email': email,
        'mobile': mobile,
        'password': password,
        'mail_otp': mailOtp,
        'mob_otp': mobOtp,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailOtp(String email) async {
    try {
      await _apiClient.dio.post(ApiConfig.sendEmailOtp, data: {'email': email});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendMobileOtp(String mobile) async {
    try {
      await _apiClient.dio.post(ApiConfig.sendMobileOtp, data: {'mob_no': mobile});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyEmailOtp(String email, String otp) async {
    try {
      await _apiClient.dio.post(ApiConfig.verifyEmailOtp, data: {'email': email, 'otp': otp});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyMobileOtp(String mobile, String otp) async {
    try {
      await _apiClient.dio.post(ApiConfig.verifyMobileOtp, data: {'mob_no': mobile, 'otp': otp});
    } catch (e) {
      rethrow;
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.login, data: {
        'email': email,
        'password': password,
      });
      // Assuming the structure is { "token": "xyz" } based on "Receive token" description
      // or maybe it's just the body? usually JSON.
      return response.data['token'] ?? ''; 
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyOtp({
    required String token, // This might come from previous login step if API requires it, but based on request it seems to be just token + otp
    required String otp, 
  }) async {
    // The request payload says: { "token": "string", "otp": "string" }
    // Usually 'token' here refers to some temporary token received in login response?
    // The prompt says: Login Response -> Receive token -> Navigate to OTP
    // So we need to return that token from login.
    
    // Wait, let's adjust login to return the token.
    try {
      final response = await _apiClient.dio.post(ApiConfig.loginVerify, data: {
        'token': token,
        'otp': otp,
      });
      
      final data = response.data;
      // On success store jToken and token
      if (data != null) {
          final jToken = data['jToken']; 
          final secondaryToken = data['token'];
          
          if (jToken != null && secondaryToken != null) {
             await _storageService.saveAuthData(jToken, secondaryToken);
          }
      }
    } catch (e) {
      rethrow;
    }
  }
}
