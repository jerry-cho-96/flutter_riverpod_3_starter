# AGENTS.md

이 파일은 이 저장소에서 작업하는 AI agent 를 위한 실행 규칙입니다.  
이 프로젝트는 `Riverpod 3 + go_router + usecase + repository pattern` 을 기준으로 설계되어 있으며, agent 는 아래 규칙을 반드시 따라야 합니다.
목적은 기존 아키텍처와 프로젝트 판단을 유지하면서, 최소 수정으로 정확하게 구현하고 안전하게 검증하는 것입니다.

## 1. 기본 원칙

- 모든 설명, 커밋 메시지 초안, 문서 작성은 한국어로 작성합니다.
- 실수로라도 실제 비밀값을 커밋하지 않습니다.
- base URL, token, env 값은 예시값 또는 `--dart-define` 기반 설정만 사용합니다.
- 구조를 바꿀 때는 “작동”보다 “계층 일관성”을 우선합니다.
- 구조를 바꿀지 애매하면 먼저 `docs/ARCHITECTURE.md` 의 운영 기준과 판단 메모를 확인합니다.

## 1-1. 문서 우선순위

이 저장소에서 문서 충돌이나 판단 애매함이 생기면 아래 우선순위를 따릅니다.

1. `AGENTS.md`
2. `docs/ARCHITECTURE.md`
3. `docs/PROJECT_GUIDE.md`
4. `README.md`

해석 원칙:

- `AGENTS.md` 는 agent 실행 규칙과 강제 제약의 기준입니다.
- `docs/ARCHITECTURE.md` 는 구조 유지/분리 판단 기준과 스타터킷 운영 규칙의 기준입니다.
- `docs/PROJECT_GUIDE.md` 는 실제 코드 흐름과 구현 의도를 설명하는 가이드입니다.
- `README.md` 는 빠른 온보딩, 실행 방법, 개요 확인용입니다.

문서 간 표현 차이가 있으면 상위 우선순위 문서를 기준으로 해석하고, 필요하면 하위 문서도 함께 최신화합니다.

## 1-2. 작업 유형별 참조 순서

작업을 시작할 때는 아래 순서로 문서를 참조합니다.

### 구조 변경 / 리팩터링

1. `AGENTS.md`
2. `docs/ARCHITECTURE.md`
3. 관련 feature 코드
4. `docs/PROJECT_GUIDE.md`

### 새 feature / 새 API 추가

1. `AGENTS.md`
2. `docs/ARCHITECTURE.md`
3. 동일 성격의 기존 feature 코드
4. `docs/PROJECT_GUIDE.md`
5. `README.md`

### 라우팅 / 세션 / 인증 흐름 수정

1. `AGENTS.md`
2. `docs/ARCHITECTURE.md`
3. `docs/PROJECT_GUIDE.md`
4. `lib/app/router/*`, `features/auth/*`

### 환경설정 / 실행 / 문서 확인

1. `README.md`
2. `AGENTS.md`
3. `docs/PROJECT_GUIDE.md`
4. 관련 설정 파일

### 판단 원칙

- 문서만 보고 충분히 결정 가능한 내용이면 구조를 성급히 바꾸지 않습니다.
- 문서와 실제 코드가 다르면 코드를 확인한 뒤 문서를 최신화합니다.
- 애매하면 기존 feature 의 배치 패턴을 우선 따르고, 필요할 때만 새 규칙을 도입합니다.

## 1-3. 멀티 에이전트 운영 모델

이 저장소의 복잡한 작업은 기본적으로 `explorer -> implementer -> reviewer` 3단계 구조를 사용할 수 있습니다.

### MUST

