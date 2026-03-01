import 'dart:io';
import 'package:dio/dio.dart';
import 'api_response.dart';

/// Types of API errors that can occur
enum ApiErrorType {
  noInternet,
  timeout,
  badRequest,    // 400
  unauthorized,  // 401
  notFound,      // 404
  serverError,   // 500+
  apiError,      // status: 0 from server
  unknown,
}

/// Custom exception for all API errors with user-friendly messages
class ApiException implements Exception {
  final ApiErrorType type;
  final String message;
  final int? statusCode;

  ApiException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  /// Create from a DioException (network/HTTP errors)
  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          type: ApiErrorType.timeout,
          message: 'Connection timed out. Please try again.',
          statusCode: e.response?.statusCode,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          type: ApiErrorType.noInternet,
          message: 'No internet connection. Please check your network.',
        );

      case DioExceptionType.badResponse:
        return _fromStatusCode(
          e.response?.statusCode,
          e.response?.data,
        );

      case DioExceptionType.cancel:
        return ApiException(
          type: ApiErrorType.unknown,
          message: 'Request was cancelled.',
        );

      case DioExceptionType.unknown:
      default:
        // Check if it's a SocketException (no internet)
        if (e.error is SocketException) {
          return ApiException(
            type: ApiErrorType.noInternet,
            message: 'No internet connection. Please check your network.',
          );
        }
        return ApiException(
          type: ApiErrorType.unknown,
          message: 'Something went wrong. Please try again.',
        );
    }
  }

  /// Create from an API response with status: 0
  factory ApiException.fromApiResponse(ApiResponse response) {
    return ApiException(
      type: ApiErrorType.apiError,
      message: response.message.isNotEmpty
          ? response.message
          : 'Something went wrong. Please try again.',
    );
  }

  /// Map HTTP status codes to error types
  static ApiException _fromStatusCode(int? statusCode, dynamic responseData) {
    // Try to extract server message from response body
    String serverMessage = '';
    if (responseData is Map<String, dynamic>) {
      serverMessage = responseData['message']?.toString() ?? '';
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          type: ApiErrorType.badRequest,
          message: serverMessage.isNotEmpty
              ? serverMessage
              : 'Invalid request. Please check your input.',
          statusCode: 400,
        );
      case 401:
        return ApiException(
          type: ApiErrorType.unauthorized,
          message: serverMessage.isNotEmpty
              ? serverMessage
              : 'Session expired. Please login again.',
          statusCode: 401,
        );
      case 404:
        return ApiException(
          type: ApiErrorType.notFound,
          message: serverMessage.isNotEmpty
              ? serverMessage
              : 'Service not found. Please try again later.',
          statusCode: 404,
        );
      case 500:
      case 502:
      case 503:
        return ApiException(
          type: ApiErrorType.serverError,
          message: serverMessage.isNotEmpty
              ? serverMessage
              : 'Server error. Please try again later.',
          statusCode: statusCode,
        );
      default:
        return ApiException(
          type: ApiErrorType.unknown,
          message: serverMessage.isNotEmpty
              ? serverMessage
              : 'Something went wrong. Please try again.',
          statusCode: statusCode,
        );
    }
  }

  @override
  String toString() => 'ApiException($type): $message';
}
