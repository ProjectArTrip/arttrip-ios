# API 엔드포인트 참조

Base URL: `Env.apiBaseUrl` (현재 `https://dev.08166.dev`)

## 인증

| Method | Path | Body/Query | 설명 |
|--------|------|------------|------|
| POST | `/auth/social` | `{provider, idToken}` | 소셜 로그인 → accessToken + refreshToken + isFirstLogin |
| POST | `/auth/app/reissue` | `{refreshToken}` | 토큰 갱신 → 새 accessToken |
| POST | `/auth/app/logout` | `{refreshToken}` | 로그아웃 (별도 Dio 인스턴스 사용) |

## 전시

| Method | Path | Query | 설명 |
|--------|------|-------|------|
| GET | `/exhibits/{exhibitId}` | - | 전시 상세 → ExhibitDetailModel |
| GET | `/exhibits` | `query`, `isDomestic`, `country`, `region`, `startDate`, `endDate`, `genres`, `styles`, `sortType`, `cursor`, `size` | 전시 검색/필터 → ExhibitFilterModel |
| GET | `/exhibits/overseas` | - | 해외 국가 목록 → `{countries: [{label}]}` |
| GET | `/exhibits/domestic` | - | 국내 지역 목록 → `{regions: [RegionModel]}` |
| GET | `/exhibits/genre` | - | 장르 목록 → `{genres: [{name}]}` |

## 홈

| Method | Path | Query | 설명 |
|--------|------|-------|------|
| GET | `/home/exhibits/today` | `isDomestic`, `country`/`region` | 오늘의 추천 → `{exhibits: [ExhibitModel]}` |
| GET | `/home/exhibits/genres` | `isDomestic`, `country`/`region`, `singleGenre` | 장르별 전시 → `{exhibits: [ExhibitModel]}` |
| GET | `/home/exhibits/personalized` | `isDomestic`, `country`/`region` | 개인화 추천 → `{exhibits: [ExhibitModel]}` |
| GET | `/home/exhibits/schedule` | `isDomestic`, `country`/`region`, `date` (YYYY-MM-DD) | 주간 일정 → `{exhibits: [ExhibitModel]}` |

## 리뷰

| Method | Path | Body/Query | 설명 |
|--------|------|------------|------|
| GET | `/reviews/exhibit/{exhibitId}` | `size`, `cursor` | 전시 리뷰 목록 → ExhibitReviewListResponseModel |
| POST | `/reviews/{exhibitId}` | multipart: `request` (JSON: `{date, content}`) + `files` (이미지) | 리뷰 작성 → ReviewCreateResult |
| GET | `/reviews/{reviewId}` | - | 리뷰 상세 → ReviewCreateResult |
| PATCH | `/reviews/{reviewId}` | multipart: `request` (JSON: `{date, content, deleteImageIds}`) + `files` | 리뷰 수정 → isSuccess |
| DELETE | `/reviews/{reviewId}` | - | 리뷰 삭제 |
| GET | `/reviews/all` | `size`, `cursor`, `w`, `h` | 내 리뷰 목록 → MyReviewListResponseModel |

## 즐겨찾기

| Method | Path | 설명 |
|--------|------|------|
| POST | `/favorites/{exhibitId}` | 즐겨찾기 추가 |
| DELETE | `/favorites/{exhibitId}` | 즐겨찾기 제거 |

## 사용자

| Method | Path | Body/Query | 설명 |
|--------|------|------------|------|
| GET | `/me` | `w`, `h` | 프로필 조회 → UserProfileModel |
| PATCH | `/me` | `{nickName}` | 닉네임 변경 (에러 메시지 반환 패턴) |
| PATCH | `/me/image` | multipart: `image` | 프로필 이미지 변경 |
| DELETE | `/me/image` | - | 프로필 이미지 삭제 |
| GET | `/me/recent-exhibits` | - | 최근 본 전시 → RecentExhibitListResponseModel |

## 키워드

| Method | Path | Body/Query | 설명 |
|--------|------|------------|------|
| GET | `/keyword/all` | - | 전체 키워드 (장르+스타일) → KeywordListResponseModel |
| GET | `/keyword` | - | 사용자 선택 키워드 → `[KeywordModel]` |
| POST | `/keyword` | `{keywords: [String]}` | 키워드 저장 (이름 배열) |
| GET | `/keyword/recommand` | - | 추천 키워드 → `{keywords: [KeywordModel]}` |

## 검색

| Method | Path | Query | 설명 |
|--------|------|-------|------|
| GET | `/search-history` | - | 검색 히스토리 → `{items: [SearchHistoryModel]}` |
| DELETE | `/search-history/{searchHistoryId}` | - | 검색 히스토리 삭제 |

## 서버 응답 형식

모든 API는 동일한 래퍼 구조:

```json
{
  "isSuccess": true,
  "code": "200",
  "message": "성공",
  "result": { ... }
}
```

`ApiResponse<T>.fromJson()`으로 파싱 후 `.result`로 데이터 추출.

## 페이지네이션

커서 기반 페이지네이션 사용:
- 요청: `?size=10&cursor={nextCursor}`
- 응답: `{items: [...], nextCursor: int?, hasNext: bool, totalCount: int}`
- `hasNext == false`이면 마지막 페이지

## 이미지 요청

프로필/리뷰 이미지 조회 시 리사이즈 파라미터:
- `?w=100&h=100` — 서버에서 리사이즈된 이미지 반환
