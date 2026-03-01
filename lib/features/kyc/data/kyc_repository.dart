import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'dart:io';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';

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
      return response.data['url']; // Assuming response is { "url": "..." }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadKycDetails({
    required String aadhaarNumber,
    required String aadhaarFrontUrl,
    required String aadhaarBackUrl,
    required String panNumber,
    required String panUrl,
  }) async {
    try {
      await _apiClient.dio.post(ApiConfig.uploadKycDetails, data: {
        'aadhaar_number': aadhaarNumber,
        'pan_number': panNumber,
        'aadhaar_front_image': aadhaarFrontUrl,
        'aadhaar_back_image': aadhaarBackUrl,
        'pan_image': panUrl,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addBankDetails({
    required String accNo,
    required String ifscCode,
    required String bankImageUrl,
  }) async {
    try {
      await _apiClient.dio.post(ApiConfig.addBankDetails, data: {
        'acc_no': accNo,
        'ifsc_code': ifscCode,
        'bank_image': bankImageUrl,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getKycStatus() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.getSingleKycDetail);
      // Response Handling: Show KYC + Bank verification status
      // Assuming response.data contains the status
      return response.data; 
    } catch (e) {
      rethrow;
    }
  }
}
