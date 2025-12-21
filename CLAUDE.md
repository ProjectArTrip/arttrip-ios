# ArtTrip iOS 프로젝트 가이드

> **중요**: 프로젝트 구조나 코딩 패턴이 변경되면 이 문서도 반드시 업데이트해야 합니다.

## 프로젝트 구조

```
lib/
├── core/                        # 앱 전역 설정
│   ├── app_colors.dart          # 색상 상수 (AppColors)
│   ├── app_assets.dart          # 에셋 경로 (AppAssets)
│   ├── app_consts.dart          # 상수 값 (AppConsts)
│   ├── app_utils.dart           # 유틸리티 함수
│   ├── extensions.dart          # BuildContext 확장 (l10n)
│   ├── enum.dart                # 공통 Enum
│   └── network/                 # API/네트워크 관련
│
├── features/{feature}/          # 기능별 모듈
│   ├── view/                    # 페이지 (라우팅 대상)
│   ├── views/                   # 페이지 내 독립적인 섹션 뷰
│   ├── widgets/                 # 재사용 가능한 위젯
│   ├── viewmodel/               # ViewModel (상태 관리)
│   └── data/
│       ├── models/              # 데이터 모델
│       ├── *_repository.dart    # Repository
│       └── *_api_service.dart   # API 서비스
│
├── shared/                      # 공통 컴포넌트
│   ├── widgets/                 # 공용 위젯 (AsyncView, etc.)
│   ├── models/                  # 공용 모델
│   └── utils/                   # 유틸리티 (ArtTripText, etc.)
│
├── routes/                      # 라우팅 설정
└── l10n/                        # 다국어 리소스
```

### 폴더 구분 기준

| 폴더 | 용도 | 예시 |
|------|------|------|
| `view/` | 라우팅되는 전체 페이지 | `exhibit_detail_page.dart` |
| `views/` | 페이지 내 독립적인 섹션 | `weekly_exhibition_schedule_view.dart` |
| `widgets/` | 재사용 가능한 작은 위젯 | `exhibit_header_section.dart` |

## 코딩 스타일

### 색상

**항상 `AppColors` 사용, 로컬 Color 상수 금지**

```dart
// Good
color: AppColors.primary300

// Bad
static const _primaryColor = Color(0xFF7859FF);
color: _primaryColor
```

주요 색상:
- `AppColors.primary100/200/300` - 주요 브랜드 색상
- `AppColors.textPrimary/Secondary/Tertiary` - 텍스트 색상
- `AppColors.gray0/50/100/900` - 그레이스케일
- `AppColors.subRed/subLime/subLightGray` - 서브 색상

### 텍스트 스타일

**`ArtTripText` 빌더 패턴 사용**

```dart
// Good
ArtTripText.pretendard()
    .body01Bold()
    .color(AppColors.textPrimary)
    .build()
    .text('텍스트')

// Bad
Text(
  '텍스트',
  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
)
```

사용 가능한 스타일:
- `headline()` - 헤드라인
- `title01Bold/Light()`, `title02Bold/Light()` - 제목
- `body01Bold/Regular/Light()`, `body02Bold/Regular/Light()`, `body03Regular()` - 본문

### 상태 관리

**Provider + ViewModel + AsyncState 패턴**

```dart
// ViewModel
class ExhibitDetailViewModel extends ChangeNotifier {
  AsyncState<ExhibitDetail> _exhibitState = const AsyncState.loading();
  AsyncState<ExhibitDetail> get exhibitState => _exhibitState;

  Future<void> fetchExhibitDetail(int id) async {
    _exhibitState = const AsyncState.loading();
    notifyListeners();

    try {
      final data = await _repository.getDetail(id);
      _exhibitState = AsyncState.success(data);
    } catch (e) {
      _exhibitState = AsyncState.error(error: e);
    }
    notifyListeners();
  }
}
```

```dart
// View에서 사용
Selector<ExhibitDetailViewModel, AsyncState<ExhibitDetail>>(
  selector: (_, vm) => vm.exhibitState,
  builder: (context, state, _) {
    return AsyncView<ExhibitDetail>(
      state: state,
      onData: (exhibit) => _buildContent(exhibit),
      // onError는 생략 - 기본 에러 UI 사용
    );
  },
)
```

**주의**: `AsyncView`에서 `onError`는 생략하고 기본 에러 UI 사용

### 반응형 UI

**flutter_screenutil 사용**

```dart
SizedBox(width: 24.w)      // width
SizedBox(height: 16.h)     // height
BorderRadius.circular(8.r) // radius
fontSize: 14.sp            // font size
```

### 다국어

**사용자에게 보이는 모든 텍스트는 반드시 l10n 사용 (하드코딩 금지)**

```dart
import 'package:arttrip/core/extensions.dart';

// Good
Text(context.l10n.goToHomepage)
Tab(text: context.l10n.detailInfo)

// Bad - 하드코딩 금지
Text('홈페이지 바로 가기')
Tab(text: '상세 정보')
```

