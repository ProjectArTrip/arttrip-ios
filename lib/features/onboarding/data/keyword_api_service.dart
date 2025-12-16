import 'package:arttrip/core/network/models/api_response.dart';
import 'package:arttrip/core/network/network.dart';
import 'package:arttrip/features/onboarding/data/models/keyword.dart';

/// 키워드 관련 API 서비스
class KeywordApiService extends BaseApiService {
  KeywordApiService({super.client});

  /// 모든 키워드 조회
  Future<ApiResult<ApiResponse<List<Keyword>>>> getAllKeywords() {
    return get<ApiResponse<List<Keyword>>>(
      '/auth/allkeywords',
      fromJson: (data) {
        var json = data as Map<String, dynamic>;
        return ApiResponse.fromJson(
          json,
          (obj) {
            if (obj == null) return <Keyword>[];
            var list = obj as List<dynamic>;
            return list
                .map((e) => Keyword.fromJson(e as Map<String, dynamic>))
                .toList();
          },
        );
      },
    );
  }

  /// 키워드 저장
  Future<ApiResult<ApiResponse<String>>> saveKeywords({
    required List<int> keywordIds,
  }) {
    return post<ApiResponse<String>>(
      '/auth/keywords',
      data: {'keywordIds': keywordIds},
      fromJson: (data) {
        var json = data as Map<String, dynamic>;
        return ApiResponse.fromJson(
          json,
          (obj) => obj as String? ?? '',
        );
      },
    );
  }
}
