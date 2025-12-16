# Phase 6 반응/댓글 기능 Gap 분석

> 작성일: 2025-12-15
> 분석 범위: Reaction/Comment 모델 및 컨트롤러, 뷰, 테스트

## 전체 요약

| 카테고리 | 총 항목 | P0 | P1 | P2 |
|---------|--------|----|----|-----|
| [의도적 단순화](./intentional-simplifications.md) | 5 | 0 | 3 | 2 |
| [임시 구현](./temporary-implementations.md) | 6 | 2 | 3 | 1 |
| [미구현 기능](./not-implemented.md) | 8 | 0 | 2 | 6 |
| [하드코딩된 값](./hardcoded-values.md) | 4 | 1 | 2 | 1 |
| [에러 처리 누락](./missing-error-handling.md) | 7 | 2 | 3 | 2 |
| **전체** | **30** | **5** | **13** | **12** |

## 즉시 해결 필요 (P0: 5개)

### 임시 구현
1. **이모지 유효성 검증 없음** - 아무 문자열이나 emoji로 저장 가능
2. **댓글 길이 제한 없음** - 무제한 길이의 댓글 허용

### 하드코딩된 값
3. **허용 이모지 목록 미정의** - 상수나 설정 파일로 관리 필요

### 에러 처리 누락
4. **유효하지 않은 이모지 입력 시 처리 없음** - XSS 공격 가능성
5. **댓글이 너무 긴 경우 처리 없음** - 성능 및 UI 문제 발생 가능

## 다음 스프린트 (P1: 13개)

### 의도적 단순화
- 알림 기능 미구현
- 댓글 페이지네이션 없음
- 반응 그룹핑 없음

### 임시 구현
- 동시 반응 생성 시 race condition 가능성
- 댓글/반응 수 캐싱 없음
- Turbo Stream 에러 처리 부족

### 미구현 기능
- 반응 이모지 선택 UI 없음
- 댓글 입력 폼 partial 없음

### 하드코딩된 값
- 댓글 최대 길이 미정의
- 에러 메시지 하드코딩

### 에러 처리 누락
- 동일 사용자가 빠르게 반응 변경 시 race condition
- 삭제된 사용자의 댓글/반응 처리 없음
- Turbo Stream 요청 실패 시 fallback 없음

## 백로그 (P2: 12개)

- 댓글 수정 기능
- 반응 종류 제한 재검토
- 댓글 정렬 옵션
- 반응 통계 조회 API
- 댓글 신고/좋아요/대댓글 기능
- 멘션(@) 기능
- System test 추가
- 기타 에러 처리 개선

## 분석 파일

### 분석 대상
```
app/controllers/photos/
├── reactions_controller.rb
└── comments_controller.rb

app/models/
├── reaction.rb
└── comment.rb

app/views/photos/
├── reactions/
│   └── _reactions.html.erb
└── comments/
    └── _comment.html.erb

test/controllers/photos/
├── reactions_controller_test.rb
└── comments_controller_test.rb
```

### 주요 발견사항

#### 1. 보안 이슈 (P0)
- 이모지 검증 없음으로 인한 XSS 공격 가능성
- 댓글 길이 제한 없음으로 인한 DoS 가능성

#### 2. 성능 이슈 (P1)
- 댓글 페이지네이션 없음 (전체 로딩)
- counter_cache 미사용
- race condition 가능성

#### 3. UX 이슈 (P1)
- 반응 선택 UI 없음
- 댓글 입력 폼 없음
- 반응 그룹핑 없음
- 알림 기능 없음

#### 4. 코드 품질 (P1)
- 에러 메시지 i18n 미사용
- 하드코딩된 값들
- Turbo Stream 에러 처리 부족

## 권장 조치

### 즉시 (이번 주)
1. 이모지 허용 목록 정의 및 validation 추가
2. 댓글 최대 길이 제한 추가
3. XSS 방지를 위한 입력 검증 강화

### 단기 (다음 스프린트)
1. 반응 이모지 선택 UI 구현
2. 댓글 입력 폼 추가
3. 알림 기능 연동 (사진 업로더에게)
4. 댓글 페이지네이션
5. counter_cache 적용
6. 에러 메시지 i18n 처리

### 중장기 (백로그)
1. 댓글 수정 기능
2. 반응 그룹핑 UI
3. 댓글 신고/좋아요 기능
4. 대댓글 및 멘션 기능
5. System test 추가

## 테스트 커버리지

### 현재 테스트된 항목
- ✅ 반응 생성/변경/삭제
- ✅ 댓글 생성/삭제
- ✅ 권한 체크 (본인만 삭제 가능)
- ✅ 인증 체크
- ✅ Turbo Stream 응답
- ✅ JSON API 응답

### 테스트 누락 항목
- ❌ 유효하지 않은 이모지 입력
- ❌ 댓글 길이 초과
- ❌ 동시 요청 시 race condition
- ❌ 삭제된 사용자의 데이터
- ❌ Turbo Stream 에러 응답
- ❌ 실시간 업데이트 (System test)
- ❌ 404/422 에러 응답

## 참고 문서

- [PRD - Phase 6 반응/댓글](/Users/lms/dev/repository/moabom/docs/features/mvp/PRD.md)
- [API 설계](/Users/lms/dev/repository/moabom/docs/features/mvp/API_DESIGN.md)
- [아키텍처 가이드](/Users/lms/dev/repository/moabom/.claude/rules/architecture-guide.md)
- [코딩 가이드](/Users/lms/dev/repository/moabom/.claude/rules/coding-guide.md)
