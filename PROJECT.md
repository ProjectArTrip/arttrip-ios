# ArtTrip iOS

글로벌 전시회 예약 앱

## 기술 스택

- **Flutter** 3.3.0+
- **Dart** 3.3.0+
- **상태관리**: (추후 결정)
- **네트워크**: Dio + 커스텀 인터셉터
- **로컬 저장소**: SharedPreferences
- **다국어 지원**: flutter_localizations (ko, en)

## 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점
├── main_page.dart               # 메인 페이지 (바텀 네비게이션)
│
├── core/                        # 핵심 유틸리티
│   ├── config/
│   │   └── prefs.dart           # SharedPreferences 싱글톤
│   ├── network/                 # 네트워크 레이어
│   │   ├── network.dart         # 배럴 파일
│   │   ├── dio_client.dart      # Dio 클라이언트
│   │   ├── base_api_service.dart
│   │   ├── api_result.dart      # ApiResult sealed class
│   │   ├── network_exceptions.dart
│   │   ├── connectivity_service.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       ├── error_interceptor.dart
│   │       └── retry_interceptor.dart
│   ├── app_colors.dart          # 색상 정의
│   ├── app_assets.dart          # 에셋 경로 정의
│   ├── env.dart                 # 환경변수 접근 클래스
│   ├── enum.dart                # 공용 enum
│   └── extensions.dart          # Extension 메서드
│
├── features/                    # 기능별 모듈
│   ├── splash/
│   │   └── view/
│   │       └── splash_view.dart # 스플래시 (인증 체크)
│   ├── login/
│   │   ├── login_page.dart      # 로그인 페이지
│   │   └── service/
│   │       └── kakao_login_service.dart
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_api_service.dart
│   │   └── service/
│   │       ├── auth_service.dart
│   │       └── token_storage_service.dart
│   ├── home/
│   │   └── home_page.dart
│   ├── map/
│   │   └── view/map_view.dart
│   ├── stamp/
│   │   └── view/stamp_view.dart
│   ├── storage/
│   │   └── view/storage_view.dart
│   └── my/
│       └── view/my_view.dart
│
├── shared/                      # 공용 컴포넌트
│   ├── widgets/
│   │   ├── bottom_nav_bar.dart
│   │   └── social_login_button.dart
│   └── utils/
│       ├── snackbar_utils.dart
│       └── text/                # 텍스트 유틸리티
│
└── l10n/                        # 다국어 리소스
    └── generated/
```

## 주요 기능

### 1. 인증 시스템

#### 소셜 로그인
- **카카오 로그인**: OIDC ID Token 방식
- Google 로그인 (예정)
- Apple 로그인 (예정)

#### 토큰 관리
- Access Token: 15분 만료
- Refresh Token: 7일 만료
- 자동 토큰 갱신 (AuthInterceptor)

### 2. 네트워크 레이어

```dart
// API 호출 예시
final result = await authApi.socialLogin(
  provider: 'KAKAO',
  idToken: idToken,
);

result.when(
  success: (data) => print('성공: $data'),
  failure: (error) => print('실패: ${error.message}'),
);
```

#### 인터셉터
- **AuthInterceptor**: 토큰 자동 추가, 401 시 갱신
- **ErrorInterceptor**: DioException → NetworkException 변환
- **RetryInterceptor**: 지수 백오프 재시도

### 3. 바텀 네비게이션
- 홈 / 지도 / 스탬프 / 보관함 / MY

## 환경 설정

### .env 파일
```env
KAKAO_NATIVE_APP_KEY=your_kakao_native_app_key
API_BASE_URL=https://api.example.com
```

### iOS 설정 (ios/Runner/Info.plist)
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>kakaokompassauth</string>
    <string>kakaolink</string>
    <string>kakaoplus</string>
</array>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>kakao{NATIVE_APP_KEY}</string>
        </array>
    </dict>
</array>
```

## 컬러 시스템

| 이름 | 색상 코드 | 용도 |
|------|-----------|------|
| primary100 | #DBD5FC | 연한 포인트 |
| primary200 | #AA97FF | 중간 포인트 |
| primary300 | #8063FF | 메인 브랜드 색상 |
| subRed | #EB6A5B | 에러/경고 |
| subKakao | #FEE500 | 카카오 버튼 |
| gray0 | #FFFFFF | 배경 |
| gray900 | #111111 | 텍스트 |

## 폰트

- **Pretendard**: Bold(700), SemiBold(600), Regular(400), Light(300)

## 명령어

```bash
# 의존성 설치
flutter pub get

# 빌드 실행
flutter run

# 린트 검사
flutter analyze

# 다국어 생성
flutter gen-l10n

# iOS 빌드
flutter build ios
```

## API 엔드포인트

| 메서드 | 경로 | 설명 |
|--------|------|------|
| POST | /auth/social | 소셜 로그인 |
| POST | /auth/app/reissue | 토큰 재발급 |
| POST | /auth/logout | 로그아웃 |

## 코드 컨벤션

### 린트 규칙
- `final` 대신 `var` 사용 (지역 변수)
- `package:` import 사용 (상대 경로 X)
- `dynamic` 대신 `Object?` 사용
- 생성자는 필드 선언 전에 위치

### 네이밍
- 파일: snake_case (`auth_service.dart`)
- 클래스: PascalCase (`AuthService`)
- 변수/함수: camelCase (`getAccessToken`)
- 상수: camelCase (`accessTokenKey`)

### 폴더 구조 (Feature-first)
```
feature/
├── data/           # API 서비스, 모델
├── service/        # 비즈니스 로직
└── view/           # UI 위젯
```
