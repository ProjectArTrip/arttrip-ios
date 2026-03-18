import 'package:arttrip/core/network/models/api_response.dart';
import 'package:arttrip/core/network/network.dart';
import 'package:arttrip/features/onboarding/data/models/keyword_model.dart';

/// 키워드 관련 API 서비스
class KeywordModelApiService extends BaseApiService {
  KeywordModelApiService({super.client});

  /// 모든 키워드 조회
  Future<ApiResult<ApiResponse<List<KeywordModel>>>> getAllKeywordModels() {
    return get<ApiResponse<List<KeywordModel>>>(
      '/auth/allkeywords',
      fromJson: (data) {
        final json = data as Map<String, dynamic>;
        return ApiResponse.fromJson(json, (obj) {
          if (obj == null) return <KeywordModel>[];
          final list = obj as List<dynamic>;
          return list
              .map((e) => KeywordModel.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      },
    );
  }

  /// 키워드 저장
  Future<ApiResult<ApiResponse<String>>> saveKeywordModels({
    required List<int> keywordIds,
  }) {
    return post<ApiResponse<String>>(
      '/auth/keywords',
      data: {'keywordIds': keywordIds},
      fromJson: (data) {
        final json = data as Map<String, dynamic>;
        return ApiResponse.fromJson(json, (obj) => obj as String? ?? '');
      },
    );
  }
}
