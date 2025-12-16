# Missing Error Handling - Phase 8 Native API

## 요약
- 총 항목 수: 7개
- P0 (즉시): 1개
- P1 (다음 스프린트): 3개
- P2 (백로그): 3개

## 항목 목록

### 1. CSRF 보호 비활성화 보안 검토
- **현재 상태**:
  - API 전체에서 CSRF 토큰 검증 비활성화
  ```ruby
  class BaseController < ActionController::Base
    skip_before_action :verify_authenticity_token
  end
  ```
  - 대체 보안 메커니즘 없음

- **개선 필요 사항**:
  - JWT 또는 API 토큰 기반 인증 도입 (intentional-simplifications.md #1 참조)
  - 또는 Origin/Referer 헤더 검증
  - CORS 정책 설정 강화
  - API 키 발급 및 관리 시스템
  - 민감한 작업에는 추가 인증 요구 (예: 디바이스 삭제)

- **우선순위**: P0 (즉시) - 보안 취약점

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/api/base_controller.rb:6`

---

### 2. Sync endpoint 쿼리 실패 처리 없음
- **현재 상태**:
  - 데이터베이스 쿼리 실패 시 500 Internal Server Error
  - 예외 처리 없음
  ```ruby
  def show
    render json: {
      user: user_data,
      families: families_data,
      children: children_data
    }
  end
  ```

- **개선 필요 사항**:
  - `Api::BaseController`에 공통 에러 핸들러 추가
  ```ruby
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::StatementInvalid, with: :handle_database_error
  ```
  - 특정 리소스 조회 실패 시 해당 항목만 제외하고 응답
  - 로깅 및 모니터링 (Sentry, Rollbar)

- **우선순위**: P1 (다음 스프린트)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/api/native/syncs_controller.rb:6-12`
  - `/Users/lms/dev/repository/moabom/app/controllers/api/base_controller.rb`

---

### 3. 대량 데이터 응답 처리
- **현재 상태**:
  - 모든 가족/자녀 데이터를 한 번에 반환
  - 데이터 크기 제한 없음
  - 메모리 사용량 폭증 가능

- **개선 필요 사항**:
  - 페이지네이션 추가
  ```ruby
  def show
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 50
    per_page = [per_page, 100].min  # 최대 100개 제한

    families = current_user.families.page(page).per(per_page)
    # ...
  end
  ```
  - 응답 크기 제한 (예: 5MB)
  - Cursor-based pagination (성능 개선)
  - 부분 응답 지원 (`fields` 파라미터)

- **우선순위**: P1 (다음 스프린트)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/api/native/syncs_controller.rb:25-58`

---

### 4. Race Condition (동시 요청 처리)
- **현재 상태**:
  - `find_or_initialize_by` 사용
  - 동시 요청 시 중복 생성 가능
  ```ruby
  def create
    device = current_user.devices.find_or_initialize_by(device_id: device_params[:device_id])
    device.assign_attributes(device_params)
    device.save  # 유니크 제약 위반 가능
  end
  ```

- **개선 필요 사항**:
  - `find_or_create_by!` 사용 또는 트랜잭션 + 락
  ```ruby
  def create
    device = current_user.devices.lock.find_or_initialize_by(device_id: device_params[:device_id])
    device.assign_attributes(device_params)
    device.save!
  rescue ActiveRecord::RecordNotUnique
    retry
  end
  ```
  - 또는 upsert 사용 (Rails 6+)
  ```ruby
  Device.upsert({
    user_id: current_user.id,
    device_id: device_params[:device_id],
    ...
  }, unique_by: [:user_id, :device_id])
  ```

- **우선순위**: P1 (다음 스프린트)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/api/native/push_tokens_controller.rb:7-8`

---

### 5. 디바이스 삭제 시 푸시 토큰 무효화 미처리
- **현재 상태**:
  - 로컬 DB에서만 디바이스 삭제
  - FCM/APNs에 토큰 무효화 알림 없음
  ```ruby
  def destroy
    device = current_user.devices.find_by(device_id: params[:id])
    if device
      device.destroy  # 단순 삭제
      render json: { status: "success" }
    end
  end
  ```

- **개선 필요 사항**:
  - 삭제 전 FCM/APNs에 토큰 무효화 요청
  ```ruby
  def destroy
    device = current_user.devices.find_by(device_id: params[:id])
    if device
      PushNotificationService.revoke_token(device.push_token)
      device.destroy
      render json: { status: "success" }
    end
  end
  ```
  - Background Job으로 비동기 처리
  - 실패 시 로깅 (완전 삭제 실패는 무시 가능)

- **우선순위**: P2 (백로그) - 푸시 알림 구현 후

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/api/native/push_tokens_controller.rb:38-52`

---

### 6. API 타임아웃 처리
- **현재 상태**:
  - API 요청 타임아웃 설정 없음
  - 느린 쿼리 시 무한 대기 가능

- **개선 필요 사항**:
  - Rack::Timeout 설정
  ```ruby
  # config/initializers/timeout.rb
  Rack::Timeout.timeout = 30  # 30초
  Rack::Timeout.wait_timeout = 10  # 10초
  ```
  - 긴 작업은 Background Job으로 전환
  - 타임아웃 시 `503 Service Unavailable` 응답
  - Retry-After 헤더 추가

- **우선순위**: P2 (백로그)

- **관련 파일**:
  - 추가 필요: `config/initializers/timeout.rb`
  - `/Users/lms/dev/repository/moabom/app/controllers/api/base_controller.rb`

---

### 7. Invalid JSON 요청 처리
- **현재 상태**:
  - `ActionController::ParameterMissing`만 처리
  - JSON 파싱 에러는 500 에러 발생
  ```ruby
  rescue ActionController::ParameterMissing => e
    render json: { error: { code: "bad_request", message: e.message } }, status: :bad_request
  end
  ```

- **개선 필요 사항**:
  - JSON 파싱 에러 처리 추가
  ```ruby
  # Api::BaseController
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :handle_json_parse_error

  def handle_json_parse_error(exception)
    render json: {
      error: {
        code: "invalid_json",
        message: "JSON 형식이 올바르지 않습니다."
      }
    }, status: :bad_request
  end
  ```
  - Content-Type 헤더 검증 (`application/json` 강제)

- **우선순위**: P1 (다음 스프린트)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/api/native/push_tokens_controller.rb:29-35`
  - `/Users/lms/dev/repository/moabom/app/controllers/api/base_controller.rb`
