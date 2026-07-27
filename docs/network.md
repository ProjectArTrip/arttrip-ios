# 네트워크 계층

## 아키텍처 개요

```
View → ViewModel → Repository → DioClient → Server
                                    ↓
                          Interceptor Chain (순서 중요):
                          1. AuthInterceptor   — 토큰 주입/갱신
                          2. LoggingInterceptor — 디버그 로깅
                          3. RetryInterceptor   — 지수 백오프 재시도
                          4. ErrorInterceptor   — 예외 변환 (항상 마지막)
```

## DioClient (싱글톤)

```dart
// 접근
DioClient.instance  // 또는 DioClient.I

// 초기화 (main.dart에서 1회)
DioClient.instance.initialize(
  options: DioClientOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    enableLogging: true,
    enableRetry: true,
    maxRetries: 3,
  ),
  authInterceptor: AuthInterceptor(...),
);
```

### HTTP 메서드

모두 `ApiResult<T>` 반환:

```dart
DioClient.instance.get<T>(path, {queryParameters, options, cancelToken, fromJson})
DioClient.instance.post<T>(path, {data, queryParameters, options, cancelToken, fromJson})
DioClient.instance.put<T>(path, {data, queryParameters, options, cancelToken, fromJson})
DioClient.instance.patch<T>(path, {data, queryParameters, options, cancelToken, fromJson})
DioClient.instance.delete<T>(path, {data, queryParameters, options, cancelToken, fromJson})
DioClient.instance.upload<T>(path, {formData, queryParameters, options, cancelToken, onSendProgress, fromJson})
DioClient.instance.download(url, savePath, {queryParameters, options, cancelToken, onReceiveProgress})
```

### 유틸리티

```dart
DioClient.instance.setHeader(key, value)
DioClient.instance.removeHeader(key)
DioClient.instance.cancelAllRequests()
```

## ApiResult<T> (Sealed Class, Freezed)

```dart
// 성공/실패 분기 처리
var result = await DioClient.instance.get<T>('/path');
result.when(
  success: (data) => /* T data */,
  failure: (exception) => /* NetworkException */,
);

// 간편 접근
result.dataOrNull   // T? — 성공 시 데이터, 실패 시 null
result.isSuccess    // bool
result.isFailure    // bool
```

## ApiResponse<T> (서버 응답 래퍼)

서버 표준 응답 포맷:

```json
{ "isSuccess": true, "code": "200", "message": "성공", "result": { ... } }
```

```dart
var apiResponse = ApiResponse<ModelType>.fromJson(
  response.dataOrNull,
  (obj) => ModelType.fromJson(obj as Map<String, dynamic>),
);
apiResponse.isSuccess  // bool
apiResponse.message    // String
apiResponse.result     // T?
```

### result 래퍼 없는 API

일부 API(`/map/exhibits/markers`, `/map/cluster`)는 `{isSuccess, result}` 래퍼 없이 바로 데이터를 반환함.
Repository에서 `result` 키 존재 여부로 분기 처리:

```dart
final map = data as Map<String, dynamic>;
final target = map.containsKey('result')
    ? map['result'] as Map<String, dynamic>
    : map;
return Model.fromJson(target);
```

## 인터셉터

### AuthInterceptor

- 모든 요청에 `Authorization: Bearer {accessToken}` 자동 추가
- 401 응답 시 에러 코드 기반 처리:
  - `JWT401-EXPIRED_REFRESH` → 즉시 로그아웃
  - `JWT401-EXPIRED_ACCESS`, `JWT401-EMPTY_TOKEN` → 토큰 갱신 시도
- 토큰 갱신 중 다른 요청은 큐에 대기 → 갱신 완료 후 자동 재시도
- **퍼블릭 엔드포인트** (토큰 불필요): `/auth/login`, `/auth/register`, `/auth/refresh`, `/auth/social`, `/auth/app/reissue`, `/health`

### RetryInterceptor

- **재시도 대상**: 상태 코드 408, 429, 500, 502, 503, 504 + 타임아웃 + 연결 에러
- **최대 재시도**: 3회 (설정 가능)
- **지수 백오프**: `baseDelay * 2^retryCount + 랜덤 지터`
- **재시도 제외**: `/auth/app/logout`, `/auth/social`

### ErrorInterceptor

- 모든 `DioException` → `NetworkException`으로 변환
- 포맷된 에러 로그 출력 (디버그)
- 항상 인터셉터 체인 **마지막**에 위치

### LoggingInterceptor

- 요청/응답 로깅 (디버그 모드만)
- 응답 시간 측정: `[API] ✓ POST /path → 200 (125ms)`
- FormData 필드/파일 로깅

