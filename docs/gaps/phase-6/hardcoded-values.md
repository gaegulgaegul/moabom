# 하드코딩된 값 - Phase 6 반응/댓글

## 요약
- 총 항목 수: 4개
- P0 (즉시): 1개
- P1 (다음 스프린트): 2개
- P2 (백로그): 1개

## 항목 목록

### 1. 허용 이모지 목록 미정의
- **현재 상태**:
  - 허용할 이모지 목록이 코드에 없음
  - validation도 없어서 아무 문자열이나 허용
  - 이모지 선택 UI도 없음
- **개선 필요 사항**:
  - 허용 이모지를 상수로 정의
  ```ruby
  ALLOWED_EMOJIS = %w[❤️ 😍 👍 🎉 😊 😢 😮 😂].freeze
  validates :emoji, inclusion: { in: ALLOWED_EMOJIS }
  ```
  - 또는 `config/reactions.yml`로 관리
  - 관리자가 허용 이모지 추가/제거 가능하도록
- **우선순위**: P0
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/models/reaction.rb`

### 2. 댓글 최대 길이 미정의
- **현재 상태**:
  - 길이 제한이 없음
  - 무제한 댓글 가능
- **개선 필요 사항**:
  - 최대 길이를 상수로 정의
  ```ruby
  MAX_BODY_LENGTH = 500
  validates :body, length: { maximum: MAX_BODY_LENGTH }
  ```
  - 또는 `config/application.rb`에서 설정
  - 프론트엔드에도 동일한 제한 적용
- **우선순위**: P1
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/models/comment.rb`

### 3. 에러 메시지 하드코딩
- **현재 상태**:
  - 컨트롤러에 "권한이 없습니다." 직접 작성
  - i18n을 사용하지 않음
  - 다국어 지원 불가
- **개선 필요 사항**:
  - `config/locales/ko.yml`로 이동
  ```yaml
  ko:
    photos:
      reactions:
        forbidden: "권한이 없습니다."
        created: "반응을 추가했습니다."
      comments:
        forbidden: "권한이 없습니다."
        created: "댓글을 추가했습니다."
  ```
  - 컨트롤러에서 `t('.forbidden')` 사용
- **우선순위**: P1
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/reactions_controller.rb` (L42, L43)
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/comments_controller.rb` (L51, L52)

### 4. 댓글 정렬 순서 하드코딩
- **현재 상태**:
  - `order(created_at: :asc)` 하드코딩
  - 정렬 기준을 변경할 수 없음
- **개선 필요 사항**:
  - 정렬 옵션을 상수 또는 설정으로 분리
  ```ruby
  DEFAULT_SORT_ORDER = :asc
  @comments = @photo.comments.order(created_at: sort_order)
  ```
  - 또는 사용자 설정으로 저장
- **우선순위**: P2
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/comments_controller.rb` (L15)
