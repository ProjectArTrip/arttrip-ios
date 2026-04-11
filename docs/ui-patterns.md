# UI 패턴

## 공용 위젯 목록

| 위젯 | 용도 | 파일 |
|------|------|------|
| `AsyncView<T>` | 로딩/에러/성공 상태 UI 처리 | `shared/widgets/async_view.dart` |
| `InitWidget` | 위젯 초기화 시 콜백 실행 (postFrameCallback) | `shared/widgets/init_widget.dart` |
| `CommonAppBar` | 통일된 앱바 (뒤로가기 + 제목 + 액션) | `shared/widgets/common_appbar.dart` |
| `ExhibitListItem` | 전시 리스트 카드 (이미지+정보+즐겨찾기) | `shared/widgets/exhibit_list_item.dart` |
| `ExhibitStatusBadge` | 리스트용 전시 상태 배지 (모서리 형태) | `shared/widgets/exhibit_status_badge.dart` |
| `ExhibitDetailStatusBadge` | 상세페이지용 전시 상태 배지 (칩 형태) | `shared/widgets/exhibit_status_badge.dart` |
| `AppCachedImage` | 네트워크 이미지 + Shimmer 로딩 + 에러 폴백 | `shared/widgets/app_cached_image.dart` |
| `ShimmerSkeletonItem` | 로딩 스켈레톤 아이템 | `shared/widgets/shimmer_skeleton_item.dart` |
| `ExhibitListItemSkeleton` | 전시 리스트 아이템 스켈레톤 | `shared/widgets/exhibit_list_item_skeleton.dart` |
| `AppConfirmDialog` | 확인/취소 다이얼로그 | `shared/widgets/app_confirm_dialog.dart` |
| `AppInputDialog` | 입력 + 동기/비동기 검증 다이얼로그 | `shared/widgets/app_input_dialog.dart` |
| `AppToast` | 플로팅 토스트 메시지 | `shared/widgets/app_toast.dart` |
| `AppDivider` | 커스텀 디바이더 (색상, 높이, 패딩) | `shared/widgets/app_divider.dart` |
| `AlertBadge` | 알림 아이콘 + 읽지않음 빨간 점 | `shared/widgets/alert_badge.dart` |
| `SocialLoginButton` | 소셜 로그인 버튼 (아이콘+라벨) | `shared/widgets/social_login_button.dart` |
| `CalendarBottomSheet` | 달력 날짜 선택 바텀시트 | `shared/widgets/calendar_bottom_sheet.dart` |
| `BottomNavBar` | 하단 네비게이션 바 (5탭) | `shared/widgets/bottom_nav_bar.dart` |
| `MainShell` | GNB 쉘 (Scaffold + BottomNavBar) | `shared/widgets/main_shell.dart` |

## 앱바 패턴

```dart
// 기본 앱바 (뒤로가기 + 제목)
CommonAppBar(title: context.l10n.myReviewsTitle)

// 뒤로가기 없이
CommonAppBar(title: '제목', showBackButton: false)

// 액션 버튼 추가
CommonAppBar(title: '제목', actions: [AlertBadge()])

// 배경색 변경
CommonAppBar(title: '제목', backgroundColor: Colors.transparent)
```

규격: 높이 52.h, 중앙 정렬 제목, leading 너비 48.w

## 이미지 패턴

### 네트워크 이미지 캐싱

```dart
AppCachedImage(
  imageUrl: posterUrl,
  width: 100,
  height: 100,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(8.r),
)
```

- 로딩: Shimmer + ShimmerSkeletonItem
- 에러: 회색 배경 + image_not_supported 아이콘

### 이미지 없을 때 플레이스홀더

```dart
if (imageUrl != null)
  AppCachedImage(imageUrl: imageUrl)
else
  Container(color: AppColors.gray100)
```

### 프로필 이미지

- 기본: `AppAssets.icEmptyProfile` (SVG)
- 원형: `ClipOval` 또는 `borderRadius: 100`
- 업로드: PATCH `/me/image` (multipart)
- 삭제: DELETE `/me/image`

### 이미지 업로드 제약

