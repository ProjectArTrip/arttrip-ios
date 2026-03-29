# 프로젝트 아키텍처

## 기술 스택

- **Flutter**: 3.41.4 (FVM 관리)
- **Dart SDK**: >=3.8.0 <4.0.0
- **iOS 최소 버전**: 15.0
- **디자인 기준 사이즈**: 375x812
- **폰트**: Pretendard (Bold 700, SemiBold 600, Regular 400, Light 300)
- **지원 언어**: 한국어(ko), 영어(en) — 템플릿: app_ko.arb

## 주요 의존성

| 패키지 | 버전 | 용도 |
|--------|------|------|
| `provider` | 6.1.5 | 상태 관리 |
| `go_router` | 17.0.0 | 라우팅 |
| `dio` | 5.7.0 | HTTP 클라이언트 |
| `freezed_annotation` | 3.1.0 | 불변 모델 코드 생성 |
| `json_annotation` | 4.11.0 | JSON 직렬화 |
| `flutter_screenutil` | 5.9.3 | 반응형 UI |
| `cached_network_image` | 3.4.1 | 이미지 캐싱 |
| `kakao_flutter_sdk_user` | 1.9.7 | 카카오 로그인 |
| `google_maps_flutter` | 2.14.0 | 구글 지도 |
| `table_calendar` | 3.2.0 | 달력 위젯 |
| `image_picker` | 1.2.1 | 이미지 선택/촬영 |
| `webview_flutter` | 4.13.0 | 웹뷰 |
| `shimmer_animation` | 2.2.2 | 스켈레톤 로딩 |
| `connectivity_plus` | 6.1.0 | 네트워크 상태 |
| `shared_preferences` | 2.3.4 | 로컬 저장소 |
| `flutter_dotenv` | 6.0.0 | 환경 변수 |
| `package_info_plus` | 9.0.0 | 앱 버전 정보 |

## 디렉터리 구조

```
lib/
├── core/                        # 앱 전역 설정
│   ├── app_colors.dart          # 색상 상수 (AppColors)
│   ├── app_assets.dart          # 에셋 경로 (AppAssets)
│   ├── app_consts.dart          # 상수 값 (AppConsts)
│   ├── app_urls.dart            # URL 상수 (AppUrls)
│   ├── app_utils.dart           # 유틸리티 함수 (AppUtil)
│   ├── extensions.dart          # BuildContext 확장 (l10n)
│   ├── enum.dart                # 공통 Enum
│   ├── env.dart                 # 환경 변수 (Env)
│   ├── config/
│   │   ├── provider_config.dart # Provider/DI 설정
│   │   └── prefs.dart           # SharedPreferences 래퍼
│   └── network/                 # 네트워크 계층 (→ docs/network.md)
│
├── features/{feature}/          # 기능별 모듈 (MVVM)
│   ├── views/                   # 페이지 및 섹션 뷰
│   ├── widgets/                 # 재사용 가능한 위젯
│   ├── viewmodels/              # ViewModel (상태 관리)
│   ├── services/                # 서비스 (비즈니스 로직)
│   └── data/
│       ├── models/              # 데이터 모델
│       ├── *_repository.dart    # Repository (abstract + impl + mock + hybrid)
│       └── *_api_service.dart   # API 서비스
│
├── shared/                      # 공통 컴포넌트 (→ docs/ui-patterns.md)
│   ├── widgets/                 # 공용 위젯
│   ├── viewmodels/              # 공용 ViewModel
│   ├── pages/                   # 공용 페이지 (WebView, Alerts)
│   ├── models/                  # 공용 모델
│   └── utils/                   # 유틸리티 (ArtTripText, SnackBarUtils)
│
├── routes/                      # 라우팅 (→ docs/routing.md)
├── l10n/                        # 다국어 리소스
└── main.dart                    # 앱 진입점
```

### 폴더 구분 기준

| 폴더 | 용도 | 예시 |
|------|------|------|
| `views/` | 페이지 및 섹션 뷰 | `exhibit_detail_page.dart`, `splash_view.dart` |
| `widgets/` | 재사용 가능한 작은 위젯 | `exhibit_header_section.dart` |
| `widgets/{기능명}/` | 특정 기능 관련 위젯 그룹 | `widgets/write_review/` |
| `viewmodels/` | ViewModel (상태 관리) | `exhibit_detail_viewmodel.dart` |
| `services/` | 서비스 (비즈니스 로직) | `auth_service.dart`, `token_storage_service.dart` |
| `models/` | 데이터 모델 | `exhibit_detail_model.dart` |

**폴더 네이밍 규칙**: 여러 파일을 담는 폴더는 **복수형** 사용 (`views/`, `widgets/`, `viewmodels/`, `services/`, `models/`)

## MVVM 아키텍처

```
View (Widget)
  ↕ Provider Selector
ViewModel (ChangeNotifier)
  ↕
Repository (Abstract → Impl/Mock/Hybrid)
  ↕
DioClient → Interceptor Chain → Server
```

