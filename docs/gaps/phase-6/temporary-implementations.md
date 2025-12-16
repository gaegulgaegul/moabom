# 임시 구현 - Phase 6 반응/댓글

## 요약
- 총 항목 수: 6개
- P0 (즉시): 2개
- P1 (다음 스프린트): 3개
- P2 (백로그): 1개

## 항목 목록

### 1. 이모지 유효성 검증 없음
- **현재 상태**:
  - `validates :emoji, presence: true`만 존재
  - 아무 문자열이나 emoji로 저장 가능
  - 유효한 이모지인지 검증하지 않음
- **개선 필요 사항**:
  - 허용된 이모지 목록 정의 (예: ❤️, 😍, 👍, 🎉, 😊)
  - custom validation으로 검증
  - 클라이언트에서도 선택 UI로 제한
- **우선순위**: P0
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/models/reaction.rb` (L7)

### 2. 댓글 길이 제한 없음
- **현재 상태**:
  - `validates :body, presence: true`만 존재
  - 무제한 길이의 댓글 허용
  - DB 컬럼은 text 타입으로 제한 없음
- **개선 필요 사항**:
  - 최대 길이 제한 추가 (예: 500자 또는 1000자)
  - `validates :body, length: { maximum: 500 }`
  - 프론트엔드에서도 글자 수 표시 및 제한
- **우선순위**: P0
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/models/comment.rb` (L7)

### 3. 동시 반응 생성 시 race condition 가능성
- **현재 상태**:
  - `find_or_initialize_by` 사용
  - 같은 사용자가 빠르게 두 번 반응 시 중복 생성 가능
  - DB uniqueness constraint는 있으나 예외 처리 없음
- **개선 필요 사항**:
  - `find_or_create_by!` 사용 또는 트랜잭션 처리
  - `rescue ActiveRecord::RecordNotUnique` 추가
  - optimistic locking 고려
- **우선순위**: P1
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/reactions_controller.rb` (L15-16)

### 4. 댓글/반응 수 캐싱 없음
- **현재 상태**:
  - 매번 `@photo.reactions.count`, `@photo.comments.count` 쿼리 실행
  - N+1 문제는 없으나 캐싱으로 최적화 가능
- **개선 필요 사항**:
  - `counter_cache` 사용
  - `photos` 테이블에 `reactions_count`, `comments_count` 컬럼 추가
  - 마이그레이션으로 기존 데이터 카운트 초기화
- **우선순위**: P1
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/models/reaction.rb`
  - `/Users/lms/dev/repository/moabom/app/models/comment.rb`

### 5. Turbo Stream 에러 처리 부족
- **현재 상태**:
  - validation 실패 시 Turbo Stream 에러 응답 없음
  - HTML format만 에러 처리 (redirect with alert)
  - JSON format만 422 상태 코드 반환
- **개선 필요 사항**:
  - Turbo Stream format에서도 에러 메시지 표시
  - flash message를 Turbo Stream으로 전송
  - 에러 상태를 UI에 반영
- **우선순위**: P1
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/reactions_controller.rb` (L24-29)
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/comments_controller.rb` (L33-38)

### 6. 댓글 정렬 하드코딩
- **현재 상태**:
  - `order(created_at: :asc)` 하드코딩
  - 사용자가 정렬 순서 변경 불가
- **개선 필요 사항**:
  - 정렬 옵션을 파라미터로 받기
  - 최신순/오래된순 선택 가능
  - 사용자 설정으로 기본값 저장
- **우선순위**: P2
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/comments_controller.rb` (L15)
