# 스타터킷 아키텍처 운영 규칙

이 문서는 현재 `riverpod_origin_template` 의 구조를 보수적으로 유지하면서, 새 기능 추가와 리팩터링 시 판단 기준을 명확히 남기기 위한 운영 문서입니다.

핵심 원칙은 아래 한 문장입니다.

`화면은 상태를 보여주고, controller는 상태를 관리하고, usecase는 일을 처리하고, repository는 데이터를 추상화하고, datasource는 외부와 통신한다.`

## 현재 권장 트리

현재 스타터킷은 아래 구조를 기본으로 유지합니다.

```text
lib/
  app/
    router/
      route_modules/
      widgets/
    theme/
    widgets/
  core/
    config/
    errors/
    logging/
    network/
    pagination/
    presentation/
    result/
    storage/
  features/
    <feature>/
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
      <feature>_providers.dart
```

이 구조는 이미 계층 분리가 잘 되어 있으므로, 지금 단계에서는 대규모 폴더 이동보다 역할 규칙을 명확히 문서화하는 편이 이득이 큽니다.

## 레이어 책임

### presentation

- 화면과 위젯, 화면 전용 facade 성격의 mixin class 를 둡니다.
- `ref.watch/read`, controller 호출 위임, 단순 파생 상태까지만 담당합니다.
- repository, datasource, storage 구현체를 직접 알면 안 됩니다.
- 파일 수가 늘어나면 `screens/`, `widgets/`, `mixins/`, `listeners/` 로 분리합니다.

### application

- UI 와 domain/data 를 연결하는 오케스트레이션 계층입니다.
- controller, feature-level state, page-scoped argument provider, usecase 를 둘 수 있습니다.
- API 직접 호출 구현, DTO, Widget UI, domain entity 는 두지 않습니다.
- 읽기 전용 목록은 `PageChunk<T> + AsyncNotifier + PaginatedListState` 조합으로 `refresh`, `load more`, `loadMoreFailure` 를 함께 다루는 패턴을 기본값으로 사용합니다.
- 추가/수정/삭제가 함께 섞여 local-only 항목 또는 optimistic merge 가 필요한 목록은 `skip`, `total` 계산이 달라질 수 있으므로 feature 전용 paginated state 를 둘 수 있습니다.
- 현재는 feature별 루트 파일 수가 아직 작으므로 `controllers/`, `states/`, `providers/` 하위 폴더를 강제하지 않습니다.
- 아래 조건이 생기면 하위 폴더 분리를 검토합니다.
  - 생성 파일을 제외한 서로 다른 성격의 루트 파일이 5개 이상 섞이는 경우
  - controller/state/provider 탐색 비용이 눈에 띄게 커지는 경우

### domain

- entity, value object, repository contract 만 둡니다.
- DTO, JSON 직렬화, storage 구현, network 구현 타입을 직접 참조하지 않습니다.

### data

- datasource, 외부 응답 모델, repository 구현을 둡니다.
- DTO -> Entity 변환 책임은 data 에 둡니다.
- 현재처럼 변환이 단순하면 repository 구현체 내부 private mapper 로 유지합니다.
- 아래 조건이 생기면 `data/mappers/` 도입을 검토합니다.
  - 매핑 분기가 많아지는 경우
  - 여러 DTO 를 하나의 entity 로 조합하는 경우
  - repository 구현체가 과도하게 길어지는 경우

## Provider 배치 규칙

### feature 루트 `<feature>_providers.dart`

- feature DI entrypoint 로 사용합니다.
- repository implementation 과 datasource 를 조립하는 공개 provider 만 둡니다.
- 화면 전용 provider, 테스트 편의용 override, 내부 helper provider 까지 한 파일에 모으지 않습니다.

### application/usecases

- usecase class 와 usecase provider 를 같은 파일에 둡니다.
- usecase provider 는 feature 루트 provider 와 `core` 공통 provider 를 조합해 의존성을 주입받습니다.
- 조회 usecase 는 성공 결과만 메모이즈하고, 같은 요청의 동시 호출은 in-memory 에서 합쳐 중복 fetch 를 줄일 수 있습니다.
- 단건 상세 조회는 보통 entity id 같은 key 단위 캐시와 key 단위 invalidation 으로 유지합니다.
- 목록 조회 contract 는 가능하면 `PageChunk<T>` 로 `items`, `total`, `skip`, `limit` 를 함께 전달해 정확한 pagination 판단 기준을 유지합니다.
- mutation 목록은 `PageChunk<T>` 계약을 유지하되, application state 에 `loadedRemoteCount`, `remoteTotalCount` 같은 추가 메타데이터를 둘 수 있습니다.
- mutation 성공 뒤에는 관련 목록 조회 usecase 캐시를 비워 stale page 를 재사용하지 않도록 유지합니다.

### page-scoped provider

- 특정 화면 route argument 처럼 페이지 범위에서만 의미가 있는 provider 는 `application` 에 두고, 페이지 진입점의 `ProviderScope` override 로 주입합니다.
- 전역 app scope 나 feature 루트 provider 파일로 끌어올리지 않습니다.

