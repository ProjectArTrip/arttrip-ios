# ArtTrip iOS 프로젝트 가이드

> **중요**: 프로젝트 구조나 코딩 패턴이 변경되면 이 문서와 `docs/` 폴더도 반드시 업데이트해야 합니다.

## 상세 문서 (docs/)

| 문서 | 내용 |
|------|------|
| [docs/architecture.md](docs/architecture.md) | 프로젝트 구조, MVVM 아키텍처, 기능 모듈 현황, 기술 스택, 환경 설정, Enum, 싱글톤, 파일 네이밍, 주요 명령어 |
| [docs/coding-style.md](docs/coding-style.md) | 코딩 컨벤션, 포맷팅/린트 규칙, 색상(AppColors), 텍스트(ArtTripText), 반응형 UI, 다국어(l10n), 모델 생성(Freezed), 버튼 구현 |
| [docs/network.md](docs/network.md) | DioClient, 인터셉터 체인, ApiResult/ApiResponse, 인증 플로우, 토큰 관리, Repository 패턴, Form-data 업로드, 에러 처리 |
| [docs/state-management.md](docs/state-management.md) | Provider 등록, ViewModel 패턴, AsyncState/AsyncView, 페이지네이션, 즐겨찾기 전역 상태, 편집/생성 모드, 캐싱 전략 |
| [docs/routing.md](docs/routing.md) | GoRouter, 네비게이션 메서드(push/modal/replace/go), 라우트 경로 상수, GNB 탭, 전환 애니메이션, 파라미터 전달 |
| [docs/ui-patterns.md](docs/ui-patterns.md) | 공용 위젯 목록, 앱바, 이미지 캐싱, 스켈레톤 로딩, 다이얼로그, 바텀시트, 스낵바/토스트, 스크롤 패턴, Google Maps |
| [docs/api-reference.md](docs/api-reference.md) | 전체 API 엔드포인트, 요청/응답 형식, 페이지네이션, 서버 응답 구조 |

## 핵심 규칙 (빠른 참조)

### 절대 하지 말 것

- `TextStyle` 직접 정의 → **`ArtTripText` 빌더 사용**
- `Color(0xFF...)` 직접 사용 → **`AppColors` 상수 사용**
- `OutlinedButton` / `ElevatedButton` 사용 → **`GestureDetector + Container` 사용**
- 텍스트 하드코딩 → **`context.l10n.xxx` 사용**
- 상대 import → **`package:arttrip/...` 절대 import 사용**
- 페이지에서 `ChangeNotifierProvider` 직접 생성 → **`provider_config.dart`에 전역 등록 + `InitWidget` + `reset()`**
- `.freezed.dart` / `.g.dart` 파일 직접 수정
- AI 관련 언급 (커밋 메시지, PR, 문서에서 Claude, AI, 자동 생성 등 금지)

### 항상 할 것

- 코드 작성 후 `dart format .` 실행
- 새 ViewModel → `provider_config.dart` 등록 + `reset()` 메서드 구현
- 새 모델 → Freezed 사용 + `flutter pub run build_runner build`
- 새 l10n 키 → `app_ko.arb`(필수) + `app_en.arb` 동시 추가
- 새 라우트 → `app_routes.dart` 상수 + `app_router.dart` GoRoute 추가
- 새 Repository → Abstract → Impl → Mock → Hybrid 4단계 + `provider_config.dart` 등록
- 기존 위젯 수정 시 → 영향 범위 확인, 필요시 새 위젯 생성

### 코어 패턴 요약

```dart
// 1. 상태 관리: Provider + ViewModel + AsyncState
Selector<VM, AsyncState<T>>(
  selector: (_, vm) => vm.state,
  builder: (_, state, __) => AsyncView<T>(state: state, onData: (d) => Widget),
)

// 2. Repository: try-catch + debugLog + null 반환
Future<T?> fetch() async {
  try {
    var res = await _dio.get('/path');
    return ApiResponse<T>.fromJson(res.dataOrNull, (o) => T.fromJson(o)).result;
  } catch (e) { AppUtil.debugLog('fetch: $e'); }
  return null;
}

// 3. 라우팅
Routes.push(context, AppRoutes.exhibitPath(id));
var result = await Routes.modal<bool>(context, path, extra: params);

// 4. 텍스트
ArtTripText.pretendard().body01Bold().color(AppColors.textPrimary).build().text('내용')

// 5. 반응형
SizedBox(width: 24.w, height: 16.h)
BorderRadius.circular(8.r)
```

### StatefulWidget 메서드 순서

```
1. 멤버 변수 → 2. initState → 3. dispose → 4. build → 5. 커스텀 메서드
```

### 프로젝트 구조

```
lib/
├── core/           # 전역 설정 (색상, 상수, 네트워크, 환경변수)
├── features/       # 기능별 모듈 (views, widgets, viewmodels, data)
├── shared/         # 공용 위젯, 모델, 유틸리티
├── routes/         # GoRouter 라우팅
├── l10n/           # 다국어 (ko, en)
└── main.dart       # 진입점
```
