class TemplateExample {
  const TemplateExample._();

  static const String apiProviderName = 'DummyJSON';
  static const String authChipLabel = '$apiProviderName Auth';
  static const String loginDescription =
      '$apiProviderName 인증 흐름을 기준으로 세션 복구, 라우트 가드, 홈 진입까지 한 번에 확인할 수 있습니다.';
  static const String productsTitle = '$apiProviderName 상품 예시';
  static const String productsDescription =
      '인증 세션과 별개로 네트워크 계층, usecase, DTO 매핑, pull-to-refresh 흐름을 확인할 수 있는 샘플입니다.';
  static const String exampleUsername = 'emilys';
  static const String examplePassword = 'emilyspass';
  static const String exampleCredentialsDescription =
      'username: $exampleUsername / password: $examplePassword';
  static const int authSessionExpiresInMinutes = 30;
}
