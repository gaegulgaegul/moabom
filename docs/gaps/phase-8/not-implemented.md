# Not Implemented - Phase 8 Native API

## 요약
- 총 항목 수: 7개
- P0 (즉시): 1개
- P1 (다음 스프린트): 2개
- P2 (백로그): 4개

## 항목 목록

### 1. 푸시 알림 실제 전송
- **현재 상태**:
  - 디바이스 푸시 토큰만 등록/저장
  - FCM/APNs 통합 없음
  - 알림 전송 로직 없음

- **개선 필요 사항**:
  - FCM gem 추가 (`fcm` 또는 `googleauth`)
  - APNs gem 추가 (`apnotic` 또는 `houston`)
  - `SendPushNotificationJob` 구현
  - 알림 전송 서비스 객체 (`PushNotificationService`)
  - 전송 실패 시 재시도 및 로깅
  - 디바이스별 알림 설정 관리

- **우선순위**: P0 (즉시) - 핵심 기능

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/models/device.rb`
  - 추가 필요: `app/services/push_notification_service.rb`
  - 추가 필요: `app/jobs/send_push_notification_job.rb`

---

### 2. Rate Limiting
- **현재 상태**:
  - API 요청 횟수 제한 없음
  - 악의적 사용 방지 장치 없음

- **개선 필요 사항**:
  - `rack-attack` gem 도입
  - IP 기반 rate limiting (예: 100 req/min)
  - 사용자별 rate limiting (예: 1000 req/hour)
  - 엔드포인트별 제한 설정
  - Rate limit 초과 시 `429 Too Many Requests` 응답
  - Retry-After 헤더 추가

- **우선순위**: P1 (다음 스프린트)

- **관련 파일**:
  - 추가 필요: `config/initializers/rack_attack.rb`
  - `/Users/lms/dev/repository/moabom/app/controllers/api/base_controller.rb`

---

### 3. API 버저닝
- **현재 상태**:
  - `/api/native` 경로만 존재
  - 버전 관리 없음

- **개선 필요 사항**:
  - `/api/v1/native` 형태로 버전 추가
  - Accept 헤더 버전 지정 지원 (`Accept: application/vnd.moabom.v1+json`)
  - 여러 버전 동시 지원 인프라
  - Deprecation 헤더 (`Sunset`, `Deprecation`)
  - 버전별 테스트 격리

- **우선순위**: P2 (백로그)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/config/routes.rb`
  - `/Users/lms/dev/repository/moabom/app/controllers/api/`

---

### 4. API 문서 자동 생성
- **현재 상태**:
  - 수동 문서 작성
  - API 스펙 문서 없음

- **개선 필요 사항**:
  - OpenAPI 3.0 스펙 생성
  - Swagger UI 또는 Redoc 통합
  - `rswag` gem 도입 (테스트 → 문서 자동 생성)
  - 요청/응답 예시 자동 추출
  - Postman Collection 내보내기

- **우선순위**: P2 (백로그)

- **관련 파일**:
  - 추가 필요: `swagger/v1/swagger.yaml`
  - 추가 필요: `spec/requests/api/` (rswag spec)

---

### 5. 디바이스 활성도 업데이트
- **현재 상태**:
  - `Device#update_activity!` 메서드 정의만 존재
  - 실제 호출 로직 없음
  - `last_active_at` 필드 업데이트 안 됨

- **개선 필요 사항**:
  - `Api::BaseController`에 after_action 추가
  ```ruby
  after_action :update_device_activity

  def update_device_activity
    current_device&.update_activity!
  end
  ```
  - 디바이스 식별 로직 (헤더: `X-Device-Id`)
  - 비활성 디바이스 정리 Job (30일 이상 미사용)

- **우선순위**: P2 (백로그)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/models/device.rb:12-14`
  - `/Users/lms/dev/repository/moabom/app/controllers/api/base_controller.rb`

---

### 6. 통합 테스트 부족
- **현재 상태**:
  - 각 컨트롤러별 단위 테스트만 존재
  - 엔드포인트 간 통합 시나리오 테스트 없음

- **개선 필요 사항**:
  - 푸시 토큰 등록 → 동기화 → 알림 전송 통합 시나리오
  - 여러 디바이스 동시 사용 시나리오
  - 오프라인 → 온라인 복귀 시나리오
  - API 워크플로우 E2E 테스트

- **우선순위**: P1 (다음 스프린트)

- **관련 파일**:
  - 추가 필요: `test/integration/api/native_workflow_test.rb`

---

### 7. 성능 테스트
- **현재 상태**:
  - 성능 테스트 없음
  - 대량 데이터 시나리오 미검증

- **개선 필요 사항**:
  - 대량 가족/자녀 데이터 동기화 테스트 (100+ families)
  - 동시 요청 부하 테스트 (100 req/sec)
  - 응답 시간 벤치마크 설정 (<200ms)
  - 데이터베이스 쿼리 성능 프로파일링
  - 메모리 사용량 모니터링

- **우선순위**: P2 (백로그)

- **관련 파일**:
  - 추가 필요: `test/performance/api_sync_test.rb`
  - 추가 필요: `script/load_test.rb` (wrk 또는 k6)
