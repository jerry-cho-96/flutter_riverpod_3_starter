# 프로젝트 가이드

이 문서는 `riverpod_origin_template` 의 구조와 사용 방법을 실무 관점에서 설명하는 가이드입니다.  
처음 프로젝트를 받은 개발자가 아래 순서대로 읽으면:

- 앱이 어떻게 시작되는지
- 상태가 어떻게 흘러가는지
- 새 화면과 새 API 를 어디에 추가해야 하는지
- 어떤 코드를 어느 계층에 두어야 하는지

를 한 번에 이해할 수 있도록 작성했습니다.

스타터킷 운영 기준, feature 템플릿, 폴더 유지/분리 판단 기준은 [ARCHITECTURE.md](./ARCHITECTURE.md) 를 기준 문서로 사용합니다.

## 1. 이 템플릿이 해결하려는 것

이 프로젝트는 Flutter 앱에서 자주 필요한 기본 문제를 정석적으로 풀기 위한 스타터입니다.

- 앱 시작 시 세션 복구
- 인증 상태에 따른 라우팅 제어
- API 호출과 토큰 저장 분리
- 기능별 폴더 구조
- `presentation -> application -> usecase -> domain contract` 와 `data -> domain contract` 분리
- Riverpod 3 기반 상태 관리
- `go_router` 기반 라우팅
- usecase 기반 비즈니스 흐름 분리

샘플 앱에 들어간 예제 계정, 화면 문구, DummyJSON 전용 인증 옵션은 `lib/core/config/template_example.dart` 에 모아 두었습니다. 템플릿을 실제 서비스로 전환할 때는 이 파일과 각 feature 의 datasource 구현부터 교체하면 됩니다.

핵심 원칙은 하나입니다.

`화면은 비즈니스 로직을 몰라야 하고, 비즈니스 로직은 UI를 몰라야 한다.`

## 2. 전체 구조 한눈에 보기

```text
lib/
  app/
    router/         앱 라우팅, 인증 가드, shell route
      route_modules/ 대형 확장을 위한 route 조립 샘플
    theme/          앱 테마
    widgets/        앱 전역 위젯
  core/
    config/         환경설정, env
    errors/         공통 failure 모델
    logging/        provider observer, logger
    network/        dio, interceptor, 예외 변환
    pagination/     공통 pagination value/state
    presentation/   공통 UI 조각
    result/         Result 타입
    storage/        토큰 저장소
  features/
    auth/
      auth_providers.dart
      application/
        controllers/  세션/로그인 controller
        states/       세션 상태
        usecases/   로그인/로그아웃/세션복구 usecase
      data/         remote datasource, dto, repository 구현
      domain/       entity, value object, repository contract
      presentation/
        mixins/     화면 전용 provider facade
        screens/    splash, login 화면
    home/
      home_providers.dart
      application/
        controllers/  상품 목록/상세 controller
        providers/    page-scoped argument provider
        usecases/   상품 조회 usecase
      data/
      domain/
      presentation/
        mixins/     화면 전용 provider facade
        screens/    home, detail, invalid detail 화면
    quotes/
      quotes_providers.dart
      application/
        controllers/  명언 목록 controller
        usecases/   명언 목록 조회 usecase
      data/
      domain/
      presentation/
        mixins/     화면 전용 provider facade
        screens/    quotes 화면
    todos/
      todos_providers.dart
      application/
        controllers/  할 일 목록 controller
        providers/    사용자 id provider
        states/       mutation 포함 목록 상태
        usecases/   할 일 목록/추가/수정/삭제 usecase
      data/
      domain/
      presentation/
        mixins/     화면 전용 provider facade
        screens/    todos 화면
assets/
  images/          일반 이미지
  icons/           앱/feature 아이콘
```

자산 경로 문자열은 `lib/core/config/app_assets.dart` 에서 공통 관리합니다. 새 이미지를 추가할 때는 `AppAssets.image('file.png')`, 아이콘은 `AppAssets.icon('file.png')` 패턴으로 연결하면 경로 하드코딩을 줄일 수 있습니다.

## 3. 계층별 역할

### presentation

화면과 위젯이 있는 계층입니다.

