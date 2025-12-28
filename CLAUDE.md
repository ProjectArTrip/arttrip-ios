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
│   ├── views/                   # 페이지 및 섹션 뷰
│   ├── widgets/                 # 재사용 가능한 위젯
│   ├── viewmodels/              # ViewModel (상태 관리)
│   ├── services/                # 서비스 (비즈니스 로직)
│   └── data/
│       ├── models/              # 데이터 모델
│       ├── *_repository.dart    # Repository
│       └── *_api_service.dart   # API 서비스
│
├── shared/                      # 공통 컴포넌트
│   ├── widgets/                 # 공용 위젯 (AsyncView, etc.)
│   ├── viewmodels/              # 공용 ViewModel
│   ├── pages/                   # 공용 페이지
│   ├── models/                  # 공용 모델
│   └── utils/                   # 유틸리티 (ArtTripText, etc.)
│
├── routes/                      # 라우팅 설정
└── l10n/                        # 다국어 리소스
```

### 폴더 구분 기준

| 폴더 | 용도 | 예시 |
|------|------|------|
| `views/` | 페이지 및 섹션 뷰 | `exhibit_detail_page.dart`, `splash_view.dart` |
| `widgets/` | 재사용 가능한 작은 위젯 | `exhibit_header_section.dart` |
| `widgets/{기능명}/` | 특정 기능 관련 위젯 그룹 | `widgets/write_review/` |
| `viewmodels/` | ViewModel (상태 관리) | `exhibit_detail_viewmodel.dart` |
| `services/` | 서비스 (비즈니스 로직) | `auth_service.dart`, `token_storage_service.dart` |
| `models/` | 데이터 모델 | `exhibit_detail.dart` |

**폴더 네이밍 규칙**: 여러 파일을 담는 폴더는 **복수형** 사용 (`views/`, `widgets/`, `viewmodels/`, `services/`, `models/`)

## 코딩 스타일

### StatefulWidget 메서드 순서

**라이프사이클 메서드 먼저, 커스텀 메서드는 build 아래**

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

### 코드 포맷팅

**코드 작성 후 항상 `dart format .` 실행**

```bash
dart format .
```

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

**모든 텍스트는 반드시 `ArtTripText` 사용 (TextStyle 직접 정의 금지)**

```dart
// Good - 텍스트 위젯
ArtTripText.pretendard()
    .body01Bold()
    .color(AppColors.textPrimary)
    .build()
    .text('텍스트')

// Good - TextField 등에서 TextStyle이 필요한 경우
TextField(
  style: ArtTripText.pretendard()
      .body01Regular()
      .color(AppColors.textPrimary)
      .build()
      .style(),  // .style()로 TextStyle 추출
  decoration: InputDecoration(
    hintStyle: ArtTripText.pretendard()
        .body01Regular()
        .color(AppColors.textTertiary)
        .build()
        .style(),
  ),
)

// Bad - TextStyle 직접 정의
Text(
  '텍스트',
  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
)

// Bad - TextField에서 TextStyle 직접 정의
TextField(
  style: TextStyle(fontFamily: 'Pretendard', fontSize: 14.sp),
)
```

사용 가능한 스타일:
- `headline()` - 헤드라인 (20px/28px)
- `title01Bold/Light()` - 제목1 (18px/20px)
- `title02Bold/Light()` - 제목2 (16px/18px)
- `body01Bold/Regular/Light()` - 본문1 (14px/20px 또는 16px)
- `body02Bold/Regular/Light()` - 본문2 (12px)
- `body03Regular()` - 본문3 (11px)

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

### ViewModel Provider 등록

**모든 ViewModel은 `provider_config.dart`에 전역 등록**

```dart
// lib/core/config/provider_config.dart
ChangeNotifierProvider<WriteReviewViewModel>(
  create: (_) => WriteReviewViewModel(
    AppConsts.useMock
        ? ExhibitRepositoryMockImpl()
        : ExhibitRepositoryImpl(DioClient.instance),
  ),
),
```

**페이지에서 ChangeNotifierProvider 직접 사용 금지**

```dart
// Bad - 페이지에서 직접 Provider 생성
return ChangeNotifierProvider(
  create: (_) => WriteReviewViewModel(...),  // ❌
  child: Scaffold(...),
);

// Good - InitWidget + reset() 패턴
return InitWidget(
  init: () => context.read<WriteReviewViewModel>().reset(),  // ✅
  child: Scaffold(...),
);
```

**이유**:
- 일관된 Provider 관리 (한 곳에서 모든 ViewModel 확인)
- 모달이 다시 열릴 때 이전 상태가 남아있는 문제 방지
- `reset()` 메서드로 명시적 상태 초기화

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

// 기본 페이지 이동
Routes.push(context, '/exhibit/${item.exhibitId}');

// 모달 페이지 (결과 반환)
var result = await Routes.modal<bool>(
  context,
  '/exhibit/write-review/$exhibitId',
  extra: WriteReviewParams(...),
);
if (result == true) {
  // 성공 처리
}
```

