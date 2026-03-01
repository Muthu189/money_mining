import 'package:dio/dio.dart';

/// Standardized API response model.
/// All API responses follow: { "status": 1/0, "message": "...", "data": {...} }
class ApiResponse {
  final int status;
  final String message;
  final dynamic data;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  /// Whether the API returned a success status (status == 1)
  bool get isSuccess => status == 1;

  /// Parse a Dio Response into an ApiResponse
  factory ApiResponse.fromResponse(Response response) {
    final body = response.data;

    if (body is Map<String, dynamic>) {
      return ApiResponse(
        status: body['status'] is int
            ? body['status']
            : int.tryParse(body['status']?.toString() ?? '0') ?? 0,
        message: body['message']?.toString() ?? '',
        data: body['data'],
      );
    }

    // If response is not the expected format, treat as success with raw data
    return ApiResponse(
      status: 1,
      message: 'Success',
      data: body,
    );
  }
}
