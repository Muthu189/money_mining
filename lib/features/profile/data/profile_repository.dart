import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_response.dart';
import '../../../core/api/api_exception.dart';
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

  /// Change password
  Future<ApiResponse> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.changePassword, data: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
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

  /// Upload image to server and get URL
  Future<String> uploadImage(File image) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path, filename: fileName),
      });
      final response = await _apiClient.dio.post(ApiConfig.uploadImage, data: formData);

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['url'] != null) {
        return response.data['url'];
      }
      throw ApiException(type: ApiErrorType.unknown, message: 'Invalid upload response');
    } on DioException catch (e) {
      debugPrint("Upload Dio Error: ${e.response?.data}");
      throw ApiException.fromDioException(e);
    }
  }

  /// Update profile image URL
  Future<ApiResponse> updateProfileImage(String imageUrl) async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.updateProfileImage, data: {
        'profile_img': imageUrl,
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

  /// Update PIN (type=1 enable, type=2 disable)
  Future<ApiResponse> updatePin({required int type, required String pin}) async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.updatePin, data: {
        'type': type,
        'pin': pin,
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
}
