import 'package:freezed_annotation/freezed_annotation.dart';

import '../network/models/app_exception.dart';

part 'app_failure.freezed.dart';

enum FailureType { network, unauthorized, validation, server, unknown }

@freezed
abstract class AppFailure with _$AppFailure implements Exception {
  const factory AppFailure({
    required String message,
    required FailureType type,
    int? statusCode,
  }) = _AppFailure;

  factory AppFailure.fromAppException(AppException exception) {
    return AppFailure(
      message: exception.message,
      type: _resolveType(exception.statusCode),
      statusCode: exception.statusCode,
    );
  }

  factory AppFailure.fromObject(
    Object error, {
    String fallbackMessage = '알 수 없는 오류가 발생했습니다.',
  }) {
    if (error is AppFailure) {
      return error;
    }
    if (error is AppException) {
      return AppFailure.fromAppException(error);
    }

    return AppFailure(message: fallbackMessage, type: FailureType.unknown);
  }

  static FailureType _resolveType(int? statusCode) {
    if (statusCode == null) {
      return FailureType.network;
    }
    if (statusCode == 401 || statusCode == 403) {
      return FailureType.unauthorized;
    }
    if (statusCode >= 400 && statusCode < 500) {
      return FailureType.validation;
    }
    if (statusCode >= 500) {
      return FailureType.server;
    }

    return FailureType.unknown;
  }
}

extension AppFailureX on AppFailure {
  bool get isUnauthorized => type == FailureType.unauthorized;
}
