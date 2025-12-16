// ignore_for_file: unused_field, unused_element

import 'package:arttrip/core/network/api_result.dart';
import 'package:arttrip/core/network/base_api_service.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/core/network/interceptors/auth_interceptor.dart';
import 'package:arttrip/core/network/network_exceptions.dart';
import 'package:dio/dio.dart';

// ============================================
// 1. 앱 초기화 시 DioClient 설정
// ============================================

/// main.dart에서 앱 시작 시 호출
Future<void> initializeNetworkLayer() async {
  DioClient.instance.initialize(
    options: const DioClientOptions(
      baseUrl: 'https://api.arttrip.com/v1',
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      enableLogging: true,
      enableRetry: true,
      maxRetries: 3,
    ),
    // 인증이 필요한 경우 AuthInterceptor 추가
    authInterceptor: AuthInterceptor(
      tokenProvider: () async {
        // SharedPreferences나 SecureStorage에서 토큰 가져오기
        // final prefs = await SharedPreferences.getInstance();
        // return prefs.getString('access_token');
        return 'your_access_token';
      },
      onTokenRefresh: () async {
        // Refresh token으로 새 access token 획득
        // final response = await DioClient.I.post('/auth/refresh', ...);
        // return newAccessToken;
        return 'new_access_token';
      },
      onTokenExpired: () async {
        // 로그아웃 처리
        // await AuthService.logout();
        // Navigator.pushReplacementNamed(context, '/login');
      },
    ),
  );
}

// ============================================
// 2. 모델 정의 (예시)
// ============================================

/// 사용자 모델
class User {
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      profileImage: json['profile_image'] as String?,
    );
  }

  final int id;
  final String email;
  final String name;
  final String? profileImage;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image': profileImage,
    };
  }
}

/// 전시회 모델
class Exhibition {
  const Exhibition({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.thumbnailUrl,
  });

  factory Exhibition.fromJson(Map<String, dynamic> json) {
    return Exhibition(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  final int id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String? thumbnailUrl;
}

// ============================================
// 3. API 서비스 구현
// ============================================

/// 사용자 관련 API 서비스
class UserApiService extends BaseApiService {
  UserApiService({super.client});

  /// 현재 사용자 정보 조회
  Future<ApiResult<User>> getCurrentUser() {
    return get<User>(
      '/users/me',
      fromJson: (data) => User.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 사용자 프로필 업데이트
  Future<ApiResult<User>> updateProfile({
    required String name,
    String? profileImage,
  }) {
    return put<User>(
      '/users/me',
      data: {
        'name': name,
        if (profileImage != null) 'profile_image': profileImage,
      },
      fromJson: (data) => User.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 프로필 이미지 업로드
  Future<ApiResult<String>> uploadProfileImage(String filePath) async {
    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    return upload<String>(
      '/users/me/profile-image',
      formData: formData,
      fromJson: (data) => (data as Map<String, dynamic>)['url'] as String,
    );
  }
}

/// 전시회 관련 API 서비스
class ExhibitionApiService extends BaseApiService {
  ExhibitionApiService({super.client});

  /// 전시회 목록 조회 (페이지네이션)
  Future<ApiResult<PaginatedResponse<Exhibition>>> getExhibitions({
    int page = 1,
    int limit = 20,
    String? keyword,
  }) async {
    var result = await get<Map<String, dynamic>>(
      '/exhibitions',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (keyword != null) 'keyword': keyword,
      },
    );

    return result.map(
      (data) => parsePaginatedResponse<Exhibition>(data, Exhibition.fromJson),
    );
  }

  /// 전시회 상세 조회
  Future<ApiResult<Exhibition>> getExhibition(int id) {
    return get<Exhibition>(
      '/exhibitions/$id',
      fromJson: (data) => Exhibition.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 전시회 북마크 추가
  Future<ApiResult<void>> addBookmark(int exhibitionId) async {
    var result = await post<Object?>('/exhibitions/$exhibitionId/bookmark');

    return result.map((_) {});
  }

  /// 전시회 북마크 삭제
  Future<ApiResult<void>> removeBookmark(int exhibitionId) async {
    var result = await delete<Object?>('/exhibitions/$exhibitionId/bookmark');

    return result.map((_) {});
  }
}

// ============================================
// 4. ViewModel/Controller에서 사용 예시
// ============================================

/// 사용 예시를 보여주는 가상의 ViewModel
class _ExampleViewModel {
  final _userService = UserApiService();
  final _exhibitionService = ExhibitionApiService();

  User? currentUser;
  List<Exhibition> exhibitions = [];
  String? errorMessage;
  bool isLoading = false;

  /// 사용자 정보 로드
  Future<void> loadUser() async {
    isLoading = true;

    var result = await _userService.getCurrentUser();

    result.when(
      success: (user) {
        currentUser = user;
        errorMessage = null;
      },
      failure: (exception) {
        errorMessage = exception.message;

        // 특정 에러 타입에 따른 처리
        if (exception is UnauthorizedException) {
          // 로그인 화면으로 이동
        } else if (exception is NoInternetConnectionException) {
          // 오프라인 모드 활성화
        }
      },
    );

    isLoading = false;
  }

  /// 전시회 목록 로드
  Future<void> loadExhibitions({int page = 1}) async {
    isLoading = true;

    var result = await _exhibitionService.getExhibitions(page: page, limit: 20);

    // when 패턴 사용
    result.when(
      success: (response) {
        if (page == 1) {
          exhibitions = response.items;
        } else {
          exhibitions.addAll(response.items);
        }
      },
      failure: (exception) {
        errorMessage = exception.message;
      },
    );

    isLoading = false;
  }

  /// 북마크 토글 (간단한 결과 처리)
  Future<bool> toggleBookmark(int exhibitionId, bool isBookmarked) async {
    var result = isBookmarked
        ? await _exhibitionService.removeBookmark(exhibitionId)
        : await _exhibitionService.addBookmark(exhibitionId);

    // 성공/실패 여부만 확인
    return result.isSuccess;
  }

  /// 데이터 또는 기본값 반환
  Future<User> getUserOrDefault() async {
    var result = await _userService.getCurrentUser();

    // getOrElse 사용
    return result.getOrElse(
      () => const User(id: 0, email: 'guest@example.com', name: 'Guest'),
    );
  }

  /// nullable 데이터 반환
  Future<User?> getUserOrNull() async {
    var result = await _userService.getCurrentUser();

    // dataOrNull 사용
    return result.dataOrNull;
  }
}

// ============================================
// 5. 위젯에서 사용 예시
// ============================================

/*
class ExhibitionListView extends StatefulWidget {
  @override
  _ExhibitionListViewState createState() => _ExhibitionListViewState();
}

class _ExhibitionListViewState extends State<ExhibitionListView> {
  final _service = ExhibitionApiService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResult<PaginatedResponse<Exhibition>>>(
      future: _service.getExhibitions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final result = snapshot.data;
        if (result == null) {
          return const Text('데이터를 불러올 수 없습니다');
        }

        return result.when(
          success: (response) => ListView.builder(
            itemCount: response.items.length,
            itemBuilder: (context, index) {
              final exhibition = response.items[index];
              return ListTile(
                title: Text(exhibition.title),
                subtitle: Text(exhibition.description),
              );
            },
          ),
          failure: (exception) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(exception.message),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
*/