## NetworkException (Sealed Class)

### 타입 목록

| 카테고리 | 타입 |
|---------|------|
| 타임아웃 | `ConnectionTimeout`, `SendTimeout`, `ReceiveTimeout`, `RequestTimeout` |
| 연결 | `NoInternetConnection`, `BadCertificate` |
| 4xx | `BadRequest`, `Unauthorized`, `Forbidden`, `NotFound`, `MethodNotAllowed`, `Conflict`, `UnprocessableEntity`, `TooManyRequests` |
| 5xx | `InternalServerError`, `BadGateway`, `ServiceUnavailable`, `GatewayTimeout` |
| 기타 | `RequestCancelled`, `Unexpected` |

### 팩토리 메서드

```dart
NetworkException.fromDioException(dioError)     // DioException → NetworkException
NetworkException.fromStatusCode(statusCode: 404) // 상태 코드 → NetworkException
```

### 속성

```dart
exception.message     // String
exception.statusCode  // int?
exception.data        // Object?
```

## 인증 플로우

### 로그인

```
LoginPage
  → KakaoLoginService.login()       // Kakao SDK → idToken 획득
  → AuthService.loginWithKakao()    // POST /auth/social → 토큰 발급
  → TokenStorageService.saveTokens() // accessToken + refreshToken 저장
  → firstLogin == true ? '/onboarding/keywords' : '/'
```

### 토큰 갱신

```
API 요청 → 401 에러
  → AuthInterceptor.onError()
  → 에러코드 확인
  → EXPIRED_ACCESS → POST /auth/app/reissue → 새 토큰 → 원래 요청 재시도
  → EXPIRED_REFRESH → 로그아웃 → '/login'으로 이동
```

### 로그아웃

```
AuthService.logout()
  → POST /auth/app/logout (실패해도 무시)
  → KakaoLoginService.logout()
  → TokenStorageService.clearTokens()
  → Prefs().clearAuthData()
```

## Repository 패턴

### 4단계 구현

```dart
// 1. Abstract (인터페이스)
abstract class ExhibitRepository {
  Future<ExhibitDetailModel?> fetchExhibitDetail(int exhibitId);
}

// 2. Impl (실제 API)
class ExhibitRepositoryImpl implements ExhibitRepository {
  final DioClient _dio;
  ExhibitRepositoryImpl(this._dio);
  // ...
}

// 3. Mock (개발/테스트)
class ExhibitRepositoryMockImpl implements ExhibitRepository {
  // 고정 더미 데이터, 500ms 딜레이
}

// 4. Hybrid (AppConsts.useMock로 분기)
class ExhibitRepositoryHybrid implements ExhibitRepository {
  final _mock = ExhibitRepositoryMockImpl();
  final ExhibitRepositoryImpl _api;
  // useMock ? _mock : _api
}
```

### Repository 메서드 패턴

```dart
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

**규칙**: try-catch + AppUtil.debugLog + 실패 시 null 반환

### 에러 메시지 반환 패턴

성공 시 `null`, 실패 시 에러 메시지 `String` 반환:

```dart
Future<String?> updateNickname(String nickname) async {
  try {
    var response = await _dio.patch('/me', data: {'nickName': nickname});
    var apiResponse = ApiResponse<void>.fromJson(response.dataOrNull, (_) {});
    if (apiResponse.isSuccess) return null;
    return apiResponse.message;
  } on DioException catch (e) {
    var data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? '기본 에러 메시지';
    }
  } catch (e) {
    AppUtil.debugLog('updateNickname: $e');
  }
  return '기본 에러 메시지';
}
```

### Form-data 요청 (파일 업로드)

```dart
// JSON 필드 + 파일 업로드 조합
var requestJson = jsonEncode({'date': date, 'content': content});
var formData = FormData.fromMap({
  'request': MultipartFile.fromString(
    requestJson,
    contentType: DioMediaType.parse('application/json'),  // 필수
  ),
});

for (var file in files) {
  formData.files.add(MapEntry(
    'files',
    await MultipartFile.fromFile(file.path, filename: file.name),
  ));
}

var response = await _dio.post('/endpoint/$id', data: formData);
```

## ConnectivityService (싱글톤)

```dart
ConnectivityService.instance.initialize();

bool isOnline = ConnectivityService.instance.isOnline;
Stream<ConnectivityStatus> stream = ConnectivityService.instance.onConnectivityChanged;

enum ConnectivityStatus { wifi, mobile, ethernet, other, offline, unknown }
```
