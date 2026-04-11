# 상태 관리

## 개요

**Provider + ChangeNotifier + AsyncState<T>** 패턴 사용.

```
provider_config.dart (전역 DI)
  → ViewModel (ChangeNotifier + AsyncState)
    → View (Selector로 구독)
      → AsyncView (상태별 UI 분기)
```

## AsyncState<T>

```dart
// 3가지 상태
const AsyncState.loading()
AsyncState.success(data)
const AsyncState.error({Object? error})

// 속성
state.status  // AsyncStatus.loading | success | error
state.data    // T? (성공 시)
state.error   // Object? (에러 시)
```

## AsyncView<T>

```dart
AsyncView<T>(
  state: state,
  onData: (data) => Widget,     // 필수 - 성공 UI
  onLoading: () => Widget,      // 선택 - 기본: CircularProgressIndicator
  onError: ({error}) => Widget, // 선택 - 기본: 에러 텍스트 (생략 권장)
  isSliverWidget: false,        // true면 SliverToBoxAdapter로 래핑
)
```

**규칙**: `onError`는 생략하고 기본 에러 UI 사용

## ViewModel 패턴

### 기본 구조

```dart
class ExhibitDetailViewModel extends ChangeNotifier {
  final ExhibitRepository _repository;
  ExhibitDetailViewModel(this._repository);

  // 상태 정의
  AsyncState<ExhibitDetailModel> _exhibitState = const AsyncState.loading();
  AsyncState<ExhibitDetailModel> get exhibitState => _exhibitState;

  // 데이터 로드
  Future<void> fetchExhibitDetail(int id) async {
    _exhibitState = const AsyncState.loading();
    notifyListeners();

    try {
      final data = await _repository.fetchExhibitDetail(id);
      _exhibitState = AsyncState.success(data!);
    } catch (e) {
      _exhibitState = AsyncState.error(error: e);
    }
    notifyListeners();
  }

  // 상태 초기화
  void reset() {
    _exhibitState = const AsyncState.loading();
    notifyListeners();
  }
}
```

### View에서 사용

```dart
// Selector로 특정 상태만 구독 (리빌드 최소화)
Selector<ExhibitDetailViewModel, AsyncState<ExhibitDetailModel>>(
  selector: (_, vm) => vm.exhibitState,
  builder: (context, state, _) {
    return AsyncView<ExhibitDetailModel>(
      state: state,
      onData: (exhibit) => _buildContent(exhibit),
    );
  },
)
```

## Provider 등록

### provider_config.dart에 전역 등록

```dart
// 단순 Provider
ChangeNotifierProvider<MyViewModel>(
  create: (_) => MyViewModel(
    AppConsts.useMock
        ? MyRepositoryMockImpl()
        : MyRepositoryImpl(DioClient.instance),
  ),
),

// ViewModel 간 의존성 (ProxyProvider)
ChangeNotifierProxyProvider<ExhibitViewModel, HomeViewModel>(
  create: (context) => HomeViewModel(
    exhibitVM: context.read<ExhibitViewModel>(),
    homeRepository: HomeRepositoryHybrid(DioClient.instance),
  ),
  update: (context, exhibitVM, homeVM) => homeVM!,
),
```

### 현재 등록된 Provider (9개)

| Provider | 타입 | 의존성 |
|----------|------|--------|
| `AlertViewModel` | ChangeNotifier | 없음 |
| `ExhibitViewModel` | ChangeNotifier | ExhibitRepositoryHybrid |
| `HomeViewModel` | ProxyProvider | ExhibitViewModel + HomeRepositoryHybrid |
| `KeywordModelsViewModel` | ChangeNotifier | KeywordModelsRepository |
| `ExhibitDetailModelViewModel` | ChangeNotifier | ExhibitRepository |
| `WriteReviewViewModel` | ChangeNotifier | ExhibitRepository |
| `MyViewModel` | ChangeNotifier | MyRepository |
| `SearchViewModel` | ChangeNotifier | SearchRepository |
| `MapViewModel` | ProxyProvider | ExhibitViewModel + MapRepositoryHybrid |

### 페이지에서 직접 Provider 생성 금지

```dart
// Bad
return ChangeNotifierProvider(
  create: (_) => WriteReviewViewModel(...),
  child: Scaffold(...),
);

// Good - InitWidget + reset() 패턴
return InitWidget(
  init: () => context.read<WriteReviewViewModel>().reset(),
  child: Scaffold(...),
);
```

