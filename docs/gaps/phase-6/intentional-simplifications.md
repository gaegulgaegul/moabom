# 의도적 단순화 - Phase 6 반응/댓글

## 요약
- 총 항목 수: 5개
- P0 (즉시): 0개
- P1 (다음 스프린트): 3개
- P2 (백로그): 2개

## 항목 목록

### 1. 알림 기능 미구현
- **현재 상태**:
  - 댓글/반응 생성 시 알림 전송 없음
  - 가족 구성원에게 실시간 알림 없음
  - 사진 업로더도 알림 받지 못함
- **개선 필요 사항**:
  - 사진 업로더에게 댓글/반응 알림 전송 (P1)
  - 푸시 알림 연동 (P2)
  - 앱 내 알림 목록 (P2)
- **우선순위**: P1
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/reactions_controller.rb`
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/comments_controller.rb`

### 2. 댓글 페이지네이션 없음
- **현재 상태**:
  - `index` 액션에서 전체 댓글 로딩
  - 댓글이 많아지면 성능 문제 가능
- **개선 필요 사항**:
  - 페이지네이션 또는 무한 스크롤 적용
  - 초기 로딩 시 최근 N개만 표시
  - "더 보기" 버튼으로 추가 로딩
- **우선순위**: P1
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/comments_controller.rb` (L15)

### 3. 반응 그룹핑 없음
- **현재 상태**:
  - 각 사용자의 반응을 개별적으로 표시
  - 같은 이모지끼리 묶어서 보여주지 않음
  - "❤️ 5명" 같은 집계 표시 없음
- **개선 필요 사항**:
  - 이모지별로 그룹핑하여 표시
  - 반응한 사용자 목록 표시
  - 클릭 시 상세 정보 모달
- **우선순위**: P1
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/views/photos/reactions/_reactions.html.erb`
  - `/Users/lms/dev/repository/moabom/app/models/reaction.rb`

### 4. 댓글 수정 기능 없음
- **현재 상태**:
  - 댓글 삭제만 가능
  - 오타 수정을 위해서는 삭제 후 재작성 필요
- **개선 필요 사항**:
  - 댓글 수정 액션 추가
  - 수정 이력 관리 (선택사항)
  - 수정 시간 표시 (edited)
- **우선순위**: P2
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/comments_controller.rb`
  - `/Users/lms/dev/repository/moabom/app/models/comment.rb`

### 5. 반응 종류 제한 없음
- **현재 상태**:
  - 사용자가 한 사진에 하나의 반응만 가능 (의도적)
  - 여러 개의 서로 다른 반응을 달 수 없음
- **개선 필요 사항**:
  - 현재 구현(1인 1반응)이 적절한지 재검토
  - 필요시 복수 반응 허용으로 변경
  - uniqueness validation 수정
- **우선순위**: P2
- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/models/reaction.rb` (L8)
  - `/Users/lms/dev/repository/moabom/app/controllers/photos/reactions_controller.rb` (L15)
