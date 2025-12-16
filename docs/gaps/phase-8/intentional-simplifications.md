# Intentional Simplifications - Phase 8 Native API

## 요약
- 총 항목 수: 4개
- P0 (즉시): 0개
- P1 (다음 스프린트): 2개
- P2 (백로그): 2개

## 항목 목록

### 1. 세션 기반 인증 사용
- **현재 상태**:
  - `session[:user_id]` 기반 인증 방식 사용
  - `Api::BaseController`에서 세션으로 사용자 식별
  ```ruby
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  ```

- **개선 필요 사항**:
  - JWT 또는 API 토큰 기반 인증으로 전환
  - Stateless 인증 구현 (서버 확장성)
  - 토큰 갱신(refresh) 메커니즘 추가
  - Bearer token 헤더 방식 지원

- **MVP 의도**: Turbo Native가 세션 쿠키를 지원하므로 초기에는 세션 방식 사용

- **우선순위**: P1 (다음 스프린트)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/api/base_controller.rb`

---

### 2. 푸시 알림 전송 미구현
- **현재 상태**:
  - 푸시 토큰 등록/삭제만 구현
  - 실제 푸시 알림 전송 로직 없음
  - FCM/APNs 통합 없음

- **개선 필요 사항**:
  - FCM (Firebase Cloud Messaging) 통합
  - APNs (Apple Push Notification service) 통합
  - 알림 전송 Job 구현 (`SendPushNotificationJob`)
  - 알림 템플릿 관리
  - 전송 실패 시 재시도 로직

- **MVP 의도**: 푸시 인프라 먼저 구축, 실제 전송은 알림 기능과 함께 구현

- **우선순위**: P1 (다음 스프린트)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/api/native/push_tokens_controller.rb`
  - `/Users/lms/dev/repository/moabom/app/models/device.rb`

---

### 3. 전체 데이터 동기화만 지원
- **현재 상태**:
  - `/api/native/sync` endpoint가 모든 데이터 반환
  - 타임스탬프 기반 필터링 없음
  - 증분(incremental) 동기화 미지원

- **개선 필요 사항**:
  - `since` 파라미터로 변경된 데이터만 반환
  - 삭제된 리소스 추적 (soft delete 또는 deleted_resources)
  - ETag/Last-Modified 헤더 지원
  - 페이지네이션 추가 (대량 데이터 대응)

- **MVP 의도**: 초기 데이터 양이 적으므로 전체 동기화로 시작

- **우선순위**: P2 (백로그)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/api/native/syncs_controller.rb`

---

### 4. 디바이스 활성도 추적 미사용
- **현재 상태**:
  - `last_active_at` 필드 존재
  - `update_activity!` 메서드 정의되어 있음
  - 실제로 호출하는 로직 없음

- **개선 필요 사항**:
  - API 요청마다 `update_activity!` 호출
  - 비활성 디바이스 자동 정리 Job (`CleanupInactiveDevicesJob`)
  - 푸시 토큰 유효성 검증 (비활성 디바이스 제외)
  - 활성 디바이스 통계 대시보드

- **MVP 의도**: 스키마만 준비, 실제 활용은 운영 단계에서

- **우선순위**: P2 (백로그)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/models/device.rb`
  - `/Users/lms/dev/repository/moabom/db/migrate/20251214154751_create_devices.rb`