l10n 적용 대상:
- 버튼 라벨 (`'저장'`, `'취소'`, `'확인'`)
- 탭/메뉴 이름 (`'상세 정보'`, `'지도'`, `'리뷰'`)
- 안내 문구, 에러 메시지
- 플레이스홀더, 힌트 텍스트

예외 (l10n 불필요):
- 서버에서 받아온 데이터 (전시 제목, 설명 등)
- 숫자, 날짜 포맷

## 모델 생성

**Freezed + JSON Serializable 사용**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exhibit_detail.freezed.dart';
part 'exhibit_detail.g.dart';

@freezed
class ExhibitDetail with _$ExhibitDetail {
  const factory ExhibitDetail({
    required int exhibitId,
    required String title,
    // nullable 필드는 String? 사용
    String? hallOpeningHours,
    String? hallPhone,
  }) = _ExhibitDetail;

  factory ExhibitDetail.fromJson(Map<String, dynamic> json) =>
      _$ExhibitDetailFromJson(json);
}
```

**nullable 필드 처리**: API에서 null이 올 수 있는 필드는 `String?`으로 nullable 타입 사용

코드 생성:
```bash
flutter pub run build_runner build
```

## 공용 위젯

| 위젯 | 용도 |
|------|------|
| `AsyncView<T>` | 로딩/에러/성공 상태 UI 처리 |
| `InitWidget` | 위젯 초기화 시 함수 실행 |
| `ExhibitionListItem` | 전시 리스트 아이템 |
| `ExhibitionStatusBadge` | 리스트 아이템용 전시 상태 배지 (모서리에 붙는 형태) |
| `ExhibitDetailStatusBadge` | 상세 페이지용 전시 상태 배지 (독립 칩 형태) |
| `Shimmer` + `*Skeleton` | 로딩 스켈레톤 UI |

### 전시 상태 (ExhibitionStatus)

```dart
// lib/core/enum.dart
enum ExhibitionStatus {
  upcoming('UPCOMING'),      // 예정된 전시
  onGoing('ONGOING'),        // 진행 중인 전시
  endingSoon('ENDING_SOON'), // 마감 임박 (3일 전부터)
  finished('FINISHED');      // 종료된 전시
}
```

**주의**: 리스트와 상세페이지에서 배지 스타일이 다르므로 별도 위젯 사용
- `ExhibitionStatusBadge` - 리스트 아이템 이미지 우하단 모서리
- `ExhibitDetailStatusBadge` - 상세페이지 포스터 좌상단 독립 칩

## 라우팅

```dart
import 'package:arttrip/routes/routes.dart';

// 페이지 이동
Routes.push(context, '/exhibit/${item.exhibitId}');
```

## UI 패턴

### 조건부 표시

**데이터가 없으면 위젯 숨기기**

```dart
// Good - 데이터 있을 때만 표시
if (exhibit.hallAddress.isNotEmpty) {
  infoItems.add(ExhibitInfoRow(...));
}

// 모든 항목이 비어있으면 전체 컨테이너도 숨김
if (infoItems.isEmpty) {
  return const SizedBox.shrink();
}
```

## 스크롤 패턴

### DraggableScrollableSheet + 탭 콘텐츠

`DraggableScrollableSheet` 내부에서 탭 콘텐츠를 구현할 때 **Flutter의 알려진 한계**가 있습니다:

- `DraggableScrollableSheet` + `NestedScrollView` + `TabBarView` 조합은 스크롤 통합이 안 됨 ([GitHub Issue #64157](https://github.com/flutter/flutter/issues/64157))
- 바텀시트 확장과 탭 콘텐츠 스크롤 통합을 동시에 구현하기 어려움

**현재 해결책**: `CustomScrollView` + 탭 인덱스 기반 콘텐츠 전환

```dart
// 탭바 스와이프 전환 없이, 클릭으로만 탭 전환
CustomScrollView(
  controller: scrollController,
  slivers: [
    SliverToBoxAdapter(child: Header),
    SliverToBoxAdapter(child: TabBar),
    SliverToBoxAdapter(child: _buildTabContent()),  // 탭 인덱스에 따라 전환
  ],
)

Widget _buildTabContent() {
  switch (_currentTabIndex) {
    case 0: return ExhibitDetailTabContent(...);
    case 1: return ExhibitMapTabContent(...);
    case 2: return ExhibitReviewTabContent(...);
  }
}
```

**트레이드오프**:
- ✅ 바텀시트 확장/축소 동작
- ✅ 헤더 + 탭바 + 콘텐츠 통합 스크롤
- ❌ 탭바 상단 고정 (pinned)
- ❌ 탭 스와이프 전환

## 주의사항

1. **CLAUDE.md 업데이트 필수**: 프로젝트 구조, 패턴, 규칙 변경 시 이 문서 업데이트
2. **기존 패턴 따르기**: 새 기능 추가 시 기존 코드 패턴 참고
3. **Lint 준수**: `flutter analyze` 통과 확인
4. **코드 생성 파일 수정 금지**: `.freezed.dart`, `.g.dart` 파일 직접 수정 금지
5. **기존 위젯 수정 주의**: 다른 곳에서 사용 중인 위젯 수정 시, 영향 범위 확인 후 필요시 새 위젯 생성
