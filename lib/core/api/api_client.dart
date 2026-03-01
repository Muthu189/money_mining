import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/storage_service.dart';
import 'api_config.dart';

class ApiClient {
  final Dio _dio;
  final StorageService _storageService;

  ApiClient(this._storageService)
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add Auth Headers if token exists
        final jToken = await _storageService.getJToken();
        final token = await _storageService.getToken();

        if (jToken != null) {
          options.headers['Authorization'] = 'Bearer $jToken';
        }
        if (token != null) {
          options.headers['token'] = token;
        }

        if (kDebugMode) {
          print('--> ${options.method} ${options.path}');
          print('Headers: ${options.headers}');
          print('Body: ${options.data}');
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('<-- ${response.statusCode} ${response.requestOptions.path}');
          print('Response: ${response.data}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          print('<-- ERROR ${e.response?.statusCode} ${e.requestOptions.path}');
          print('Message: ${e.message}');
          print('Data: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