- **View**: UI 렌더링. `Selector`로 특정 상태만 구독하여 리빌드 최소화
- **ViewModel**: `ChangeNotifier` 기반 상태 관리. `AsyncState<T>`로 비동기 상태 래핑
- **Repository**: 데이터 접근 추상화. 4단계 구현 (Abstract → Impl → Mock → Hybrid)
- **Network**: DioClient 싱글톤 + 인터셉터 체인

## 기능 모듈 현황

| 기능 | 경로 | 상태 | 설명 |
|------|------|------|------|
| auth | `features/auth/` | 완료 | 인증 서비스 (Kakao OAuth + 토큰 관리) |
| login | `features/login/` | 부분 | 로그인 (카카오만 구현, Google/Apple TODO) |
| splash | `features/splash/` | 완료 | 앱 시작 → 인증 확인 → 분기 |
| onboarding | `features/onboarding/` | 완료 | 관심 키워드(장르/스타일) 선택 |
| home | `features/home/` | 완료 | 국내/해외 전시 피드, 추천, 주간일정, 지역별, 장르별 |
| exhibit | `features/exhibit/` | 완료 | 전시 상세 (3탭: 상세/지도/리뷰) + 리뷰 CRUD + 즐겨찾기 |
| search | `features/search/` | 완료 | 전시 검색 + 검색 히스토리 + 추천 키워드 |
| my | `features/my/` | 완료 | 프로필, 닉네임/이미지 수정, 내 리뷰, 최근 본 전시, 설정 |
| map | `features/map/` | 스텁 | 지도 (미구현, 플레이스홀더) |
| stamp | `features/stamp/` | 스텁 | 스탬프 (미구현, 플레이스홀더) |
| storage | `features/storage/` | 스텁 | 보관함 (미구현, 플레이스홀더) |

## 환경 설정

### .env 파일

```
KAKAO_NATIVE_APP_KEY=...
API_BASE_URL=https://dev.08166.dev
GOOGLE_MAPS_API_KEY=...
```

**접근 방법**: `Env` 클래스 사용 (직접 dotenv 접근 금지)

```dart
Env.apiBaseUrl
Env.kakaoNativeAppKey
```

### SharedPreferences (Prefs 싱글톤)

```dart
Prefs().accessToken / Prefs().setAccessToken()
Prefs().refreshToken / Prefs().setRefreshToken()
Prefs().clearAuthData()
Prefs().isFirstLogin / Prefs().setIsFirstLogin()
```

## 공통 Enum

```dart
// lib/core/enum.dart

enum AsyncStatus { loading, success, error }
enum FontFamilyType { pretendard('Pretendard') }
enum ExhibitionStatus {
  upcoming('UPCOMING'), onGoing('ONGOING'),
  endingSoon('ENDING_SOON'), finished('FINISHED');
}
enum LocationType { overseas, domestic }
enum SortType { latest('LATEST'), oldest('DEADLINE'), none('NONE'); }
```

## 싱글톤 서비스

| 서비스 | 접근 방법 | 용도 |
|--------|----------|------|
| `DioClient` | `DioClient.instance` | HTTP 클라이언트 |
| `AuthService` | `AuthService.instance` | 인증 (로그인/로그아웃/토큰갱신) |
| `KakaoLoginService` | `KakaoLoginService.instance` | 카카오 SDK |
| `TokenStorageService` | `TokenStorageService.instance` | 토큰 저장/조회 |
| `ConnectivityService` | `ConnectivityService.instance` | 네트워크 상태 |
| `Prefs` | `Prefs()` | SharedPreferences |

## 파일 네이밍 규칙

| 유형 | 패턴 | 예시 |
|------|------|------|
| 페이지 | `*_page.dart` | `edit_profile_page.dart` |
| 뷰 (GNB 탭 등) | `*_view.dart` | `splash_view.dart`, `map_view.dart` |
| 위젯 | 기능명 또는 `*_section.dart` | `exhibit_header_section.dart` |
| 다이얼로그 | `*_dialog.dart` | `app_input_dialog.dart` |
| 바텀시트 | `*_bottom_sheet.dart` | `calendar_bottom_sheet.dart` |
| ViewModel | `*_viewmodel.dart` | `my_viewmodel.dart` |
| Repository | `*_repository.dart` | `my_repository.dart` |
| Repository Mock | `*_repository_mock.dart` | `my_repository_mock.dart` |
| API 서비스 | `*_api_service.dart` | `auth_api_service.dart` |
| 모델 | `*_model.dart` | `user_profile_model.dart` |
| 서비스 | `*_service.dart` | `auth_service.dart` |

## 주요 명령어

```bash
dart format .                                              # 코드 포맷팅
flutter analyze                                            # 코드 분석
flutter pub run build_runner build                         # Freezed 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs  # 충돌 시 재생성
flutter gen-l10n                                           # l10n 생성
flutter pub get                                            # 의존성 설치
```