- 모든 agent 는 본 문서와 문서 우선순위를 동일하게 따릅니다.
- `explorer` 는 코드 탐색, 원인 분석, 변경 범위 정의만 수행합니다.
- `explorer` 는 코드를 수정하지 않습니다.
- `implementer` 는 승인된 변경 범위 안에서만 최소 패치를 적용합니다.
- `implementer` 는 구현 후 `dart format`, `flutter analyze`, 필요한 `flutter test` 를 수행합니다.
- `reviewer` 는 구현 결과를 독립적으로 검토하고, 직접 수정하지 않습니다.
- 각 agent 는 다음 단계가 바로 사용할 수 있는 구조화된 결과를 남겨야 합니다.
- 아래 조건 중 하나라도 만족하면 멀티 에이전트 구조를 반드시 사용합니다.
  - 원인이 명확하지 않은 경우
  - 2개 이상의 레이어를 동시에 수정하는 경우
  - 리팩터링 또는 구조 변경인 경우
  - 인증/세션/라우팅/DI/API 매핑에 영향을 주는 경우
  - 변경 범위가 feature 를 넘어가는 경우
  - 회귀 위험이 중간 이상인 경우
- 동작 변경이 있는 작업은 최소 `implementer -> reviewer` 를 반드시 사용합니다.
- `explorer -> implementer -> reviewer` 는 반드시 순차적으로 실행합니다.
- `implementer` 는 `explorer` 의 최종 결과가 완전히 확정되기 전에는 시작하면 안 됩니다.
- `reviewer` 는 `implementer` 의 최종 결과와 검증 결과가 완전히 확정되기 전에는 시작하면 안 됩니다.
- 역할을 내부적으로 흉내 내는 방식(simulation)으로 대체하지 않고, 실제 subagent 실행을 사용합니다.

### SHOULD

- 복잡한 리팩터링, 다층 영향 변경, 원인 불명확 작업은 멀티 에이전트 구조를 우선 사용합니다.
- 단순 UI 수정이나 국소 버그 수정은 단일 agent 로 처리할 수 있습니다.
- 각 agent 는 판단 근거를 본 문서의 규칙과 연결해서 설명합니다.
- 아래 조건을 모두 만족하면 단일 agent 사용이 가능합니다.
  - 1~2개 파일만 수정
  - 원인이 명확
  - 구조 영향 없음
  - 회귀 위험 낮음

### AVOID

- `explorer` 가 구현까지 진행하는 것
- `implementer` 가 승인 범위 없이 수정 범위를 넓히는 것
- `reviewer` 가 리뷰 대신 직접 코드를 고치는 것

## 2. 이 프로젝트의 정답 아키텍처

이 저장소의 기본 계층은 아래와 같습니다.

```text
presentation -> application(controller/provider) -> application/usecases
application/usecases -> domain(repository contract / entity)
data(repository impl / datasource / dto) -> domain(repository contract / entity)
data -> external(api, storage)
```

반드시 지켜야 하는 규칙:

- `presentation` 은 repository 를 직접 호출하면 안 됩니다.
- `presentation` 은 `Dio`, `SharedPreferences`, `FlutterSecureStorage` 를 직접 사용하면 안 됩니다.
- `application` 은 repository 구현체를 직접 import 하면 안 됩니다.
- `application` 은 controller 뿐 아니라 feature-level state, page-scoped provider 를 포함할 수 있습니다.
- controller 는 usecase 만 통해서 의존성을 받아야 합니다.
- usecase provider 는 feature root provider 와 `core` 의 공통 provider 를 조합해 의존성을 주입받을 수 있습니다.
- `usecase` 는 repository contract 를 사용해야 하며, data 구현 상세를 몰라야 합니다.
- `domain` 은 DTO, JSON 직렬화, storage 구현, network 구현 타입을 직접 참조하면 안 됩니다.
- `data` 는 DTO -> Entity 변환을 담당합니다.
- repository 구현체 조립은 feature 루트 provider 파일에서 수행합니다.
- datasource provider 는 해당 `data/datasources` 파일 안에 둘 수 있습니다.
- 공통 infra provider(`dioProvider`, `tokenStorageProvider`, logger/monitoring 등)는 `core` 에 둡니다.
- 이 저장소의 기본 네이밍은 `<feature>_providers.dart` 입니다.
  - 예: `auth_providers.dart`, `home_providers.dart`

