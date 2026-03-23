import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required int id,
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    String? image,
  }) = _AppUser;
}

extension AppUserX on AppUser {
  String get displayName {
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? username : fullName;
  }
}
