# 코딩 스타일 가이드

## 포맷팅 규칙

**코드 작성 후 항상 `dart format .` 실행**

**린트 규칙** (`analysis_options.yaml`):
- `page_width: 80`
- `trailing_commas: preserve`
- `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`
- `prefer_final_fields`, `prefer_final_locals`
- `prefer_single_quotes`
- `always_use_package_imports` — 상대 import 금지
- `unawaited_futures` — Future 반환값 무시 경고
- 제외 대상: `lib/**.freezed.dart`, `lib/**.g.dart`

## import 규칙

```dart
// Good - 항상 package import
import 'package:arttrip/core/app_colors.dart';

// Bad - 상대 import 금지
import '../core/app_colors.dart';
```

## StatefulWidget 메서드 순서

```dart
class _MyPageState extends State<MyPage> {
  // 1. 멤버 변수
  late TabController _tabController;

  // 2. initState
  @override
  void initState() { ... }

  // 3. dispose
  @override
  void dispose() { ... }

  // 4. build
  @override
  Widget build(BuildContext context) { ... }

  // 5. 커스텀 메서드들
  Widget _buildContent() { ... }
  void _onTabChanged() { ... }
}
```

## 색상

**항상 `AppColors` 사용, 로컬 Color 상수 금지**

```dart
// Good
color: AppColors.primary300

// Bad
static const _primaryColor = Color(0xFF7859FF);
```

### 색상 팔레트

| 카테고리 | 상수 | 용도 |
|---------|------|------|
| 브랜드 | `primary100/200/300` | 주요 보라색 |
| 텍스트 | `textPrimary/Secondary/Tertiary` | 텍스트 색상 |
| 텍스트 | `textWhite/textPoint` | 흰색/포인트 |
| 그레이 | `gray0/50/100/900` | 그레이스케일 |
| 서브 | `subRed` | 에러/삭제 |
| 서브 | `subLime` | 진행중 배지 |
| 서브 | `subLightGray` | 예정 배지, 캘린더 오늘 |
| 서브 | `subKakao` | 카카오 노란색 |

## 텍스트 스타일

**모든 텍스트는 반드시 `ArtTripText` 사용 (TextStyle 직접 정의 금지)**

```dart
// 텍스트 위젯
ArtTripText.pretendard()
    .body01Bold()
    .color(AppColors.textPrimary)
    .build()
    .text('텍스트')

// TextStyle이 필요한 경우 (TextField 등)
ArtTripText.pretendard()
    .body01Regular()
    .color(AppColors.textPrimary)
    .build()
    .style()  // .style()로 TextStyle 추출
```

### 빌더 체인

```
ArtTripText.pretendard()  →  스타일 선택  →  커스터마이즈  →  .build()  →  .text() / .style()
```

커스터마이즈 메서드: `.color()`, `.weight()`, `.letterSpacing()`, `.textAlign()`, `.decoration()`, `.ellipsis()`

### 사용 가능한 스타일

| 메서드 | 사이즈 | 굵기 |
|--------|--------|------|
| `headline()` | 20px | w700 |
| `title01Bold()` / `title01Light()` | 18px | w700 / w300 |
| `title02Bold()` / `title02Light()` | 16px | w700 / w300 |
| `body01Bold()` / `body01Regular()` / `body01Light()` | 14px | w700 / w400 / w300 |
| `body02Bold()` / `body02Regular()` / `body02Light()` | 12px | w700 / w400 / w300 |
| `body03Regular()` | 11px | w400 |
| `custom(double fontSize)` | 커스텀 | 기본 w400 |

## 반응형 UI

**flutter_screenutil 사용**

```dart
SizedBox(width: 24.w)      // width
SizedBox(height: 16.h)     // height
BorderRadius.circular(8.r) // radius
fontSize: 14.sp            // font size
```

## 다국어 (l10n)

**사용자에게 보이는 모든 텍스트는 반드시 l10n 사용 (하드코딩 금지)**

```dart
import 'package:arttrip/core/extensions.dart';

// Good
Text(context.l10n.goToHomepage)

// Bad
Text('홈페이지 바로 가기')
```

### 적용 대상

- 버튼 라벨, 탭/메뉴 이름, 안내 문구, 에러 메시지, 플레이스홀더

### 예외 (l10n 불필요)

- 서버에서 받아온 데이터 (전시 제목, 설명 등)
- 숫자, 날짜 포맷

### 파라미터가 있는 l10n 키

```dart
context.l10n.personalizedRecommendationTitle(userName)  // "{userName}님을 위한 추천"
context.l10n.genreDetailExhibition(genreName)
context.l10n.calendarYearMonth(year, month)
context.l10n.visitDateFormat(date)
context.l10n.totalCount(count)
context.l10n.noExhibitionsInGenre(genre)
```

### 새 l10n 키 추가 절차

1. `lib/l10n/app_ko.arb`에 한국어 키 추가 (필수)
2. `lib/l10n/app_en.arb`에 영어 키 추가
3. `flutter gen-l10n` 실행

## 모델 생성

**Freezed + JSON Serializable 사용**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exhibit_detail_model.freezed.dart';
part 'exhibit_detail_model.g.dart';

@freezed
abstract class ExhibitDetailModel with _$ExhibitDetailModel {
  const ExhibitDetailModel._();  // 커스텀 메서드가 필요할 때만

  const factory ExhibitDetailModel({
    required int exhibitId,
    required String title,
    String? hallOpeningHours,           // nullable
    @Default(false) bool isFavorite,    // 기본값
    @Default([]) List<String> photoUrls, // 기본 빈 배열
    @JsonKey(name: 'isFavorite') @Default(false) bool favorite, // JSON 키 매핑
  }) = _ExhibitDetailModel;

  factory ExhibitDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ExhibitDetailModelFromJson(json);

  // 커스텀 getter
  bool get isOngoing => status == 'ONGOING';
}
```

### 리스트 응답 모델 패턴

```dart
@freezed
abstract class ExhibitReviewListResponseModel with _$ExhibitReviewListResponseModel {
  const factory ExhibitReviewListResponseModel({
    required List<ExhibitReviewModel> reviews,
    int? nextCursor,
    required bool hasNext,
    @Default(0) int reviewTotalCount,
  }) = _ExhibitReviewListResponseModel;

  factory ExhibitReviewListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ExhibitReviewListResponseModelFromJson(json);
}
```

### 코드 생성

```bash
flutter pub run build_runner build
flutter pub run build_runner build --delete-conflicting-outputs  # 충돌 시
```

**주의**: `.freezed.dart`, `.g.dart` 파일 직접 수정 금지

## 버튼 구현

**GestureDetector + Container 사용 (OutlinedButton/ElevatedButton 사용 금지)**

```dart
GestureDetector(
  onTap: () => Navigator.of(context).pop(),
  child: Container(
    height: 48.h,
    decoration: BoxDecoration(
      color: AppColors.gray0,
      border: Border.all(color: const Color(0xFFDBDBDB)),
      borderRadius: BorderRadius.circular(12.r),
    ),
    alignment: Alignment.center,
    child: ArtTripText.pretendard()
        .body01Bold()
        .color(AppColors.textPrimary)
        .build()
        .text('취소'),
  ),
)
```

**비활성화 상태**:
- `onTap: _canConfirm ? _onPressed : null`
- `color: _canConfirm ? AppColors.primary300 : AppColors.primary100`

**예외**: `SocialLoginButton`은 `ElevatedButton` 사용 (소셜 로그인 전용)
