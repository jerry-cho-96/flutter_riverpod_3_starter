import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/template_example.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/models/app_exception.dart';
import '../models/auth_response_dto.dart';
import '../models/refresh_token_response_dto.dart';
import '../models/user_dto.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(dio: ref.watch(dioProvider));
});

class AuthRemoteDataSource {
  AuthRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<UserDto> fetchCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      final json = response.data;
      if (json == null) {
        throw const AppException('사용자 정보를 불러오지 못했습니다.');
      }

      return UserDto.fromJson(json);
    } on DioException catch (error) {
      throw AppException.fromDioException(error);
    }
  }

  Future<RefreshTokenResponseDto> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: <String, Object>{
          'refreshToken': refreshToken,
          'expiresInMins': TemplateExample.authSessionExpiresInMinutes,
        },
        options: Options(extra: <String, Object>{'skipAuth': true}),
      );
      final json = response.data;
      if (json == null) {
        throw const AppException('토큰 갱신 응답이 비어 있습니다.');
      }

      return RefreshTokenResponseDto.fromJson(json);
    } on DioException catch (error) {
      throw AppException.fromDioException(error);
    }
  }

  Future<AuthResponseDto> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: <String, Object>{
          'username': username.trim(),
          'password': password,
          'expiresInMins': TemplateExample.authSessionExpiresInMinutes,
        },
        options: Options(extra: <String, Object>{'skipAuth': true}),
      );
      final json = response.data;
      if (json == null) {
        throw const AppException('로그인 응답이 비어 있습니다.');
      }

      return AuthResponseDto.fromJson(json);
    } on DioException catch (error) {
      throw AppException.fromDioException(error);
    }
  }
}
