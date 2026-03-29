# 라우팅

## 개요

**GoRouter 17.0.0** 사용. `StatefulShellRoute`로 5탭 하단 네비게이션 상태 보존.

## 네비게이션 메서드

```dart
import 'package:arttrip/routes/routes.dart';

// 기본 페이지 이동
Routes.push(context, '/exhibit/${item.exhibitId}');

// 전환 애니메이션 지정
Routes.push(context, '/path', transition: TransitionType.fade);

// 모달 페이지 (결과 반환)
var result = await Routes.modal<bool>(
  context,
  '/exhibit/write-review/$exhibitId',
  extra: WriteReviewParams(...),
);
if (result == true) { /* 성공 처리 */ }

// 페이지 교체 (뒤로가기 불가, fade 전환)
await Routes.replace(context, '/path');

// 전체 스택 교체 (루트로 이동)
Routes.go(context, '/');
```

## 전환 애니메이션

```dart
enum TransitionType { none, fade, slideUp, slideDown }
```

`route_builder.dart`의 `buildPage()`에서 처리:
- `?trans=fade` → FadeTransition
- `?trans=slideUp` → SlideTransition (아래→위)
- `?trans=slideDown` → SlideTransition (위→아래)
- `?modal=true` → fullscreenDialog 모달

## 라우트 경로 상수 (AppRoutes)

```dart
AppRoutes.splash               // '/splash'
AppRoutes.login                // '/login'
AppRoutes.onboardingKeywords   // '/onboarding/keywords'

// 전시 관련
AppRoutes.exhibit              // '/exhibit/:id'
AppRoutes.exhibitPath(id)      // '/exhibit/$id'
AppRoutes.exhibitWriteReview   // '/exhibit/write-review/:id'
AppRoutes.exhibitWriteReviewPath(id)  // '/exhibit/write-review/$id'
AppRoutes.reviewEdit           // '/review/edit/:reviewId'
AppRoutes.reviewEditPath(id)   // '/review/edit/$id'

// 홈 하위
AppRoutes.homeRegion           // '/home/domestic/:regionName'
AppRoutes.homeRegionPath(name) // '/home/domestic/$name'
AppRoutes.homeGenre            // '/home/genre/:genreName'
AppRoutes.homeGenrePath(...)   // '/home/genre/$name'
AppRoutes.search               // '/search'
AppRoutes.alerts               // '/alerts'

// 마이페이지 하위
AppRoutes.myEditProfile        // '/my/edit-profile'
AppRoutes.mySettings           // '/my/settings'
AppRoutes.myTasteAnalysis      // '/my/taste-analysis'
AppRoutes.myRecentExhibits     // '/my/recent-exhibits'
AppRoutes.myReviews            // '/my/reviews'
AppRoutes.webview              // '/webview'
```

## 하단 네비게이션 (GNB)

`StatefulShellRoute.indexedStack`으로 탭별 상태 보존:

| 탭 | 인덱스 | 경로 | 위젯 |
|---|--------|------|------|
| 홈 | 0 | `/` | HomePage |
| 지도 | 1 | `/map` | MapView |
| 스탬프 | 2 | `/stamp` | StampView |
| 보관함 | 3 | `/storage` | StorageView |
| My | 4 | `/my` | MyPage |

## 라우트 정의 패턴

### Path Parameter + Extra 조합

```dart
// 라우트 정의 (app_router.dart)
GoRoute(
  path: '/exhibit/write-review/:id',
  pageBuilder: (context, state) {
    var id = int.parse(state.pathParameters['id']!);
    var params = state.extra as WriteReviewParams;
    return buildPage(context, state,
      child: WriteReviewPage(exhibitId: id, params: params));
  },
),
```

**규칙**:
- ID 등 필수 값: path parameter (`:id`)
- 복잡한 객체: extra로 전달
- 모달 결과: 제네릭 타입으로 반환값 지정 (`Routes.modal<bool>`)

### ExtraCodec

`route_params.dart`에 `ExtraCodec` 정의 — GoRouter의 extra 직렬화 경고 억제 (모바일 전용):

```dart
final appRouter = GoRouter(
  extraCodec: const ExtraCodec(),
  // ...
);
```

## 라우트 파라미터 모델

### 공용 파라미터 (route_params.dart)

```dart
class WebViewParams {
  const WebViewParams({required this.title, required this.url});
  final String title;
  final String url;
}
```

### 기능 고유 파라미터 (features 내부)

```dart
// lib/features/exhibit/data/models/write_review_params.dart
class WriteReviewParams {
  final String? posterUrl;
  final String title;
  final String hallName;
  final int? reviewId;  // null이면 생성, 있으면 편집
  bool get isEditMode => reviewId != null;
}
```

**위치 규칙**:
- 범용 파라미터: `lib/routes/route_params.dart`
- 기능 고유 파라미터: `lib/features/{feature}/data/models/`

## 새 라우트 추가 체크리스트

1. `app_routes.dart`에 경로 상수 추가
2. 필요 시 `static String xxxPath(...)` 헬퍼 메서드 추가
3. `app_router.dart`에 `GoRoute` 정의 추가
4. `buildPage()` 사용하여 페이지 빌더 설정
5. 파라미터가 필요하면 `route_params.dart` 또는 feature models에 정의