## 3. 폴더별 책임

### `lib/app`

- 앱 전체 부트스트랩
- 전역 라우터
- route module 조립
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
- 앱 전역 infra provider

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
    value_objects/
  presentation/
  <feature>_providers.dart
```

- `domain/value_objects` 는 feature 고유 value object 가 필요할 때 사용합니다.
- `core` 에는 feature 고유 entity/value object 를 두지 않습니다.

추가 배치 규칙:

- usecase provider 는 `application/usecases` 파일 안에 둡니다.
- repository provider 는 `<feature>_providers.dart` 에 둡니다.
- datasource provider 는 `data/datasources` 파일 안에 둡니다.
- controller 는 `application` 에 두고 codegen 파일(`*.g.dart`)과 함께 관리합니다.
- feature-level state 는 `application` 에 두고 controller 와 가까이 관리합니다.
- page-scoped route argument provider 는 `application` 에 둡니다.
- page-scoped route argument provider 는 반드시 route module 또는 화면 진입점 builder 의 `ProviderScope` override 로 주입합니다.
- page-scoped route argument provider 를 화면 내부에서 다시 `ProviderScope` 로 주입하지 않습니다.
- 화면은 route 진입점에서 override 된 page-scoped provider 를 소비만 해야 합니다.
- `application` 하위 폴더 분리는 아직 기본값이 아닙니다.
  - 현재처럼 파일 수가 작고 탐색 비용이 낮으면 루트 구조를 유지합니다.
  - 생성 파일을 제외한 서로 다른 성격의 루트 파일이 5개 이상 섞이기 시작하면 `controllers/`, `states/`, `providers/`, `usecases/` 분리를 검토합니다.

## 4. Riverpod 규칙

- side effect 와 상태 전이가 있으면 class-based provider 를 사용합니다.
- 단순 조립/설정/의존성 주입은 `Provider` 를 사용합니다.
- controller 는 usecase 만 호출합니다.
- provider 안에서 UI 관련 로직을 만들지 않습니다.
- provider 이름은 역할이 드러나야 합니다.
  - 예: `sessionControllerProvider`, `signInUseCaseProvider`
- feature 루트 `<feature>_providers.dart` 는 repository wiring 용 공개 DI entrypoint 로 유지합니다.
- 화면 전용 provider, 내부 helper provider, 테스트 override 용 provider 를 `<feature>_providers.dart` 에 한꺼번에 모으지 않습니다.

권장 패턴:

- 저장/로그인/로그아웃: controller + usecase
- 목록 조회: `AsyncNotifier` controller
- 설정 주입: `Provider`

### Riverpod 실행 규칙

- `ref.watch` 는 UI 반응형 구독에 사용합니다.
- `ref.read` 는 이벤트/액션 트리거에 사용합니다.
- build 과정에서 직접 side effect 를 발생시키지 않습니다.
- page-scoped provider override 가 필요한 값은 화면 진입점 `ProviderScope` 에서만 주입합니다.
- page-scoped provider override 는 route builder, shell child builder, 또는 화면 진입 직전 wrapper 에서만 수행합니다.
- `ConsumerWidget`/`ConsumerStatefulWidget` 내부에서 argument 전달을 위해 새 `ProviderScope` 를 다시 여는 방식을 금지합니다.
- session/global provider 와 화면 전용 provider 의 수명을 혼동하지 않습니다.

### AVOID

- 화면 build 과정에서 직접 API 호출 시작
- 전역 provider 와 page-scoped provider 책임 혼합
- 화면 내부에서 page-scoped argument 를 다시 `ProviderScope` 로 재주입
- `<feature>_providers.dart` 에 내부 helper/provider 를 무분별하게 누적

## 5. go_router 규칙

- 인증이 필요 없는 화면은 공개 route 로 둡니다.
- 인증이 필요한 화면은 authenticated shell 하위에 둡니다.
- 인증 가드는 top-level `redirect` 에서 처리합니다.
- 로그인 여부 판정은 `SessionState` 만 기준으로 합니다.
- 현재 템플릿은 이미 `app/router/route_modules` 로 route 조립을 분리하고 있습니다.
- 새 인증 필요 화면은 해당 feature route module 에 추가합니다.
- 새 공개 화면은 auth/public route module 에 추가합니다.
- `app_router.dart` 는 module 조립과 redirect 유지가 우선이며, 상세 route 정의를 여기에 계속 누적하지 않습니다.
- `app_routes.dart` 는 path/name 상수와 location 생성만 담당합니다.
- `app_route_guard.dart` 는 인증 redirect 정책만 담당합니다.
- `route_modules/*` 는 feature route 정의만 담당합니다.
- `authenticated_shell.dart` 는 인증 후 공통 scaffold/layout 역할만 담당합니다.
- protected feature 가 2~3개를 넘기기 시작하면 계속 feature 단위 route module 조립을 유지합니다.

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
- domain entity/value object 에 `fromJson/toJson` 추가

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
10. 필요 시 해당 route module 과 `AppRoute` 에 route 추가
11. 테스트 작성

### API 추가 시 금지사항

- 화면에서 `dio.get/post/...` 직접 호출 금지
- DTO 를 화면까지 전달 금지
- repository 구현체를 controller 에서 직접 import 금지
- domain entity/value object 에 `fromJson/toJson` 추가 금지
- 예외를 문자열로 아무렇게나 처리 금지

### DTO / 매핑 규칙

- `data/models` 폴더는 외부/로컬 데이터 모델 보관 위치로 유지합니다.
- 파일명은 `*_dto.dart` 형태로 DTO 임을 드러냅니다.
- DTO -> Entity 변환은 우선 `data/repositories/*_impl.dart` 내부 private mapper 로 둡니다.
- 매핑 분기가 많아지거나 repository 구현체가 길어지면 `data/mappers/` 도입을 검토합니다.

## 8. 에러 처리 규칙

- network layer 는 `AppException`
- application/usecase layer 는 `AppFailure`
- usecase 는 가능하면 `Result<T>` 를 반환하고, 실패 타입은 `AppFailure` 로 통일합니다.
- controller 는 `Result<T>` 를 해석해 화면 상태로 변환합니다.
- UI 와 공통 presentation helper 는 `AppFailure` 만 직접 해석합니다.
- 인증 토큰 삭제는 `401/403` 처럼 실제 인증 무효로 판단되는 경우에만 수행합니다.
- 일시적 네트워크 실패로 세션을 지우면 안 됩니다.

## 9. UI 규칙

- 기존 테마와 색상 방향을 유지합니다.
- 새로운 화면도 현재 디자인 톤을 크게 벗어나지 않게 작성합니다.
- 로딩/에러/재시도 패턴은 `core/presentation` 공통 위젯을 우선 사용합니다.
- shell route 구조가 있으면 공통 scaffold 를 재사용합니다.
- `presentation` 에서 provider 접근 지점이 많아지면 화면 전용 mixin class 로 `ref.watch/read` 를 정리할 수 있습니다.
- `*_presentation_mixins.dart` 는 실제 mixin class 인 경우에만 유지합니다.
- presentation 파일 수가 늘어나면 `screens/`, `widgets/`, `mixins/`, `listeners/` 하위 분리를 검토합니다.
- 화면 파일 네이밍은 `*_screen.dart` 를 기본으로 유지합니다.

## 10. 환경설정 규칙

- 환경은 `APP_ENV`, `API_BASE_URL` 로 제어합니다.
- 운영형 실행은 `lib/main_development.dart`, `lib/main_staging.dart`, `lib/main_production.dart` entrypoint 를 우선 사용합니다.
- 환경별 기본 설정값은 `lib/core/config/app_flavors.dart` 한 파일에서 관리합니다.
- 새 환경값이 필요하면:
  - 가능하면 먼저 `app_flavors.dart` 에 기본값 추가
  - `AppConfig` 에 추가
  - `README.md` 와 문서 업데이트
  - 필요 시 기본값 정의
- 하드코딩된 서버 주소를 feature 코드에 직접 넣지 않습니다.

## 10-1. 관측성 규칙

- bootstrap 에서 `FlutterError.onError`, `PlatformDispatcher.instance.onError` 를 연결합니다.
- provider 실패는 logger 와 monitoring 훅에 함께 기록합니다.
- 실제 Sentry/Crashlytics 연결 시 `core/logging/app_monitoring.dart` 구현체를 교체합니다.

## 11. 저장소 및 보안 규칙

- 모바일 토큰 저장은 `flutter_secure_storage`
- 웹 토큰 저장은 `shared_preferences`
- UI, usecase, controller 에서 저장소 구현체를 직접 쓰지 않습니다.
- 토큰 값 객체는 `features/auth/domain/value_objects` 에 두고, storage 는 문자열 저장 책임만 가집니다.
- 토큰 저장/삭제는 usecase 또는 session controller 흐름 안에서만 수행합니다.
- `TokenStorage` 는 저장 계약이며, 모바일/데스크톱 기본 구현은 secure storage 입니다.
- `SharedPreferencesTokenStorage` 는 웹 환경용 대체 구현으로 취급합니다.

## 12. 문서 규칙

구조 변경, 새 feature 추가, 새 env 추가 시 아래 파일도 함께 검토합니다.

- `README.md`
- `docs/PROJECT_GUIDE.md`
- `docs/ARCHITECTURE.md`
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

최소 usecase 시나리오:

- validation 실패
- unauthorized/network/server 실패
- 성공 케이스
- 인증 usecase 는 토큰 보존/삭제 분기까지 확인

## 13-1. Agent Execution Workflow

### MUST

작업은 아래 순서를 따릅니다.

1. Code Exploration
2. Change Planning
3. Minimal Patch Implementation
4. Formatting
5. Static Analysis
6. Testing
7. Result Validation
8. Risk Reporting

### 역할 분담

- `explorer`
  - Code Exploration
  - Change Planning
- `implementer`
  - Minimal Patch Implementation
  - Formatting
  - Static Analysis
  - Testing
- `reviewer`
  - Result Validation
  - Risk Reporting
  - Stop / Retry / Escalate 판단

### SHOULD

- 구조 변경, 인증/세션/라우팅/DI/API 매핑 수정, Riverpod 상태 구조 변경은 `explorer -> implementer -> reviewer` 를 우선 사용합니다.
- 범위는 명확하지만 동작 변경이 있는 작업은 `implementer -> reviewer` 를 우선 사용합니다.

### AVOID

- 단일 파일만 보고 수정 시작
- 관련 usecase / repository / route module / session 흐름 확인 없이 구현
- 테스트 없이 완료 처리

## 13-2. Agent Handoff / Output Format

### Handoff Acceptance Rules

#### MUST

- `implementer` 는 아래 항목이 모두 채워진 explorer output 이 없으면 작업을 시작하지 않습니다.
  1. Problem Summary
  2. Suspected Root Cause
  3. Relevant Files
  4. Change Scope
  5. Non-Target Areas
  6. Test Impact
  7. Risks / Open Questions

- `reviewer` 는 아래 항목이 모두 채워진 implementer output 이 없으면 리뷰를 시작하지 않습니다.
  1. Approved Plan Reference
  2. Files Changed
  3. Key Changes
  4. Verification Results
  5. Remaining Risks

### Explorer Output

#### MUST

`explorer` 는 아래 형식으로만 결과를 남깁니다.

1. Problem Summary
2. Suspected Root Cause
3. Relevant Files
4. Change Scope
5. Non-Target Areas
6. Test Impact
7. Risks / Open Questions

#### AVOID

- 구현 코드 제안까지 확정하는 것
- 승인 범위를 불명확하게 남기는 것

### Implementer Output

#### MUST

`implementer` 는 아래 형식으로 결과를 남깁니다.

1. Approved Plan Reference
2. Files Changed
3. Key Changes
4. Verification Results
5. Remaining Risks

- `Verification Results` 에는 최소한 `dart format`, `flutter analyze`, `flutter test` 실행 여부를 포함합니다.
- explorer 승인 범위를 벗어난 수정이 있으면 반드시 명시합니다.

#### AVOID

- 변경 파일 경로 없이 설명만 남기는 것
- 검증 없이 구현만 완료로 표시하는 것

### Reviewer Output

#### MUST

`reviewer` 는 아래 형식으로 결과를 남깁니다.

1. Review Verdict (`pass` / `rework` / `escalate`)
2. Scope Check
3. Architecture Check
4. Test Check
5. Regression Risks
6. Required Follow-up

#### AVOID

- 리뷰 결과 없이 직접 수정으로 넘어가는 것
- 테스트 누락을 사소한 문제로 넘기는 것

### Output Contract Enforcement

#### MUST

- 각 agent 는 자신의 Output 형식에 정의된 항목만 사용해야 합니다.
- 다른 agent 역할의 내용이 섞이면 안 됩니다.
- 필수 항목이 하나라도 누락되면 해당 결과는 무효입니다.
- 무효한 결과를 받은 다음 agent 는 작업을 진행하지 않고 `rework` 또는 `escalate` 해야 합니다.

## 14. 작업 전 체크리스트

작업 전 반드시 스스로 확인할 것:

- 이 변경이 어느 feature 에 속하는가?
- provider 를 어디에 둘지 현재 배치 규칙과 맞는가?
- 이 로직은 controller 가 아니라 usecase 로 가야 하는가?
- DTO 와 Entity 를 분리했는가?
- UI 가 data layer 를 직접 보고 있지 않은가?
- route 는 공개/인증 영역이 올바르게 분리됐는가?
- 지금 구조 변경이 정말 필요한가, 아니면 `docs/ARCHITECTURE.md` 에 규칙 보강만 하면 되는가?

## 15. 작업 후 체크리스트

작업 후 반드시 확인할 것:

- import 방향이 계층 규칙을 어기지 않는가?
- 불필요한 직접 의존성이 생기지 않았는가?
- 문서 업데이트가 필요한가?
- codegen 이 필요한 파일이면 생성했는가?
- analyze/test 가 통과하는가?

## 15-1. Agent Escalation Rules

### Explorer

#### MUST

아래 경우에는 `explorer` 가 에스컬레이션합니다.

- 책임 레이어가 불명확한 경우
- 둘 이상의 구조 방향이 모두 가능해 보이는 경우
- 서버 계약 또는 기획 의도가 없으면 판단이 어려운 경우
- 수정 범위가 예상보다 커져 여러 feature/module 로 확장되는 경우

### Implementer

#### MUST

아래 경우에는 `implementer` 가 에스컬레이션합니다.

- 공개 계약 변경 없이는 해결이 불가능한 경우
- 승인된 범위를 벗어난 수정이 필요한 경우
- `flutter analyze` 또는 `flutter test` 실패가 구조적 문제로 보이는 경우
- unrelated 파일까지 함께 수정해야만 해결되는 경우

### Reviewer

#### MUST

아래 경우에는 `reviewer` 가 에스컬레이션합니다.

- 구현은 통과했지만 구조적으로 안전하지 않다고 판단되는 경우
- 문서 규칙끼리 충돌하는 경우
- 테스트가 부족해서 `pass` 판단이 어려운 경우
- 비즈니스 의도를 안전하게 추론할 수 없는 경우

#### 추가 검증 (MUST)

- reviewer 는 코드 품질뿐 아니라 아래 절차 준수 여부도 함께 검토합니다.
  - explorer -> implementer -> reviewer 순차 실행 여부
  - handoff acceptance rules 충족 여부
  - output format 준수 여부
  - 승인된 변경 범위 초과 여부

- 절차 위반이 있는 경우, 코드가 맞더라도 `pass` 를 줄 수 없습니다.
- 절차 위반 시 기본 판정은 `rework` 입니다.

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
