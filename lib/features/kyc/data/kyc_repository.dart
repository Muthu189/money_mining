import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
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
        'file': await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.dio.post(
        ApiConfig.uploadImage,
        data: formData,
      );

      debugPrint("Upload Raw Response: ${response.data}");

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['url'] != null) {
        return response.data['url'];
      }

      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Invalid upload response format',
      );
    } on DioException catch (e) {
      debugPrint("Upload Dio Error: ${e.response?.data}");
      throw ApiException.fromDioException(e);
    }
  }
  Future<ApiResponse> saveKycAndBankDetails({
    required String aadhaarNumber,
    required String aadhaarFrontUrl,
    required String aadhaarBackUrl,
    required String panNumber,
    required String panUrl,
    required String accNo,
    required String ifscCode,
    required String bankName,
    required String bankImageUrl,
  }) async {
    try {
      final body = {
        'aadhaar_number': aadhaarNumber,
        'aadhaar_front_image': aadhaarFrontUrl,
        'aadhaar_back_image': aadhaarBackUrl,
        'pan_number': panNumber,
        'pan_image': panUrl,
        'acc_no': accNo,
        'ifsc_code': ifscCode,
        'bank_name': bankName,
        'bank_image': bankImageUrl,
      };

      debugPrint("Submitting KYC Body: $body");

      final response = await _apiClient.dio.post(
        ApiConfig.saveKycAndBankDetails,
        data: body,
      );

      debugPrint("KYC Raw Response: ${response.data}");

      final apiResponse = ApiResponse.fromResponse(response);

      if (!apiResponse.isSuccess) {
        debugPrint("KYC API Failed: ${apiResponse.message}");
        throw ApiException.fromApiResponse(apiResponse);
      }

      return apiResponse;
    } on DioException catch (e) {
      debugPrint("KYC Dio Error: ${e.response?.data}");
      throw ApiException.fromDioException(e);
    }
  }


  Future<ApiResponse> getKycStatus() async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.getSingleKycDetail);
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

  /// Fetch list of bank names
  Future<List<String>> fetchBankList() async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.getBankList);
      final apiResponse = ApiResponse.fromResponse(response);
      if (!apiResponse.isSuccess) {
        throw ApiException.fromApiResponse(apiResponse);
      }
      final List data = apiResponse.data ?? [];
      return data.map<String>((item) => item['bank_name']?.toString() ?? '').where((name) => name.isNotEmpty).toList();
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