## 라우팅 운영 규칙

- `app_routes.dart`: path/name 상수와 location 생성만 담당합니다.
- `route_modules/*`: feature route 정의만 담당합니다.
- `app_route_guard.dart`: 인증 redirect 정책만 담당합니다.
- `app_router.dart`: 최종 `GoRouter` 조립만 담당합니다.
- `authenticated_shell.dart`: 인증 후 공통 layout/scaffold 역할만 담당합니다.

현재 구현은 위 책임 분리가 잘 유지되고 있으므로, guard 로직을 route module 로 분산하지 않습니다.

## 공통 UI 와 `core/presentation`

`lib/core/presentation` 은 현재 공통 UI 조각과 렌더 helper 를 두는 위치로 유지합니다.

- `AsyncValueView` 처럼 feature 비종속 공통 위젯을 둘 수 있습니다.
- 아직 공통 UI 양이 크지 않으므로 `core/widgets` 또는 `shared/` 로 즉시 이동하지 않습니다.
- 공통 UI, formatter, extension, reusable widget 이 늘어나면 아래 기준으로 분리합니다.
  - 시스템 인프라 성격이면 `core`
  - feature 간 재사용 UI/헬퍼 성격이면 `shared`

## Storage 선택 정책

- `TokenStorage` 는 저장 계약입니다.
- 모바일/데스크톱 기본 구현은 `SecureTokenStorage` 입니다.
- 웹 환경에서는 플랫폼 제약 때문에 `SharedPreferencesTokenStorage` 를 사용합니다.
- `SharedPreferencesTokenStorage` 는 비민감 데모 저장소가 아니라 웹용 대체 구현입니다.
- access token / refresh token 저장과 삭제는 `TokenStorage` 계약 안에서 함께 처리합니다.
- 세션 삭제는 인증 무효(`401`, `403`)가 명확할 때만 수행합니다.

## 네이밍 정책

- 화면 파일은 `*_screen.dart` 를 표준으로 유지합니다.
- `data/models` 폴더는 외부/로컬 데이터 모델 보관 위치로 유지합니다.
- 현재 폴더명은 `models` 이지만, 파일명은 `*_dto.dart` 로 유지해 DTO 임을 드러냅니다.
- `*_presentation_mixins.dart` 는 실제 mixin class 를 담고 있을 때만 유지합니다.
- 더 이상 mixin 이 아니고 helper/listener 모음이 되면 `*_presentation_helpers.dart` 또는 `listeners/` 로 분리합니다.

## 새 Feature 추가 템플릿

새 feature 는 아래 구조를 기준으로 시작합니다.

```text
features/
  example_feature/
    application/
      usecases/
      example_controller.dart
      example_state.dart
    data/
      datasources/
      models/
      repositories/
    domain/
      entities/
      repositories/
      value_objects/
    presentation/
      example_screen.dart
    example_feature_providers.dart
```

추가 순서는 아래를 권장합니다.

1. `data/models` 에 DTO 작성
2. `domain/entities` 에 Entity 작성
3. `domain/repositories` 에 contract 작성
4. `data/datasources` 에 외부 호출 작성
5. `data/repositories` 에 DTO -> Entity 매핑 작성
6. `<feature>_providers.dart` 에 repository 조립
7. `application/usecases` 에 usecase 작성
8. `application` 에 controller/state/provider 작성
9. `presentation` 에 화면 연결
10. route module 과 테스트 추가

## 판단 메모

- `application` 하위 분리: 현재 파일 수와 책임 복잡도가 아직 낮아서 보류, 대신 하위 폴더 도입 기준을 문서화.
- `presentation` 하위 구조: 현재 파일 수가 적고 mixin class 도 실제 mixin 이라서 유지, 증가 시 `screens/widgets/mixins/listeners` 로 분리.
- `auth_providers.dart`, `home_providers.dart`: 현재는 repository wiring 전용이라 유지.
- `app_router.dart` / `app_route_guard.dart` / `route_modules/*`: 조립, 정책, 페이지 정의가 이미 분리되어 있어 구조 변경 불필요.
- `authenticated_shell.dart`: 공통 scaffold 역할만 수행하고 있어 유지.
- `core/presentation/async_value_view.dart`: 공통 Widget 성격이지만 현재 `core/presentation` 이 공통 UI helper 위치로 기능하고 있어 유지.
- `core/storage/*`: 모바일은 secure storage, 웹은 shared preferences 로 역할이 분명하므로 정책만 명확히 문서화.
- `*_repository_impl.dart`: DTO -> Entity 매핑이 단순해서 별도 mapper 폴더 도입 보류.
- `data/models` vs `dtos`: 현재 파일명에서 DTO 의미가 이미 드러나므로 폴더 이동보다 규칙 문서화가 더 보수적.
- `shared/` 계층: 아직 공통 UI/헬퍼 규모가 작아서 도입 보류.
