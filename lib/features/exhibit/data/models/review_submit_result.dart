/// 리뷰 작성/수정 결과
enum ReviewSubmitResult {
  /// 성공
  success,

  /// 금칙어 포함 (서버 응답 코드: REVIEW400-BAD_WORD_INCLUDED)
  badWord,

  /// 그 외 실패 — 네트워크/타임아웃/5xx/금칙어 외 4xx 등
  failure,
}