- `Widget`, `ConsumerWidget`, `ConsumerStatefulWidget`
- feature 전용 `State/Event mixin class`
- 사용자 입력 처리
- provider 구독
- 로딩/에러/성공 상태 렌더링

여기서는 다음을 하지 않습니다.

- `Dio` 직접 호출
- repository 직접 호출
- 토큰 저장 직접 처리
- 비즈니스 규칙 판단

`presentation` 에서 provider 접근 지점이 많아질 경우에는 화면 전용 `State/Event mixin class` 로 `ref.watch/read` 와 controller 호출을 묶을 수 있습니다. 다만 이 mixin 은 provider facade 여야 하며, usecase 수준의 비즈니스 로직이나 repository 접근을 가지면 안 됩니다.

예시:

- `login_screen.dart`
- `splash_screen.dart`
- `home_screen.dart`

### application

화면 흐름과 상태 전이를 담당하는 계층입니다.

- Riverpod controller/provider
- usecase 호출
- 화면에서 필요한 상태 구성
- 여러 usecase 결과를 화면 상태로 변환

예시:

- `SessionController`
- `SignInController`
- `ProductsController`
- `ProductDetailController`

현재 템플릿은 `application/controllers`, `application/providers`, `application/states`, `application/usecases` 를 기본 구조로 사용합니다. `presentation` 도 `screens`, `mixins` 를 기본 하위 구조로 사용하며, 필요 시 `widgets`, `listeners` 를 추가합니다.

#### usecase 를 둔 이유

이 프로젝트에서 `usecase` 는 필요합니다.

왜냐하면 controller 가 커지기 시작하면 금방 아래 문제가 생기기 때문입니다.

- 인증/로그아웃/조회 로직이 controller 안에 뭉침
- 다른 화면이나 기능에서 같은 비즈니스 로직을 재사용하기 어려움
- 테스트 단위가 controller 하나로 커짐
- application 레이어가 data 구현 쪽으로 다시 기울어짐

그래서 이 템플릿에서는:

- controller 는 상태 관리
- usecase 는 비즈니스 흐름 처리

로 역할을 나눴습니다.

### domain

비즈니스의 중심 개념을 표현하는 계층입니다.

- entity
- value object
- repository interface

여기는 Flutter UI, Dio, SharedPreferences, SecureStorage, JSON 직렬화 를 모릅니다.

예시:

- `AuthRepository`
- `ProductsRepository`
- `AuthSession`
- `AuthTokens`
- `Product`

### data

실제 외부 시스템과 통신하는 계층입니다.

- remote datasource
- DTO
- repository 구현체

예시:

- `AuthRemoteDataSource`
- `ProductsRemoteDataSource`
- `AuthRepositoryImpl`
- `ProductsRepositoryImpl`

현재 DTO -> Entity 변환은 repository 구현체 내부 private mapper 로 처리합니다. 변환 분기가 커지거나 여러 응답 조합이 늘어나면 `data/mappers/` 를 도입합니다.

## 4. 의존 방향

이 프로젝트에서 의존 방향은 아래처럼만 허용합니다.

```text
presentation -> application(controller/provider/state) -> application/usecases
application/usecases -> domain(repository contract / entity)
data(repository impl / datasource / dto) -> domain(repository contract / entity)
data -> external(api, storage)
feature root providers -> data 구현체 조립
```

정확히는 다음 원칙으로 이해하면 됩니다.

- `presentation` 은 `application` 만 본다.
- `application` 은 `usecase` 를 호출한다.
- `usecase` 는 `domain repository contract` 를 사용한다.
- `data` 는 contract 를 구현한다.
- repository 구현체 조립은 feature 루트 provider 가 담당한다.

즉, 화면이 repository 구현체를 직접 보면 안 됩니다.

## 5. 앱 시작부터 홈 진입까지 흐름

### 1) 앱 시작

`lib/main.dart` -> `app/bootstrap.dart`

여기서 하는 일:

- Flutter 바인딩 초기화
- 웹이면 `PathUrlStrategy` 적용
- entrypoint 별 환경 override 적용
- 전역 Flutter/platform error hook 연결
- `ProviderScope` 시작
- `ProviderObserver` 연결

기본 monitoring 구현은 최근 breadcrumb 를 버퍼링하고, framework/platform/provider 에러가 발생하면 함께 출력합니다.
실서비스 연결이 필요해지면 `AppMonitoring` 구현체만 교체하면 됩니다.