| 항목 | 값 |
|------|-----|
| 최대 이미지 수 | 4개 (리뷰 첨부) |
| 이미지 품질 | quality 80 |
| 최대 크기 | maxWidth 1024, maxHeight 1024 |
| 소스 | Gallery (pickMultiImage), Camera (pickImage) |

```dart
var images = await ImagePicker().pickMultiImage(
  maxWidth: 1024, maxHeight: 1024, imageQuality: 80,
);
```

## 스켈레톤 로딩 패턴

```dart
// 개별 스켈레톤 아이템
ShimmerSkeletonItem(width: 120, height: 16, radius: 10)

// Shimmer 애니메이션으로 감싸기
Shimmer(
  duration: Duration(milliseconds: AppConsts.shimmerDurationMs),  // 1200ms
  interval: Duration(milliseconds: AppConsts.shimmerIntervalMs),  // 400ms
  child: Column(children: [
    ShimmerSkeletonItem(width: 100, height: 100, radius: 8),
    ShimmerSkeletonItem(width: 160, height: 16, radius: 10),
  ]),
)
```

## 전시 상태 배지

| 상태 | 리스트 배지 | 상세 칩 |
|------|-----------|---------|
| `onGoing` | subLime 배경, 우하단 모서리 | subLime 배경, 독립 칩 |
| `endingSoon` | gray0 + gray50 테두리 | gray0 + gray50 테두리 |
| `upcoming` | subLightGray + gray100 테두리, textPoint 색 | subLightGray + gray100 테두리, textPoint 색 |
| `finished` | 숨김 (SizedBox.shrink) | 숨김 |

## 다이얼로그 패턴

### 확인/취소 다이얼로그

```dart
var result = await AppConfirmDialog.show(
  context: context,
  title: context.l10n.deleteReviewTitle,
  content: Text(context.l10n.deleteReviewContent),
  cancelText: context.l10n.cancel,
  confirmText: context.l10n.confirm,
);
if (result == true) { /* 확인 */ }
```

### 입력 다이얼로그 (동기+비동기 검증)

```dart
var result = await AppInputDialog.show(
  context: context,
  title: context.l10n.changeNicknameTitle,
  hintText: context.l10n.changeNicknamePlaceholder,
  cancelText: context.l10n.cancel,
  confirmText: context.l10n.changeNicknameButton,
  initialValue: currentNickname,
  maxLength: 10,
  // 동기 검증: null=유효, ''=버튼만 비활성화(에러 없음), 'msg'=에러 표시
  validator: (value, initial) {
    if (value == initial) return '';
    return null;
  },
  // 비동기 검증: null=성공, String=에러 메시지
  asyncValidator: (value) async {
    return await context.read<MyViewModel>().updateNickname(value);
  },
);
```

**static show() 헬퍼 메서드 패턴**: 다이얼로그 위젯에 `static Future<T?> show()`를 두어 호출 간소화

## 바텀시트 패턴

### 전역 함수 형태

```dart
enum ProfileImageAction { gallery, camera, delete }

Future<ProfileImageAction?> showProfileImageBottomSheet(BuildContext context) {
  return showModalBottomSheet<ProfileImageAction>(
    context: context,
    builder: (context) => /* 위젯 */,
  );
}

// 사용
var action = await showProfileImageBottomSheet(context);
if (action == null) return;
switch (action) {
  case ProfileImageAction.gallery: /* ... */
  case ProfileImageAction.camera: /* ... */
  case ProfileImageAction.delete: /* ... */
}
```

### 캘린더 바텀시트

```dart
var selectedDate = await showCalendarBottomSheet(
  context: context,
  initialDate: currentDate,
  firstDate: DateTime(2000),
  lastDate: DateTime.now(),
);
```

## 스낵바 / 토스트 패턴

### AppToast (간단한 알림)

```dart
AppToast.show(
  context,
  message: context.l10n.copyCompleted,
  bottomMargin: 108,               // 기본값
  duration: Duration(seconds: 2),   // 기본값
);
```

### SnackBarUtils (타입별 알림)

