# AGENTS.md

이 파일은 이 저장소에서 작업하는 AI agent 를 위한 실행 규칙입니다.  
이 프로젝트는 `Riverpod 3 + go_router + usecase + repository pattern` 을 기준으로 설계되어 있으며, agent 는 아래 규칙을 반드시 따라야 합니다.

## 1. 기본 원칙

- 모든 설명, 커밋 메시지 초안, 문서 작성은 한국어로 작성합니다.
- 실수로라도 실제 비밀값을 커밋하지 않습니다.
- base URL, token, env 값은 예시값 또는 `--dart-define` 기반 설정만 사용합니다.
- 구조를 바꿀 때는 “작동”보다 “계층 일관성”을 우선합니다.

## 2. 이 프로젝트의 정답 아키텍처

이 저장소의 기본 계층은 아래와 같습니다.

```text
presentation -> application(controller/provider) -> application/usecases
-> domain(repository contract / entity) -> data(repository impl / datasource / dto)
```

반드시 지켜야 하는 규칙:

- `presentation` 은 repository 를 직접 호출하면 안 됩니다.
- `presentation` 은 `Dio`, `SharedPreferences`, `FlutterSecureStorage` 를 직접 사용하면 안 됩니다.
- `application` 은 repository 구현체를 직접 import 하면 안 됩니다.
- `application` 은 feature root provider 또는 usecase 만 통해서 의존성을 받아야 합니다.
- `usecase` 는 repository contract 를 사용해야 하며, data 구현 상세를 몰라야 합니다.
- `data` 는 DTO -> Entity 변환을 담당합니다.
- feature 구현체 조립은 `feature_root_providers.dart` 같은 feature 루트 파일에서만 수행합니다.

## 3. 폴더별 책임

### `lib/app`

- 앱 전체 부트스트랩
- 전역 라우터
- shell route
- 앱 테마
- 앱 전역 위젯

### `lib/core`

- 환경설정
- 공통 error/failure/result
- 공통 logging
- 공통 network 설정
- 공통 storage
- 공통 presentation helper

### `lib/features/<feature>`

각 feature 는 아래 구조를 유지합니다.

```text
feature/
  application/
    usecases/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
  presentation/
  <feature>_providers.dart
```

## 4. Riverpod 규칙

- side effect 와 상태 전이가 있으면 class-based provider 를 사용합니다.
- 단순 조립/설정/의존성 주입은 `Provider` 를 사용합니다.
- controller 는 usecase 만 호출합니다.
- provider 안에서 UI 관련 로직을 만들지 않습니다.
- provider 이름은 역할이 드러나야 합니다.
  - 예: `sessionControllerProvider`, `signInUseCaseProvider`

권장 패턴:

- 저장/로그인/로그아웃: controller + usecase
- 목록 조회: `AsyncNotifier` controller
- 설정 주입: `Provider`

## 5. go_router 규칙

- 인증이 필요 없는 화면은 공개 route 로 둡니다.
- 인증이 필요한 화면은 authenticated shell 하위에 둡니다.
- 인증 가드는 top-level `redirect` 에서 처리합니다.
- 로그인 여부 판정은 `SessionState` 만 기준으로 합니다.
- 새 인증 필요 화면 추가 시 shell route 아래에 등록합니다.

## 6. usecase 규칙

이 프로젝트에서 usecase 는 필수입니다.

다음 경우 usecase 를 반드시 만듭니다.

- 로그인/로그아웃/회원가입
- 세션 복구
- 목록 조회
- 상세 조회
- 저장/수정/삭제
- 둘 이상의 repository/datasource 결과를 조합하는 경우

하지 말아야 할 것:

- controller 안에 비즈니스 로직을 직접 구현
- repository 호출/예외 변환/입력 검증을 controller 에 몰아넣기

## 7. API 추가 규칙

새 API 를 추가할 때는 아래 순서를 강제합니다.

1. `data/models` 에 DTO 작성
2. `domain/entities` 에 Entity 작성
3. `domain/repositories` 에 contract 작성
4. `data/datasources` 에 실제 HTTP 호출 작성
5. `data/repositories` 에 DTO -> Entity 매핑 작성
6. feature 루트 provider 파일에 repository 조립
7. `application/usecases` 에 usecase 작성
8. `application` 에 controller/provider 작성
9. `presentation` 에 화면 연결
10. 필요 시 `app_router.dart` 에 route 추가
11. 테스트 작성

