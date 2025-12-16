# 에러 처리 누락 - Phase 6 반응/댓글

## 요약
- 총 항목 수: 7개
- P0 (즉시): 2개
- P1 (다음 스프린트): 3개
- P2 (백로그): 2개

## 항목 목록

### 1. 유효하지 않은 이모지 입력 시 처리 없음
- **현재 상태**:
  - validation이 없어서 아무 문자열이나 허용
  - 빈 문자열, 특수문자, HTML 등 저장 가능
  - XSS 공격 가능성
- **개선 필요 사항**:
  - 허용된 이모지 목록 검증 추가
  - `validates :emoji, inclusion: { in: ALLOWED_EMOJIS }`
  - 에러 메시지: "허용되지 않은 이모지입니다."
- **우선순위**: P0
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/models/reaction.rb` (L7)
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/reactions_controller.rb` (L24-29)

### 2. 댓글이 너무 긴 경우 처리 없음
- **현재 상태**:
  - 길이 제한이 없어서 무제한 입력 가능
  - DB text 컬럼 한계까지 저장 가능
  - 성능 및 UI 문제 발생 가능
- **개선 필요 사항**:
  - 최대 길이 validation 추가
  - `validates :body, length: { maximum: 500 }`
  - 에러 메시지: "댓글은 500자 이하로 입력해주세요."
- **우선순위**: P0
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/models/comment.rb` (L7)
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/comments_controller.rb` (L33-38)

### 3. 동일 사용자가 빠르게 반응 변경 시 race condition
- **현재 상태**:
  - `find_or_initialize_by` 사용
  - 동시 요청 시 duplicate key error 가능
  - `ActiveRecord::RecordNotUnique` 예외 처리 없음
- **개선 필요 사항**:
  - 트랜잭션으로 감싸기
  ```ruby
  ActiveRecord::Base.transaction do
    @reaction = @photo.reactions.lock.find_or_initialize_by(user: current_user)
    @reaction.emoji = reaction_params[:emoji]
    @reaction.save!
  end
  rescue ActiveRecord::RecordNotUnique
    retry
  ```
  - 또는 `find_or_create_by!` 사용
- **우선순위**: P1
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/reactions_controller.rb` (L14-18)

### 4. 삭제된 사용자의 댓글/반응 처리 없음
- **현재 상태**:
  - `belongs_to :user`에 `dependent` 옵션 없음
  - 사용자 삭제 시 댓글/반응도 함께 삭제되는지 불명확
  - orphaned records 가능성
- **개선 필요 사항**:
  - User 모델에서 `has_many :reactions, dependent: :destroy`
  - User 모델에서 `has_many :comments, dependent: :destroy`
  - 또는 soft delete로 사용자만 비활성화
- **우선순위**: P1
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/models/reaction.rb` (L5)
  - `/Users/lms/dev/repository/moabom/app/models/comment.rb` (L5)

### 5. Turbo Stream 요청 실패 시 fallback 없음
- **현재 상태**:
  - Turbo Stream 응답 생성 실패 시 처리 없음
  - 네트워크 오류 시 사용자에게 피드백 없음
- **개선 필요 사항**:
  - Stimulus controller에서 에러 처리
  - 실패 시 flash message 표시
  - 재시도 버튼 제공
- **우선순위**: P1
- **관련 파일**:
  - 신규 파일: `app/javascript/controllers/reaction_controller.js` (필요)
  - 신규 파일: `app/javascript/controllers/comment_controller.js` (필요)

### 6. photo가 존재하지 않을 때 처리 부족
- **현재 상태**:
  - `set_photo`에서 `ActiveRecord::RecordNotFound` 발생
  - ApplicationController의 rescue_from으로 처리되지만
  - 테스트에서 검증되지 않음
- **개선 필요 사항**:
  - 404 응답 테스트 추가
  - JSON API에서도 적절한 에러 응답 확인
  - Turbo Stream 요청 시 에러 처리
- **우선순위**: P2
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/reactions_controller.rb` (L50-52)
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/comments_controller.rb` (L59-61)
  - `/Users/lms/dev/repository/moabom/test/controllers/photos/reactions_controller_test.rb`
  - `/Users/lms/dev/repository/moabom/test/controllers/photos/comments_controller_test.rb`

### 7. JSON API에서 include 파라미터 검증 없음
- **현재 상태**:
  - `index` 액션에서 `as_json(include: :user)` 하드코딩
  - 클라이언트가 다른 association을 요청할 수 없음
  - 불필요한 데이터를 항상 포함
- **개선 필요 사항**:
  - `params[:include]`로 동적 include 지원
  - 허용된 association만 include
  - sparse fieldsets 지원 (JSON:API 스펙)
- **우선순위**: P2
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/comments_controller.rb` (L18)
