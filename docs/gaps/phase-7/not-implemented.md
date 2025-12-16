# Not Implemented - Phase 7 설정

## 요약
- 총 항목 수: 8개
- P0 (즉시): 2개
- P1 (다음 스프린트): 4개
- P2 (백로그): 2개

## 항목 목록

### 1. 닉네임 중복 체크
- **현재 상태**: 닉네임 중복 허용, `validates :nickname, presence: true`만 존재
- **개선 필요 사항**:
  - 닉네임 uniqueness 검증 (대소문자 무시)
  - 실시간 중복 체크 API
  - 사용 가능한 닉네임 제안
- **우선순위**: P1
- **관련 파일**:
  - `app/models/user.rb`
  - `app/controllers/settings/profiles_controller.rb`
  - 신규: `app/controllers/api/nickname_checks_controller.rb`

### 2. 닉네임 길이 및 형식 검증
- **현재 상태**: presence 검증만 존재, 길이/형식 제한 없음
- **개선 필요 사항**:
  - 최소 2자, 최대 20자 제한
  - 허용 문자: 한글, 영문, 숫자, 일부 특수문자
  - 금지어 필터링
  - 정규식 검증
- **우선순위**: P0
- **관련 파일**:
  - `app/models/user.rb`
  - 신규: `app/validators/nickname_validator.rb`
  - 신규: `config/banned_nicknames.yml`

### 3. 알림 시간대 설정
- **현재 상태**: 알림 on/off만 가능, 시간대 설정 없음
- **개선 필요 사항**:
  - 무음 시간대 설정 (예: 22:00 ~ 08:00)
  - 요일별 설정
  - 타임존 고려
- **우선순위**: P2
- **관련 파일**:
  - `db/migrate/*_add_quiet_hours_to_users.rb`
  - `app/models/user.rb`
  - `app/controllers/settings/notifications_controller.rb`

### 4. 알림 전송 테스트 기능
- **현재 상태**: 실제 알림 전송 없이 설정만 저장
- **개선 필요 사항**:
  - "테스트 알림 보내기" 버튼
  - 푸시 알림 도달 확인
  - 알림 전송 실패 시 에러 표시
- **우선순위**: P1
- **관련 파일**:
  - 신규: `app/controllers/settings/notification_tests_controller.rb`
  - 신규: `app/jobs/send_test_notification_job.rb`

### 5. 설정 변경 이력
- **현재 상태**: 변경 이력 기록 없음
- **개선 필요 사항**:
  - Audited gem 통합
  - 설정 변경 로그 조회 UI
  - 이전 설정으로 복원 기능
- **우선순위**: P2
- **관련 파일**:
  - `Gemfile`
  - `app/models/user.rb`
  - 신규: `app/controllers/settings/audit_logs_controller.rb`

### 6. 프로필 사진 크롭/편집
- **현재 상태**: 아바타 업로드 자체가 미구현
- **개선 필요 사항**:
  - 이미지 크롭 UI (Cropper.js)
  - 회전/확대/축소
  - 미리보기
  - 파일 크기/형식 검증
- **우선순위**: P1
- **관련 파일**:
  - 신규: `app/javascript/controllers/avatar_cropper_controller.js`
  - `app/views/settings/profiles/show.html.erb`

### 7. 알림 그룹화 설정
- **현재 상태**: 개별 알림만 on/off 가능
- **개선 필요 사항**:
  - "모든 알림 끄기" 토글
  - 알림 그룹별 설정 (사진 관련, 댓글/반응 관련)
  - 일괄 설정 UI
- **우선순위**: P1
- **관련 파일**:
  - `app/views/settings/notifications/show.html.erb`
  - `app/controllers/settings/notifications_controller.rb`

### 8. 내보내기/가져오기 기능
- **현재 상태**: 설정 백업/복원 기능 없음
- **개선 필요 사항**:
  - 설정 JSON 내보내기
  - 다른 기기에서 가져오기
  - QR 코드로 설정 공유
- **우선순위**: P2
- **관련 파일**:
  - 신규: `app/controllers/settings/exports_controller.rb`
  - 신규: `app/controllers/settings/imports_controller.rb`