### API 추가 시 금지사항

- 화면에서 `dio.get/post/...` 직접 호출 금지
- DTO 를 화면까지 전달 금지
- repository 구현체를 controller 에서 직접 import 금지
- 예외를 문자열로 아무렇게나 처리 금지

## 8. 에러 처리 규칙

- network layer 는 `AppException`
- application/usecase layer 는 `AppFailure`
- usecase 는 가능하면 `Result<T>` 를 반환합니다.
- controller 는 `Result<T>` 를 해석해 화면 상태로 변환합니다.
- 인증 토큰 삭제는 `401/403` 처럼 실제 인증 무효로 판단되는 경우에만 수행합니다.
- 일시적 네트워크 실패로 세션을 지우면 안 됩니다.

## 9. UI 규칙

- 기존 테마와 색상 방향을 유지합니다.
- 새로운 화면도 현재 디자인 톤을 크게 벗어나지 않게 작성합니다.
- 로딩/에러/재시도 패턴은 `core/presentation` 공통 위젯을 우선 사용합니다.
- shell route 구조가 있으면 공통 scaffold 를 재사용합니다.

## 10. 환경설정 규칙

- 환경은 `APP_ENV`, `API_BASE_URL` 로 제어합니다.
- 새 환경값이 필요하면:
  - `AppConfig` 에 추가
  - `README.md` 와 문서 업데이트
  - 필요 시 기본값 정의
- 하드코딩된 서버 주소를 feature 코드에 직접 넣지 않습니다.

## 11. 저장소 및 보안 규칙

- 모바일 토큰 저장은 `flutter_secure_storage`
- 웹 토큰 저장은 `shared_preferences`
- UI, usecase, controller 에서 저장소 구현체를 직접 쓰지 않습니다.
- 토큰 저장/삭제는 usecase 또는 session controller 흐름 안에서만 수행합니다.

## 12. 문서 규칙

구조 변경, 새 feature 추가, 새 env 추가 시 아래 파일도 함께 검토합니다.

- `README.md`
- `docs/PROJECT_GUIDE.md`
- `AGENTS.md`

문서 반영이 필요한데 안 했으면 작업이 덜 끝난 것입니다.

## 13. 테스트 규칙

새 기능을 추가하거나 구조를 바꾸면 최소 아래를 확인합니다.

- `flutter analyze`
- `flutter test`

라우팅/플랫폼 설정을 건드렸다면 가능하면 아래도 확인합니다.

- `flutter build web`
- `flutter build ios --simulator --no-codesign`

권장 테스트 범위:

- usecase 테스트
- controller 상태 전이 테스트
- route guard 테스트
- 필요한 경우 widget 테스트

## 14. 작업 전 체크리스트

작업 전 반드시 스스로 확인할 것:

- 이 변경이 어느 feature 에 속하는가?
- 이 로직은 controller 가 아니라 usecase 로 가야 하는가?
- DTO 와 Entity 를 분리했는가?
- UI 가 data layer 를 직접 보고 있지 않은가?
- route 는 공개/인증 영역이 올바르게 분리됐는가?

## 15. 작업 후 체크리스트

작업 후 반드시 확인할 것:

- import 방향이 계층 규칙을 어기지 않는가?
- 불필요한 직접 의존성이 생기지 않았는가?
- 문서 업데이트가 필요한가?
- codegen 이 필요한 파일이면 생성했는가?
- analyze/test 가 통과하는가?

## 16. 커밋/PR 규칙

커밋 메시지는 Conventional Commits 형식을 따릅니다.

- 형식: `<type>: <subject>`
- 타입: `feat`, `fix`, `docs`, `style`, `refact`, `perf`, `test`, `chore`, `design`
- 제목/본문은 한국어
- 제목은 명사형, 50자 이하

PR 설명에는 아래가 포함되어야 합니다.

- 변경 요약
- 관련 이슈
- UI 변경 시 스크린샷
- 설정 변경 사항

## 17. 최종 원칙

이 프로젝트에서 agent 는 아래 한 문장을 항상 기준으로 삼습니다.

`화면은 상태를 보여주고, controller는 상태를 관리하고, usecase는 일을 처리하고, repository는 데이터를 추상화하고, datasource는 외부와 통신한다.`

이 원칙을 깨는 변경은 하지 않습니다.