### 라우트 정의 패턴

**Path Parameter + Extra 조합**

```dart
// 라우트 정의 (app_router.dart)
GoRoute(
  path: '/exhibit/write-review/:id',
  pageBuilder: (context, state) {
    var id = int.parse(state.pathParameters['id']!);
    var params = state.extra as WriteReviewParams;
    return buildPage(context, state, child: WriteReviewPage(exhibitId: id, params: params));
  },
),
```

**규칙**:
- ID 등 필수 값: path parameter 사용 (`:id`)
- 복잡한 객체: extra로 전달
- 모달 결과: 제네릭 타입으로 반환값 지정 (`Routes.modal<bool>`)

### 라우트 파라미터 모델

**라우트 전달용 파라미터 클래스는 `route_params.dart`에 정의**

```dart
// lib/routes/route_params.dart
class WebViewParams {
  const WebViewParams({required this.title, required this.url});

  final String title;
  final String url;
}
```

**위치 규칙**:
- 라우트 전달용 파라미터: `lib/routes/route_params.dart`
- 일반 데이터 모델: `lib/features/{feature}/data/models/`

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

## API / Repository 패턴

### Repository 메서드 구조

**일관된 패턴 유지**

```dart
@override
Future<ModelType?> fetchSomething(int id) async {
  try {
    var response = await _dio.get('/endpoint/$id');
    var apiResponse = ApiResponse<ModelType>.fromJson(
      response.dataOrNull,
      (obj) => ModelType.fromJson(obj as Map<String, dynamic>),
    );
    return apiResponse.result;
  } catch (e) {
    AppUtil.debugLog('fetchSomething: $e');
  }
  return null;
}
```

**규칙**:
- `try-catch`로 감싸고 `AppUtil.debugLog`로 에러 로깅
- `ApiResponse.fromJson`으로 응답 파싱 후 `apiResponse.result` 반환
- 실패 시 `null` 반환

### Form-data 요청 (파일 업로드)

**JSON 필드 + 파일 업로드 조합**

```dart
Future<Result?> createWithFiles({
  required int id,
  required List<XFile> files,
  required String data,
}) async {
  try {
    // JSON 필드는 MultipartFile.fromString + contentType 지정
    var requestJson = jsonEncode({'field': data});
    var formData = FormData.fromMap({
      'request': MultipartFile.fromString(
        requestJson,
        contentType: DioMediaType.parse('application/json'),
      ),
    });

    // 파일 추가 (for-in 사용)
    for (var file in files) {
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(file.path, filename: file.name),
        ),
      );
    }

    var response = await _dio.post('/endpoint/$id', data: formData);
    var apiResponse = ApiResponse<Result>.fromJson(
      response.dataOrNull,
      (obj) => Result.fromJson(obj as Map<String, dynamic>),
    );
    return apiResponse.result;
  } catch (e) {
    AppUtil.debugLog('createWithFiles: $e');
  }
  return null;
}
```

**주의**:
- JSON 필드에 `contentType: DioMediaType.parse('application/json')` 필수
- 파일 리스트가 빈 배열이면 파일 없이 요청됨 (선택적 파일 업로드)

## 버튼 구현 패턴

**GestureDetector + Container 사용 (OutlinedButton/ElevatedButton 사용 금지)**

```dart
// Good - GestureDetector + Container
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

// Bad - OutlinedButton/ElevatedButton
OutlinedButton(
  onPressed: () => Navigator.of(context).pop(),
  child: Text('취소'),
)
```

**비활성화 상태 처리**:
- `onTap: _canConfirm ? _onPressed : null`
- 배경색 조건부 변경: `color: _canConfirm ? AppColors.primary300 : AppColors.primary100`

## 다이얼로그 패턴

### 공용 다이얼로그

| 위젯 | 용도 | 파일 |
|------|------|------|
| `AppConfirmDialog` | 확인/취소 다이얼로그 | `shared/widgets/app_confirm_dialog.dart` |
| `AppInputDialog` | 입력 + 검증 다이얼로그 | `shared/widgets/app_input_dialog.dart` |

### 다이얼로그 구조

**static show() 헬퍼 메서드 패턴**

