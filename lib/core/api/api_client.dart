import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/storage_service.dart';
import 'api_config.dart';
import 'api_exception.dart';
import '../../routes.dart';

class ApiClient {
  final Dio _dio;
  final StorageService _storageService;

  ApiClient(this._storageService)
      : _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 120),
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

          if (response.data is Map<String, dynamic>) {
            final status = response.data['status'];
            if (status == 6) {
              // Session expired -> logout
              _logout();
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  error: ApiException(type: ApiErrorType.unauthorized, message: 'Session expired. Please login again.'),
                  message: 'Session expired',
                ),
              );
            } else if (status == 5) {
              // Under maintenance
              _showMaintenance();
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  error: ApiException(type: ApiErrorType.serverError, message: 'App is under maintenance.'),
                  message: 'Under maintenance',
                ),
              );
            }
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

          if (e.response?.statusCode == 404) {
            _logout();
          }
          if (e.response?.statusCode == 400) {
            _logout();
          }

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

  void _logout() async {
    await _storageService.clearAuthData();
    Future.microtask(() {
      Routes.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        Routes.auth,
        (route) => false,
      );
    });
  }

  void _showMaintenance() {
    Future.microtask(() {
      Routes.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        Routes.maintenance,
        (route) => false,
      );
    });
  }
}