```dart
SnackBarUtils.showSuccess(context, message: '저장 완료');
SnackBarUtils.showError(context, message: '실패했습니다');
SnackBarUtils.showWarning(context, message: '주의');
SnackBarUtils.showInfo(context, message: '안내');
SnackBarUtils.hide(context);
SnackBarUtils.clearAll(context);
```

## 조건부 표시

```dart
// 데이터 있을 때만 표시
if (exhibit.hallAddress.isNotEmpty) {
  infoItems.add(ExhibitInfoRow(...));
}

// 모든 항목이 비어있으면 전체 컨테이너도 숨김
if (infoItems.isEmpty) return const SizedBox.shrink();
```

## 스크롤 패턴

### DraggableScrollableSheet + 탭 콘텐츠

Flutter 한계: `DraggableScrollableSheet` + `NestedScrollView` + `TabBarView` 스크롤 통합 불가.

**해결책**: `CustomScrollView` + 탭 인덱스 기반 콘텐츠 전환

```dart
CustomScrollView(
  controller: scrollController,
  slivers: [
    SliverToBoxAdapter(child: Header),
    SliverToBoxAdapter(child: TabBar),
    SliverToBoxAdapter(child: _buildTabContent()),
  ],
)

Widget _buildTabContent() {
  switch (_currentTabIndex) {
    case 0: return DetailTab;
    case 1: return MapTab;
    case 2: return ReviewTab;
  }
}
```

트레이드오프: 바텀시트 동작 + 통합 스크롤 OK / 탭바 고정 + 스와이프 전환 불가

## Google Maps 패턴

### 전시 상세 지도 (읽기 전용)

```dart
if (exhibit.hallLatitude != null && exhibit.hallLongitude != null)
  GoogleMap(
    initialCameraPosition: CameraPosition(
      target: LatLng(exhibit.hallLatitude!, exhibit.hallLongitude!),
      zoom: 15,
    ),
    markers: {Marker(markerId: MarkerId('venue'), position: ...)},
    zoomControlsEnabled: false,
    scrollGesturesEnabled: false,
    rotateGesturesEnabled: false,
  )
else
  Text(context.l10n.noMapInfo)
```

외부 앱: `comgooglemaps://` URI 스킴 → 실패 시 웹 URL 폴백

### 지도 탭 (클러스터링)

`google_maps_cluster_manager_2` 패키지 사용. `ClusterManager`와 `google_maps_flutter`의 `ClusterManager` 이름 충돌에 주의.

```dart
// import 시 hide 필수
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    hide Cluster, ClusterManager;
```

**클러스터 아이템**: Freezed 모델은 `ClusterItem`을 직접 구현 불가 → 래퍼 클래스 사용

```dart
class MapClusterItem with ClusterItem {
  MapClusterItem(this.marker);
  final MapMarkerModel marker;

  @override
  LatLng get location => LatLng(marker.lat, marker.lng);
}
```

**클러스터 렌더링**: `Canvas` + `PictureRecorder` → `BitmapDescriptor.bytes(imagePixelRatio:)` 패턴

```dart
// 고해상도로 그리되 논리적 크기로 표시
return BitmapDescriptor.bytes(
  byteData!.buffer.asUint8List(),
  imagePixelRatio: devicePixelRatio,  // 필수 - 없으면 마커가 거대하게 표시됨
);
```

**StatefulShellRoute 주의사항**: `IndexedStack`이 탭 상태를 유지하므로 `GoogleMapController.dispose()` 직접 호출 금지 (플랫폼 뷰 ID 충돌 발생)

**Stack 레이어 순서**: 바텀시트가 전체 화면을 덮으므로 카테고리 바는 바텀시트보다 **뒤에**(Stack에서 나중에) 배치해야 탭 이벤트가 가로채지지 않음

```dart
Stack(children: [
  GoogleMap(...),           // 1. 지도
  위치 버튼,                 // 2. 바텀시트에 가려짐
  바텀시트(Positioned.fill), // 3. 전체 화면 덮음
  카테고리 바,               // 4. 최상위 레이어 (탭 가능)
])
```