## 페이지네이션 패턴 (커서 기반)

### ViewModel

```dart
int? _nextCursor;
bool _hasNext = true;
bool _isLoadingMore = false;

// 초기 로드
Future<void> fetchReviews(int exhibitId) async {
  _reviewsState = const AsyncState.loading();
  notifyListeners();

  var response = await _repository.fetchReviews(exhibitId, size: 10);
  if (response != null) {
    _nextCursor = response.nextCursor;
    _hasNext = response.hasNext;
    _reviewsState = AsyncState.success(response.reviews);
  }
  notifyListeners();
}

// 추가 로드 (스크롤 끝 도달 시)
Future<void> fetchMoreReviews(int exhibitId) async {
  if (_isLoadingMore || !_hasNext) return;
  _isLoadingMore = true;
  notifyListeners();

  var response = await _repository.fetchReviews(
    exhibitId, cursor: _nextCursor, size: 10,
  );
  if (response != null) {
    var currentList = (_reviewsState.data ?? []);
    _reviewsState = AsyncState.success([...currentList, ...response.reviews]);
    _nextCursor = response.nextCursor;
    _hasNext = response.hasNext;
  }
  _isLoadingMore = false;
  notifyListeners();
}
```

### View (스크롤 감지)

```dart
_scrollController.addListener(() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 200) {
    vm.fetchMoreReviews(exhibitId);
  }
});
```

## 즐겨찾기 전역 상태 패턴

`ExhibitViewModel`이 앱 전체의 즐겨찾기 상태를 관리:

```dart
// ExhibitViewModel
Map<int, bool> _favoriteMap = {};

bool isFavorite(int? exhibitId) => _favoriteMap[exhibitId] ?? false;

void updateFavoriteExhibit(int? exhibitId, bool isFavorite) {
  _favoriteMap[exhibitId!] = isFavorite;
  notifyListeners();
  _repository.updateFavoriteExhibit(exhibitId, isFavorite);
}
```

```dart
// View에서 Selector로 특정 아이템만 리빌드
Selector<ExhibitViewModel, bool>(
  selector: (_, vm) => vm.isFavorite(item.exhibitId),
  builder: (context, isFavorite, _) {
    return GestureDetector(
      onTap: () => context.read<ExhibitViewModel>()
          .updateFavoriteExhibit(item.exhibitId, !isFavorite),
      child: SvgPicture.asset(AppAssets.icLikeCircle(isLiked: isFavorite)),
    );
  },
)
```

## 편집/생성 모드 패턴

ViewModel에서 모드를 구분하여 한 화면에서 생성/편집 모두 처리:

```dart
class WriteReviewViewModel extends ChangeNotifier {
  bool _isEditMode = false;
  int? _reviewId;

  // 생성 모드: reset() 호출 후 사용
  void reset({bool notify = true}) {
    _isEditMode = false;
    _reviewId = null;
    _visitDate = null;
    _content = '';
    _selectedImages = [];
    // ...
  }

  // 편집 모드: initForEdit() 호출하여 기존 데이터 로드
  Future<void> initForEdit({required int reviewId}) async {
    _isEditMode = true;
    _reviewId = reviewId;
    var detail = await _repository.fetchReviewDetail(reviewId);
    // 기존 데이터로 상태 채우기
  }

  // 제출 시 모드 분기
  Future<bool> submitReview(int exhibitId) => /* 생성 API */;
  Future<bool> updateReview() => /* 수정 API */;
}
```

## HomeViewModel 캐싱 전략

국내/해외 + 지역/국가별 데이터를 중첩 Map으로 캐싱:

```dart
// 구조: Map<LocationType, Map<area, AsyncState<List<ExhibitModel>>>>
Map<LocationType, Map<String, AsyncState<List<ExhibitModel>>>> _todayExhibitRecommendations;

// 장르별: 3중 중첩
Map<LocationType, Map<String, Map<String, AsyncState<List<ExhibitModel>>>>> _exhibitsByGenre;

// 스크롤 위치 보존
Map<LocationType, double> _scrollOffset;
```

**규칙**: 기존 데이터가 있으면 API 재호출 안 함 (캐시 사용)
