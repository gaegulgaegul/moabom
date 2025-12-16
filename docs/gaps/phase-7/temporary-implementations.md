# Temporary Implementations - Phase 7 설정

## 요약
- 총 항목 수: 5개
- P0 (즉시): 1개
- P1 (다음 스프린트): 3개
- P2 (백로그): 1개

## 항목 목록

### 1. 간단한 Boolean 필드로만 알림 설정 관리
- **현재 상태**:
  - `notify_on_new_photo`, `notify_on_comment`, `notify_on_reaction` 3개 boolean 필드만 존재
  - 세밀한 알림 제어 불가
- **개선 필요 사항**:
  - JSON 컬럼으로 알림 설정 구조화
  - 알림 채널별 설정 (푸시, 이메일, SMS)
  - 알림 빈도 설정 (즉시, 요약, 무음 시간대)
  - 알림 우선순위 설정
- **우선순위**: P1
- **관련 파일**:
  - `db/migrate/20251214155114_add_notification_settings_to_users.rb`
  - `app/models/user.rb`
  - `app/controllers/settings/notifications_controller.rb`

### 2. UI/UX가 매우 기본적
- **현재 상태**:
  - HTML 기본 form 요소만 사용
  - TailwindCSS 미적용
  - 모바일 최적화 없음
  - 접근성 고려 부족 (aria-label 등 없음)
- **개선 필요 사항**:
  - TailwindCSS 적용한 현대적인 UI
  - 반응형 디자인
  - 토글 스위치 컴포넌트
  - 로딩 상태 표시
  - 성공/에러 toast 알림
  - WCAG 접근성 준수
- **우선순위**: P0
- **관련 파일**:
  - `app/views/settings/profiles/show.html.erb`
  - `app/views/settings/notifications/show.html.erb`
  - 신규: `app/javascript/controllers/settings_controller.js`

### 3. Turbo Frame/Stream 미적용
- **현재 상태**: 전체 페이지 리로드 방식
- **개선 필요 사항**:
  - Turbo Frame으로 설정 섹션 분리
  - Turbo Stream으로 부분 업데이트
  - 낙관적 UI 업데이트
  - 실시간 검증 피드백
- **우선순위**: P1
- **관련 파일**:
  - `app/views/settings/profiles/show.html.erb`
  - `app/views/settings/notifications/show.html.erb`
  - `app/controllers/settings/profiles_controller.rb`
  - `app/controllers/settings/notifications_controller.rb`

### 4. 알림 설정 변경 시 즉시 적용 검증 부족
- **현재 상태**:
  - DB 업데이트만 수행
  - 실제 알림 전송 시스템과 연동 확인 없음
  - 변경 이력 기록 없음
- **개선 필요 사항**:
  - 설정 변경 감사 로그 (Audited gem 활용)
  - 푸시 토큰 재등록 트리거
  - 변경 사항 즉시 반영 확인
  - 테스트 알림 전송 기능
- **우선순위**: P1
- **관련 파일**:
  - `app/controllers/settings/notifications_controller.rb`
  - `app/models/user.rb`
  - 신규: `app/services/notification_settings_updater.rb`

### 5. 프로필 수정 성공 시 전체 페이지 리다이렉트
- **현재 상태**: `redirect_to settings_profile_path` 전체 페이지 이동
- **개선 필요 사항**:
  - Turbo Stream으로 부분 업데이트
  - 인라인 편집 UI
  - 변경 사항 자동 저장 (debounce)
  - 취소 기능
- **우선순위**: P2
- **관련 파일**:
  - `app/controllers/settings/profiles_controller.rb`
  - `app/views/settings/profiles/show.html.erb`
  - 신규: `app/views/settings/profiles/update.turbo_stream.erb`
