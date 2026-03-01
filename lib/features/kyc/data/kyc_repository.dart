import 'package:dio/dio.dart';
import 'dart:io';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_response.dart';
import '../../../core/api/api_exception.dart';

class KycRepository {
  final ApiClient _apiClient;

  KycRepository(this._apiClient);

  Future<String> uploadImage(File image) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path, filename: fileName),
      });

      final response = await _apiClient.dio.post(ApiConfig.uploadImage, data: formData);
      final apiResponse = ApiResponse.fromResponse(response);
      if (!apiResponse.isSuccess) {
        throw ApiException.fromApiResponse(apiResponse);
      }
      // Extract URL from data or from top-level response
      final data = apiResponse.data;
      if (data is Map<String, dynamic> && data['url'] != null) {
        return data['url'];
      }
      // Fallback: check if url is at top level of response
      if (response.data is Map<String, dynamic> && response.data['url'] != null) {
        return response.data['url'];
      }
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Failed to get uploaded image URL.',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw (e.error is ApiException)
          ? e.error as ApiException
          : ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<ApiResponse> uploadKycDetails({
    required String aadhaarNumber,
    required String aadhaarFrontUrl,
    required String aadhaarBackUrl,
    required String panNumber,
    required String panUrl,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.uploadKycDetails, data: {
        'aadhaar_number': aadhaarNumber,
        'pan_number': panNumber,
        'aadhaar_front_image': aadhaarFrontUrl,
        'aadhaar_back_image': aadhaarBackUrl,
        'pan_image': panUrl,
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
      if (e is ApiException) rethrow;
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<ApiResponse> addBankDetails({
    required String accNo,
    required String ifscCode,
    required String bankImageUrl,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.addBankDetails, data: {
        'acc_no': accNo,
        'ifsc_code': ifscCode,
        'bank_image': bankImageUrl,
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
      if (e is ApiException) rethrow;
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<ApiResponse> getKycStatus() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.getSingleKycDetail);
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
      if (e is ApiException) rethrow;
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }
}
