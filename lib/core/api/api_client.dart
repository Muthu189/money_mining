import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/storage_service.dart';
import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  final Dio _dio;
  final StorageService _storageService;

  ApiClient(this._storageService)
      : _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 60),
    ),
  ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ✅ ONLY set JSON content type for normal body
          if (options.data is! FormData) {
            options.headers['Content-Type'] = 'application/json';
          } else {
            // ✅ Remove content-type for FormData
            options.headers.remove('Content-Type');
          }

          // ✅ Get Tokens
          final jToken = await _storageService.getJToken();
          final token = await _storageService.getToken();

          // 🔥 PRINT TOKENS
          if (kDebugMode) {
            debugPrint("===== TOKEN DEBUG =====");
            debugPrint("jToken: $jToken");
            debugPrint("token: $token");
            debugPrint("=======================");
          }

          if (jToken != null && jToken.isNotEmpty) {
            options.headers['authorization'] = '$jToken';
          }

          if (token != null && token.isNotEmpty) {
            options.headers['token'] = token;
          }

          /// 🔥 FULL DEBUG LOG
          if (kDebugMode) {
            debugPrint("============= REQUEST =============");
            debugPrint("URL: ${options.baseUrl}${options.path}");
            debugPrint("METHOD: ${options.method}");
            debugPrint("HEADERS: ${options.headers}");

            if (options.data is FormData) {
              debugPrint("BODY TYPE: FormData");
              final formData = options.data as FormData;
              for (var field in formData.fields) {
                debugPrint("FIELD: ${field.key} = ${field.value}");
              }
              for (var file in formData.files) {
                debugPrint("FILE: ${file.key} = ${file.value.filename}");
              }
            } else {
              debugPrint("BODY: ${options.data}");
            }

            debugPrint("===================================");
          }

          handler.next(options);
        },

        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint("============= RESPONSE =============");
            debugPrint("STATUS CODE: ${response.statusCode}");
            debugPrint("PATH: ${response.requestOptions.path}");
            debugPrint("DATA: ${response.data}");
            debugPrint("====================================");
          }

          handler.next(response);
        },

        onError: (DioException e, handler) {
          if (kDebugMode) {
            debugPrint("============= ERROR =============");
            debugPrint("PATH: ${e.requestOptions.path}");
            debugPrint("STATUS CODE: ${e.response?.statusCode}");
            debugPrint("MESSAGE: ${e.message}");
            debugPrint("ERROR BODY: ${e.response?.data}");
            debugPrint("=================================");
          }

          final apiException = ApiException.fromDioException(e);

          handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: apiException,
              message: apiException.message,
            ),
          );
        },
      ),
    );
  }

  Dio get dio => _dio;
}