### 2) 앱 생성

`app/app.dart`

여기서 하는 일:

- `appConfigProvider` 로 환경 정보 읽기
- 배너 적용
- `MaterialApp.router` 생성

### 3) 라우터 구성

`app/router/app_router.dart`

여기서 하는 일:

- splash, login, authenticated shell route 구성
- route module 단위 조립
- 인증 상태에 따라 redirect 수행

### 4) 세션 복구

`features/auth/application/controllers/session_controller.dart`

여기서 하는 일:

- splash 진입 시 `ensureSessionRestored()` 로 최초 1회 세션 복구 시작
- 내부적으로 `RestoreSessionUseCase` 실행
- 토큰 존재 여부 확인
- `auth/me` 확인
- 필요 시 `auth/refresh`
- 성공/실패 결과를 `SessionState` 로 변환

### 5) 화면 이동

`app_route_guard.dart`

여기서 하는 일:

- `unknown` 이면 splash 유지
- `restorationFailed` 이면 splash 유지 + 재시도 UI
- `unauthenticated` 이면 login 이동
- `authenticated` 이면 shell/home 진입

### 6) 페이지 전용 route argument 관리

상품 상세처럼 route argument 를 여러 하위 위젯에서 함께 써야 하는 화면은 페이지 내부에 별도 `ProviderScope` 를 열고 argument provider 를 override 하는 방식을 사용합니다.

- 페이지 진입점이 `productId` 를 받음
- 페이지 최상단 `ProviderScope` 에서 `productDetailArgumentProvider.overrideWithValue(productId)` 수행
- 하위 위젯과 controller 는 동일한 argument provider 를 참조
- presentation 에서 `productId` 를 자식 위젯마다 계속 전달하지 않음

이 방식은 page-scoped 상태에 적합합니다. 전역 app scope 나 feature root provider 에 route argument 를 섞지 않는 것이 중요합니다.

## 6. Riverpod 사용 규칙

이 프로젝트에서는 Riverpod 를 다음처럼 사용합니다.

### class-based provider

상태 전이와 액션이 있는 경우 사용합니다.

예시:

- `SessionController`
- `SignInController`
- `ProductsController`

언제 쓰나:

- `refresh()`, `signIn()`, `signOut()` 같은 액션이 필요할 때
- 단순 조회를 넘어서 상태 변화가 있을 때

### 일반 Provider

조립이나 설정 객체 주입용으로 사용합니다.

예시:

- `appConfigProvider`
- `dioProvider`
- `authRepositoryProvider`
- `productsRepositoryProvider`
- 각 usecase provider

feature 루트의 `auth_providers.dart`, `home_providers.dart` 는 현재 repository wiring 전용 공개 진입점으로 사용합니다. 화면 전용 provider 나 내부 helper provider 는 여기에 추가하지 않습니다.

정리하면:

- controller 와 application 성격 provider 는 generator 기반 `@riverpod` / `@Riverpod` 를 우선 사용합니다.
- page-scoped override, 명시적 dependency, `keepAlive` 제어, 세션/앱 상태 파생값처럼 provider 자체 계약이 중요한 경우도 generator 기반이 우선입니다.
- repository wiring, datasource wiring, usecase wiring, router/config/logger/storage 조립은 plain `Provider` 를 유지합니다.

### Observer

`core/logging/app_provider_observer.dart`

여기서 provider 변경/실패를 관찰합니다.  
나중에 Crashlytics, Sentry, Datadog 같은 도구를 붙일 때 여기서 확장하면 됩니다.

## 7. go_router 사용 규칙

현재 라우팅 구조는 다음 원칙을 따릅니다.

- 공개 페이지: `splash`, `login`
- 인증 필요 페이지: authenticated shell 하위
- 인증 가드: top-level `redirect`
- 확장 방향: shell 하위에 feature route 를 추가하되, 인증 후 feature 가 2~3개를 넘기기 시작하면 feature 단위 route builder 또는 route module 로 분리

현재 역할 분리는 아래 기준으로 유지합니다.

- `app_routes.dart`: path/name 상수
- `route_modules/*`: feature route 정의
- `app_route_guard.dart`: 인증 redirect 정책
- `app_router.dart`: 최종 `GoRouter` 조립
- `authenticated_shell.dart`: 인증 후 공통 scaffold

