import 'package:dio/dio.dart';

class ApiResponse {
  final int status;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? raw; // ✅ store full body

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
    this.raw,
  });

  bool get isSuccess => status == 1;

  factory ApiResponse.fromResponse(Response response) {
    final body = response.data;

    if (body is Map<String, dynamic>) {
      return ApiResponse(
        status: body['status'] is int
            ? body['status']
            : int.tryParse(body['status']?.toString() ?? '0') ?? 0,
        message: body['message']?.toString() ?? '',
        data: body['data'],
        raw: body, // ✅ store complete response
      );
    }

    return ApiResponse(
      status: 1,
      message: 'Success',
      data: body,
    );
  }
}