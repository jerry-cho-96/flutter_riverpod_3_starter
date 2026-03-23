import 'package:dio/dio.dart';

import '../../logging/app_logger.dart';

class NetworkLogInterceptor extends Interceptor {
  NetworkLogInterceptor(this._logger);

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug(
      '[HTTP] ${options.method} ${options.baseUrl}${options.path} query=${options.queryParameters}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.debug(
      '[HTTP] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.error(
      '[HTTP] ${err.response?.statusCode} ${err.requestOptions.method} ${err.requestOptions.path}',
      error: err.message,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }
}