### 왜 shell route 를 썼는가

단일 홈 화면만 있을 때는 단순 route 로도 충분합니다.  
하지만 실제 프로젝트에서는 아래가 자주 생깁니다.

- 공통 app bar / bottom navigation
- 탭 기반 구조
- 인증 후 공통 레이아웃

그래서 미리 `AuthenticatedShell` 구조를 넣어 두었습니다.

## 8. 공통 core 계층 설명

### config

- `AppConfig`
- `AppEnvironment`
- `AppFlavors`

역할:

- `API_BASE_URL`
- `APP_ENV`
- 환경별 기본 설정 중앙화
- 환경별 entrypoint 와 bootstrap override
- 앱 이름/배너 노출

### logging

- `AppLogger`
- `AppMonitoring`
- `AppProviderObserver`

역할:

- debug/info/error 로그 출력
- provider 실패 및 전역 오류 관측성 훅 연결
- 나중에 Sentry/Crashlytics 로 교체 가능한 확장 포인트

### network

- `Dio` 생성
- 인증 헤더 interceptor
- 네트워크 로그 interceptor
- `AppException`

역할:

- HTTP 연결 설정
- 공통 timeout
- Authorization 헤더 자동 주입
- 네트워크 오류 메시지 표준화

### errors

- `AppFailure`

역할:

- application/usecase 에서 다룰 수 있는 공통 실패 타입
- `network`, `unauthorized`, `validation`, `server`, `unknown`

### result

- `Result<T>`
- `Success<T>`
- `Failure<T>`

역할:

- usecase 가 성공/실패를 명시적으로 반환
- controller 가 이를 해석해 화면 상태로 변환
- 실패 타입은 `AppFailure` 로 통일

### storage

- `TokenStorage`
- `SecureTokenStorage`
- `SharedPreferencesTokenStorage`

역할:

- 웹/모바일 저장 전략 분리
- application 은 구현체를 몰라도 됨
- 저장소는 access/refresh token 문자열 저장 책임만 가짐

## 9. 새 기능을 추가할 때 기본 절차

예를 들어 `profile` 기능을 새로 추가한다고 가정하겠습니다.

### 1) feature 폴더 생성

```text
lib/features/profile/
  application/
    usecases/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    value_objects/
  presentation/
  profile_providers.dart
```

### 2) domain 부터 정의

먼저 아래를 만듭니다.

- entity
- value object
- repository contract

예시:

- `Profile`
- `ProfileRepository`

### 3) data 구현

다음 순서로 만듭니다.

1. DTO
2. RemoteDataSource
3. RepositoryImpl

즉, feature 단위 큰 흐름은 `domain` 개념을 먼저 잡고,  
API 하나를 실제로 붙일 때의 세부 순서는 아래 10장 기준으로 진행하면 됩니다.

즉, API 응답 형식에 가까운 것은 `data/models` 에 두고,  
앱에서 사용하는 개념은 `domain/entities` 에 둡니다.

### 4) feature provider 조립

`profile_providers.dart` 에서 구현체를 묶습니다.

예시:

```dart
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
});
```

### 5) usecase 작성

예시:

- `GetProfileUseCase`
- `UpdateProfileUseCase`

규칙:

- controller 는 usecase 만 호출
- usecase 는 repository contract 만 사용
- usecase 는 가능하면 `Result<T>` 반환

### 6) controller/provider 작성

화면에서 필요한 상태 단위로 만듭니다.

예시:

- 조회면 `AsyncNotifier`
- 읽기 전용 목록 조회면 `PageChunk<T> + AsyncNotifier + PaginatedListState`
- mutation 이 섞인 목록 조회면 feature 전용 paginated state
- 저장/수정 액션이면 별도 controller

목록 조회 controller 기본 규칙:

- 첫 페이지는 `build()` 에서 로드
- 강제 새로고침은 `refresh()`
- 단건 상세 조회는 `refresh()` 에서 현재 key 캐시만 비움
- 다음 페이지는 `loadMore()`
- 다음 페이지 실패는 전체 화면 에러 대신 `loadMoreFailure` 로 분리
- `hasMore` 는 가능하면 `PageChunk.total` 기준으로 계산
- local-only 항목, 삭제 반영, optimistic merge 가 있으면 `loadedRemoteCount` 와 `remoteTotalCount` 를 분리해 관리
- mutation 성공 뒤에는 관련 조회 usecase 캐시를 비워 다음 refresh/loadMore 가 새 데이터를 보게 함
- 같은 요청 중복 호출은 usecase 캐시에서 합칠 수 있음

### 7) 화면 작성

`presentation` 에서:

- controller 상태 구독
- 로딩/에러/성공 분기
- 버튼 이벤트 전달

### 8) 라우터 연결

새 화면이 로그인 필요 화면이면 shell route 하위의 feature route module 에 추가합니다.

## 10. 새 API 를 추가할 때 정확한 작업 순서

여기서부터가 가장 중요합니다.

예를 들어 `GET /todos` API 를 추가한다고 가정하겠습니다.

### Step 1. API 응답 확인

먼저 응답 구조를 확인합니다.

예시 응답:

```json
{
  "todos": [
    {
      "id": 1,
      "todo": "Write docs",
      "completed": false,
      "userId": 7
    }
  ]
}
```

### Step 2. DTO 작성

`data/models` 에 API 응답용 DTO 를 만듭니다.

예시:

- `todo_dto.dart`
- `paginated_todos_response_dto.dart`

규칙:

- API 응답 key 와 최대한 1:1
- `freezed` + `json_serializable` 사용
- nullable 여부를 실제 응답 기준으로 맞춤

### Step 3. domain entity 작성

`domain/entities` 에 앱에서 사용할 모델을 만듭니다.

예시:

- `todo.dart`

규칙:

- 화면이 진짜로 필요로 하는 개념으로 정의
- DTO 를 그대로 들고 가지 않음
- domain entity/value object 에 `fromJson/toJson` 를 넣지 않음

### Step 4. repository contract 작성

`domain/repositories` 에 contract 를 추가합니다.

예시:

```dart
abstract interface class TodosRepository {
  Future<PageChunk<Todo>> fetchTodosByUser({
    required int userId,
    required int limit,
    required int skip,
  });
}
```

규칙:

- usecase 는 이 contract 만 바라봄
- data 구현 상세는 contract 밖으로 새지 않음

### Step 5. datasource 작성

`data/datasources` 에 실제 HTTP 호출 코드를 둡니다.

규칙:

- HTTP path, query, body, options 는 여기서 관리
- `DioException` 을 `AppException` 으로 변환
- UI 친화 메시지 조합은 여기서 최소화

예시:

```dart
final todosRemoteDataSourceProvider = Provider<TodosRemoteDataSource>((ref) {
  return TodosRemoteDataSource(dio: ref.watch(dioProvider));
});
```

### Step 6. repository 구현

`data/repositories` 에서 DTO -> Entity 매핑을 수행합니다.

규칙:

- datasource 는 DTO 반환
- repository 는 entity 반환
- 매핑 로직은 repository 내부 private method 로 정리

### Step 7. feature provider 조립

`feature_providers.dart` 에 구현체 연결

예시:

```dart
final todosRepositoryProvider = Provider<TodosRepository>((ref) {
  return TodosRepositoryImpl(ref.watch(todosRemoteDataSourceProvider));
});
```

feature root provider 파일은 repository 구현체 조립 지점이며,  
usecase provider 는 필요 시 feature provider 와 `core` provider 를 함께 사용해 의존성을 주입받습니다.

### Step 8. usecase 작성

예시:

```dart
final getTodosUseCaseProvider = Provider<GetTodosUseCase>((ref) {
  return GetTodosUseCase(ref.watch(todosRepositoryProvider));
});
```

### Step 9. controller/provider 작성

예시:

```dart
@riverpod
class TodosController extends _$TodosController {
  @override
  Future<TodosListState> build() => _load();

  Future<TodosListState> _load() async {
    final result = await ref.read(getTodosUseCaseProvider).call(
      userId: 1,
      limit: 20,
      skip: 0,
    );
    return result.when(
      success: (page) => TodosListState(
        items: page.items,
        pageSize: 20,
        remoteTotalCount: page.total,
        loadedRemoteCount: page.items.length,
        localOnlyCount: 0,
      ),
      failure: (error) => throw error,
    );
  }
}
```

