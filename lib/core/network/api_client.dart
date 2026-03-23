import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../logging/app_logger.dart';
import '../storage/token_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/network_log_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final logger = ref.watch(appLoggerProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      // Web 의 fetch 기반 adapter 는 request body 가 없는 요청에서
      // sendTimeout 을 지원하지 않아 GET 요청마다 경고를 남긴다.
      sendTimeout: kIsWeb ? null : const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(AuthInterceptor(tokenStorage: tokenStorage));

  if (kDebugMode) {
    dio.interceptors.add(NetworkLogInterceptor(logger));
  }

  return dio;
});
