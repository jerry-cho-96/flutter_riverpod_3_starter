import 'package:dio/dio.dart';

class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  factory AppException.fromDioException(DioException exception) {
    return AppException(
      _resolveMessage(exception),
      statusCode: exception.response?.statusCode,
    );
  }

  final String message;
  final int? statusCode;

  static String _resolveMessage(DioException exception) {
    final data = exception.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => '네트워크 연결이 지연되고 있습니다. 다시 시도해 주세요.',
      DioExceptionType.connectionError => '네트워크 연결을 확인한 뒤 다시 시도해 주세요.',
      DioExceptionType.cancel => '요청이 취소되었습니다.',
      _ => '요청을 처리하지 못했습니다.',
    };
  }

  @override
  String toString() =>
      'AppException(statusCode: $statusCode, message: $message)';
}