`todos` 처럼 목록 조회에 추가/수정/삭제가 함께 얹히는 화면은 `PaginatedListState` 대신 feature 전용 state 를 두는 편이 안전합니다.  
이유는 local-only 항목이 생기면 화면에 보이는 `items.length` 와 다음 요청의 `skip` 값이 달라질 수 있기 때문입니다.

### Step 10. 화면 연결

마지막으로 `presentation` 에서 사용합니다.

## 11. 새 API 추가 시 자주 하는 실수

### 실수 1. 화면에서 Dio 직접 호출

하지 않습니다.

- 잘못된 예: `login_screen.dart` 에서 `dio.get(...)`
- 올바른 예: 화면 -> controller -> usecase -> repository -> datasource

### 실수 2. DTO 를 화면까지 전달

하지 않습니다.

- DTO 는 `data`
- Entity 는 `domain`
- 화면은 Entity 또는 화면용 state 만 사용

### 실수 2-1. domain 에 JSON 책임 넣기

하지 않습니다.

- 잘못된 예: `domain/entity` 에 `fromJson/toJson`
- 올바른 예: JSON 은 DTO 에만 두고 repository 에서 DTO -> Entity 매핑

### 실수 3. controller 에 비즈니스 로직을 몰아넣기

하지 않습니다.

- controller 는 상태 전이
- usecase 는 비즈니스 로직

### 실수 4. repository 구현체를 application 에서 직접 import

하지 않습니다.

- 구현 조립은 feature root provider 파일에서만

### 실수 5. 예외를 무조건 throw 만 사용

가능하면 usecase 에서 `Result<T>` 로 감싸고,  
controller 에서 화면 상태에 맞는 에러로 바꿉니다.

## 12. 새 화면만 추가할 때는 어떻게 하나

API 없이 정적 화면만 추가한다면 더 단순합니다.

### 로그인 필요 화면

1. `presentation` 에 새 screen 추가
2. 현재 feature route module 에 route 추가
3. 필요한 controller/provider 가 있으면 feature application 에 추가

### 로그인 불필요 화면

1. `presentation` 에 screen 추가
2. 현재 auth/public route module 에 공개 route 추가
3. `AppRoute` enum 업데이트

## 13. 테스트는 어디까지 해야 하나

이 템플릿에서는 최소 아래를 권장합니다.

### usecase 테스트

- 성공 케이스
- validation 실패
- unauthorized 실패
- network 실패

### controller 테스트

- 상태 전이 확인
- usecase 결과가 state 에 잘 반영되는지 확인

### route guard 테스트

- unauthenticated -> login
- authenticated -> home
- restorationFailed -> splash 유지

### widget 테스트

필수는 아니지만 아래는 권장합니다.

- 로그인 실패 메시지 노출
- 홈 목록 렌더링

## 14. 이 템플릿을 계속 좋게 유지하려면

다음 규칙만 지켜도 구조가 쉽게 무너지지 않습니다.

1. 새 기능은 무조건 feature 폴더로 추가합니다.
2. 화면은 repository 를 직접 호출하지 않습니다.
3. controller 는 usecase 만 호출합니다.
4. 구현체 조립은 feature root provider 파일에서만 합니다.
5. DTO 와 entity 를 섞지 않습니다.
6. 공통 설정은 `core`, 기능 로직은 `features` 에 둡니다.
7. route 추가 시 공개 route / 인증 route 를 명확히 나눕니다.

## 15. 추천 작업 순서

새 기능을 만들 때는 아래 순서가 가장 안전합니다.

1. API 응답 확인
2. DTO 작성
3. Entity 작성
4. Repository contract 작성
5. DataSource 작성
6. RepositoryImpl 작성
7. Feature provider 조립
8. UseCase 작성
9. Controller 작성
10. Screen 작성
11. Route 연결
12. Test 작성

## 16. 마지막 요약

이 프로젝트는 다음 문장으로 이해하면 됩니다.

`화면은 상태를 보여주고, controller는 상태를 바꾸고, usecase는 일을 처리하고, repository는 데이터를 가져오고, datasource는 외부와 통신한다.`

새 API 를 추가할 때도 이 규칙만 지키면 구조가 무너지지 않습니다.
