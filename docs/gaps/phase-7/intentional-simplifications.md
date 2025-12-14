# Intentional Simplifications - Phase 7 설정

## 요약
- 총 항목 수: 6개
- P0 (즉시): 0개
- P1 (다음 스프린트): 3개
- P2 (백로그): 3개

## 항목 목록

### 1. 프로필 아바타 업로드 미구현
- **현재 상태**: 소셜 로그인에서 가져온 `avatar_url`만 표시, 사용자가 직접 업로드 불가
- **개선 필요 사항**:
  - Active Storage를 사용한 아바타 업로드 기능
  - 이미지 크롭/리사이즈 UI
  - 기본 아바타 이미지 제공
- **우선순위**: P1
- **관련 파일**:
  - `app/controllers/settings/profiles_controller.rb`
  - `app/views/settings/profiles/show.html.erb`
  - `app/models/user.rb`

### 2. 이메일 변경 기능 미제공
- **현재 상태**: 이메일 필드가 disabled 상태, 소셜 로그인 이메일 고정
- **개선 필요 사항**:
  - 이메일 변경 요청 및 인증 플로우
  - 새 이메일 소유권 확인 (인증 메일)
  - OAuth 제공자와의 동기화 고려
- **우선순위**: P2
- **관련 파일**:
  - `app/views/settings/profiles/show.html.erb`
  - `app/models/user.rb`

### 3. 푸시 알림 실제 전송 미구현
- **현재 상태**: 알림 설정만 DB에 저장, FCM/APNs 연동 없음
- **개선 필요 사항**:
  - FCM (Android) 푸시 알림 전송
  - APNs (iOS) 푸시 알림 전송
  - 디바이스 토큰 관리
  - 알림 큐잉 및 재시도 로직
- **우선순위**: P1
- **관련 파일**:
  - `app/controllers/settings/notifications_controller.rb`
  - `app/models/user.rb`
  - 신규: `app/services/push_notification_service.rb`
  - 신규: `app/jobs/send_push_notification_job.rb`

### 4. 가족별 알림 설정 미지원
- **현재 상태**: 전역 알림 설정만 가능, 가족별로 다르게 설정 불가
- **개선 필요 사항**:
  - `FamilyMembership` 모델에 알림 설정 추가
  - 가족별 알림 on/off 설정 UI
  - 알림 전송 시 가족별 설정 우선 적용
- **우선순위**: P2
- **관련 파일**:
  - `app/models/family_membership.rb`
  - `app/controllers/settings/notifications_controller.rb`

### 5. 비밀번호 변경 미지원
- **현재 상태**: 소셜 로그인만 지원, 비밀번호 개념 없음
- **개선 필요 사항**:
  - 이메일/비밀번호 로그인 추가 시 필요
  - 현재 비밀번호 확인 후 변경
  - 비밀번호 강도 검증
- **우선순위**: P2 (이메일 로그인 추가 시 구현)
- **관련 파일**:
  - `app/controllers/settings/profiles_controller.rb`
  - `app/models/user.rb`

### 6. 계정 탈퇴 기능 미구현
- **현재 상태**: 계정 삭제/비활성화 기능 없음
- **개선 필요 사항**:
  - 계정 탈퇴 UI 및 확인 플로우
  - 사용자 데이터 처리 정책 (삭제 vs 익명화)
  - 가족 소유자 변경 로직
  - 탈퇴 후 재가입 정책
- **우선순위**: P1
- **관련 파일**:
  - 신규: `app/controllers/settings/accounts_controller.rb`
  - `app/models/user.rb`
  - 신규: `app/services/account_deletion_service.rb`