```dart
class AppInputDialog extends StatefulWidget {
  // ...

  /// 다이얼로그 표시 헬퍼 메서드
  static Future<String?> show({
    required BuildContext context,
    required String title,
    // ...
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => AppInputDialog(...),
    );
  }
}

// 사용
var result = await AppInputDialog.show(
  context: context,
  title: context.l10n.changeNicknameTitle,
  // ...
);
```

### 입력 다이얼로그 검증 패턴

```dart
AppInputDialog.show(
  context: context,
  title: context.l10n.changeNicknameTitle,
  hintText: context.l10n.changeNicknamePlaceholder,
  cancelText: context.l10n.cancel,
  confirmText: context.l10n.changeNicknameButton,
  initialValue: currentNickname,
  maxLength: 10,
  // 동기 검증 - 빈 문자열 반환 시 버튼만 비활성화 (에러 메시지 없음)
  validator: (value, initial) {
    if (value == initial) return '';  // 기존값과 같으면 변경 불가
    return null;  // 유효
  },
  // 비동기 검증 - API 호출
  asyncValidator: (value) async {
    return await context.read<MyViewModel>().updateNickname(value);
  },
);
```

## Repository 에러 처리 패턴

### 에러 메시지 반환 패턴

**API 호출 결과를 에러 메시지로 반환하는 경우**

```dart
/// 닉네임 변경 - 성공 시 null, 실패 시 에러 메시지 반환
Future<String?> updateNickname(String nickname) async {
  try {
    var response = await _dio.patch('/my/nickname', data: {'nickName': nickname});
    var apiResponse = ApiResponse<void>.fromJson(response.dataOrNull, (_) {});
    if (apiResponse.isSuccess) {
      return null;  // 성공
    }
    return apiResponse.message;  // 서버 에러 메시지
  } on DioException catch (e) {
    // HTTP 에러 (400, 409 등)에서 메시지 추출
    var data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? '기본 에러 메시지';
    }
    AppUtil.debugLog('updateNickname: $e');
  } catch (e) {
    AppUtil.debugLog('updateNickname: $e');
  }
  return '기본 에러 메시지';
}
```

**반환값 규칙**:
- `null` 반환 = 성공
- `String` 반환 = 실패 (에러 메시지)

### ViewModel에서 사용

```dart
/// 닉네임 변경 - 성공 시 null, 실패 시 에러 메시지 반환
Future<String?> updateNickname(String nickname) async {
  var error = await _repository.updateNickname(nickname);
  if (error == null) {
    await fetchUserProfile();  // 성공 시 데이터 새로고침
  }
  return error;
}
```

## 바텀시트 패턴

### 공용 함수 형태

```dart
// profile_image_bottom_sheet.dart
enum ProfileImageAction { gallery, camera, delete }

Future<ProfileImageAction?> showProfileImageBottomSheet(BuildContext context) {
  return showModalBottomSheet<ProfileImageAction>(
    context: context,
    // ...
  );
}

// 사용
var action = await showProfileImageBottomSheet(context);
if (action == null) return;

switch (action) {
  case ProfileImageAction.gallery:
    await _pickImageFromGallery();
    break;
  // ...
}
```

## 파일 네이밍 규칙

| 유형 | 패턴 | 예시 |
|------|------|------|
| 페이지 | `*_page.dart` | `edit_profile_page.dart` |
| 위젯 | `*_widget.dart` 또는 기능명 | `edit_profile_field.dart` |
| 다이얼로그 | `*_dialog.dart` | `app_input_dialog.dart` |
| 바텀시트 | `*_bottom_sheet.dart` | `profile_image_bottom_sheet.dart` |
| ViewModel | `*_viewmodel.dart` | `my_viewmodel.dart` |
| Repository | `*_repository.dart` | `my_repository.dart` |
| Repository Mock | `*_repository_mock.dart` | `my_repository_mock.dart` |
| 모델 | `*_model.dart` | `user_profile_model.dart` |

## 주의사항

1. **CLAUDE.md 업데이트 필수**: 프로젝트 구조, 패턴, 규칙 변경 시 이 문서 업데이트
2. **기존 패턴 따르기**: 새 기능 추가 시 기존 코드 패턴 참고
3. **Lint 준수**: `flutter analyze` 통과 확인
4. **코드 생성 파일 수정 금지**: `.freezed.dart`, `.g.dart` 파일 직접 수정 금지
5. **기존 위젯 수정 주의**: 다른 곳에서 사용 중인 위젯 수정 시, 영향 범위 확인 후 필요시 새 위젯 생성
6. **AI 관련 언급 금지**: 커밋 메시지, PR, 문서에서 Claude, AI, 자동 생성 등 AI 도움을 받은 느낌의 문구 사용 금지. 개발자가 직접 작성한 것처럼 자연스럽게 작성
