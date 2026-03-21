import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

/// 카카오 로그인 결과
class KakaoLoginResult {
  const KakaoLoginResult({
    required this.isSuccess,
    this.idToken,
    this.user,
    this.errorMessage,
  });

  factory KakaoLoginResult.success({
    required String idToken,
    required KakaoUserInfo user,
  }) {
    return KakaoLoginResult(isSuccess: true, idToken: idToken, user: user);
  }

  factory KakaoLoginResult.failure(String message) {
    return KakaoLoginResult(isSuccess: false, errorMessage: message);
  }

  final bool isSuccess;
  final String? idToken;
  final KakaoUserInfo? user;
  final String? errorMessage;
}

/// 카카오 사용자 정보
class KakaoUserInfo {
  const KakaoUserInfo({
    required this.id,
    this.nickname,
    this.email,
    this.profileImageUrl,
  });

  final int id;
  final String? nickname;
  final String? email;
  final String? profileImageUrl;

  @override
  String toString() {
    return 'KakaoUserInfo(id: $id, nickname: $nickname, email: $email)';
  }
}

/// 카카오 로그인 서비스
class KakaoLoginService {
  KakaoLoginService._internal();

  static final KakaoLoginService _instance = KakaoLoginService._internal();

  /// 싱글톤 인스턴스
  static KakaoLoginService get instance => _instance;

  /// OIDC nonce (ID Token 재생 공격 방지용)
  /// 실제 운영에서는 매 요청마다 랜덤 생성 권장
  String _generateNonce() => 'arttrip_${DateTime.now().millisecondsSinceEpoch}';

  /// 카카오 로그인 수행
  ///
  /// 카카오톡이 설치되어 있으면 카카오톡으로 로그인,
  /// 설치되어 있지 않으면 카카오계정으로 로그인
  ///
  /// 반환값의 idToken은 서버에 전달할 OIDC ID Token (JWT)입니다.
  /// 카카오 개발자 콘솔에서 OpenID Connect 활성화 필요
  Future<KakaoLoginResult> login() async {
    try {
      OAuthToken token;
      final nonce = _generateNonce();

      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        token = await _loginWithKakaoTalk(nonce);
      } else {
        token = await _loginWithKakaoAccount(nonce);
      }

      debugPrint('카카오 로그인 성공');

      // OIDC ID Token 확인
      if (token.idToken == null) {
        return KakaoLoginResult.failure(
          'OIDC ID Token을 받지 못했습니다. 카카오 개발자 콘솔에서 OpenID Connect 활성화를 확인해주세요.',
        );
      }

      // 사용자 정보 조회
      final user = await _getUserInfo();

      return KakaoLoginResult.success(idToken: token.idToken!, user: user);
    } catch (e) {
      debugPrint('카카오 로그인 실패: $e');
      return KakaoLoginResult.failure(_getErrorMessage(e));
    }
  }

  /// 카카오톡으로 로그인 (OIDC)
  Future<OAuthToken> _loginWithKakaoTalk(String nonce) async {
    try {
      return await UserApi.instance.loginWithKakaoTalk(nonce: nonce);
    } catch (e) {
      debugPrint('카카오톡 로그인 실패, 카카오계정으로 재시도: $e');
      // 카카오톡 로그인 실패 시 카카오계정으로 로그인 시도
      return await _loginWithKakaoAccount(nonce);
    }
  }

  /// 카카오계정으로 로그인 (OIDC)
  Future<OAuthToken> _loginWithKakaoAccount(String nonce) async {
    return await UserApi.instance.loginWithKakaoAccount(nonce: nonce);
  }

  /// 사용자 정보 조회
  Future<KakaoUserInfo> _getUserInfo() async {
    final user = await UserApi.instance.me();

    return KakaoUserInfo(
      id: user.id,
      nickname: user.kakaoAccount?.profile?.nickname,
      email: user.kakaoAccount?.email,
      profileImageUrl: user.kakaoAccount?.profile?.profileImageUrl,
    );
  }

  /// 로그아웃
  Future<bool> logout() async {
    try {
      await UserApi.instance.logout();
      debugPrint('카카오 로그아웃 성공');
      return true;
    } catch (e) {
      debugPrint('카카오 로그아웃 실패: $e');
      return false;
    }
  }

  /// 연결 끊기 (회원 탈퇴)
  Future<bool> unlink() async {
    try {
      await UserApi.instance.unlink();
      debugPrint('카카오 연결 끊기 성공');
      return true;
    } catch (e) {
      debugPrint('카카오 연결 끊기 실패: $e');
      return false;
    }
  }

  /// 토큰 존재 여부 확인
  Future<bool> hasToken() async {
    try {
      return await AuthApi.instance.hasToken();
    } catch (e) {
      return false;
    }
  }

  /// 토큰 유효성 검사
  Future<bool> isTokenValid() async {
    try {
      final token = await TokenManagerProvider.instance.manager.getToken();
      if (token == null) return false;

      // 토큰 정보 조회로 유효성 검사
      await UserApi.instance.accessTokenInfo();
      return true;
    } catch (e) {
      debugPrint('토큰 유효성 검사 실패: $e');
      return false;
    }
  }

  /// 현재 사용자 정보 조회
  Future<KakaoUserInfo?> getCurrentUser() async {
    try {
      if (!await isTokenValid()) return null;
      return await _getUserInfo();
    } catch (e) {
      debugPrint('현재 사용자 정보 조회 실패: $e');
      return null;
    }
  }

  /// 에러 메시지 추출
  String _getErrorMessage(Object error) {
    if (error is KakaoException) {
      return error.message ?? '카카오 로그인 중 오류가 발생했습니다';
    }
    return '로그인 중 오류가 발생했습니다';
  }
}
