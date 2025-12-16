# 미구현 기능 - Phase 6 반응/댓글

## 요약
- 총 항목 수: 8개
- P0 (즉시): 0개
- P1 (다음 스프린트): 2개
- P2 (백로그): 6개

## 항목 목록

### 1. 반응 이모지 선택 UI 없음
- **현재 상태**:
  - 뷰 파일에 반응 입력 폼이 없음
  - 클라이언트에서 직접 API 호출 필요
  - 사용자가 어떤 이모지를 선택할 수 있는지 모름
- **개선 필요 사항**:
  - 이모지 선택 버튼 UI 추가
  - Stimulus controller로 반응 토글 구현
  - 현재 선택된 반응 하이라이트 표시
- **우선순위**: P1
- **관련 파일**:
  - 신규 파일: `app/views/photos/reactions/_form.html.erb` (필요)
  - 신규 파일: `app/javascript/controllers/reaction_controller.js` (필요)

### 2. 댓글 입력 폼 partial 없음
- **현재 상태**:
  - 뷰 파일에 댓글 입력 폼이 없음
  - 댓글 목록만 표시 가능
  - 사용자가 댓글을 입력할 UI 없음
- **개선 필요 사항**:
  - 댓글 입력 폼 partial 추가
  - Turbo Frame으로 비동기 제출
  - 입력 후 폼 초기화
- **우선순위**: P1
- **관련 파일**:
  - 신규 파일: `app/views/photos/comments/_form.html.erb` (필요)

### 3. 반응 통계 조회 API 없음
- **현재 상태**:
  - 누가 어떤 반응을 달았는지 확인 불가
  - 반응 그룹별 사용자 목록 조회 불가
- **개선 필요 사항**:
  - 반응 통계 엔드포인트 추가
  - 이모지별로 그룹핑하여 사용자 목록 반환
  - 예: `GET /families/:family_id/photos/:photo_id/reactions/stats`
- **우선순위**: P2
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/reactions_controller.rb`

### 4. 댓글 신고 기능 없음
- **현재 상태**:
  - 부적절한 댓글 신고 불가
  - 관리자가 댓글 관리 불가
- **개선 필요 사항**:
  - 댓글 신고 기능 추가
  - 신고된 댓글 숨김 처리
  - 관리자 검토 기능
- **우선순위**: P2
- **관련 파일**:
  - 신규 기능 필요

### 5. 댓글 좋아요 기능 없음
- **현재 상태**:
  - 댓글에 대한 반응 불가
  - 좋은 댓글을 표시할 방법 없음
- **개선 필요 사항**:
  - 댓글 좋아요 모델 추가
  - 좋아요 수 표시
  - 좋아요 토글 기능
- **우선순위**: P2
- **관련 파일**:
  - 신규 모델: `CommentLike` (필요)

### 6. 대댓글 기능 없음
- **현재 상태**:
  - 댓글에 대한 답글 불가
  - 평면 구조의 댓글만 가능
- **개선 필요 사항**:
  - 계층적 댓글 구조 지원
  - `parent_id` 컬럼 추가
  - 대댓글 UI 구현
- **우선순위**: P2
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/models/comment.rb`

### 7. 멘션(@) 기능 없음
- **현재 상태**:
  - 댓글에서 특정 사용자 언급 불가
  - @nickname 파싱 없음
- **개선 필요 사항**:
  - 멘션 파싱 및 링크 생성
  - 멘션된 사용자에게 알림
  - 자동완성 UI
- **우선순위**: P2
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/models/comment.rb`

### 8. 실시간 댓글 개수 업데이트 테스트 없음
- **현재 상태**:
  - Turbo Stream으로 댓글 추가는 테스트됨
  - 댓글 개수 증가가 UI에 반영되는지 미검증
- **개선 필요 사항**:
  - System test로 실시간 업데이트 검증
  - 여러 사용자 동시 댓글 시나리오
  - 브라우저 간 동기화 확인
- **우선순위**: P2
- **관련 파일**:
  - 신규 테스트: `test/system/photo_reactions_test.rb` (필요)
  - 신규 테스트: `test/system/photo_comments_test.rb` (필요)
