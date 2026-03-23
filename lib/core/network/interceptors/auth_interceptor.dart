import 'dart:io';

import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage;

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true ||
        options.headers.containsKey(HttpHeaders.authorizationHeader)) {
      handler.next(options);
      return;
    }

    final tokens = await _tokenStorage.read();
    final accessToken = tokens?.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
    }

    handler.next(options);
  }
}
