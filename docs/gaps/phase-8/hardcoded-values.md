# Hardcoded Values - Phase 8 Native API

## 요약
- 총 항목 수: 4개
- P0 (즉시): 0개
- P1 (다음 스프린트): 2개
- P2 (백로그): 2개

## 항목 목록

### 1. 플랫폼 값 하드코딩
- **현재 상태**:
  - `Device` 모델에서 플랫폼 배열 하드코딩
  ```ruby
  validates :platform, presence: true, inclusion: { in: %w[ios android] }
  enum :platform, { ios: "ios", android: "android" }, validate: true
  ```

- **개선 필요 사항**:
  - 상수로 분리
  ```ruby
  class Device < ApplicationRecord
    PLATFORMS = %w[ios android].freeze

    validates :platform, presence: true, inclusion: { in: PLATFORMS }
    enum :platform, PLATFORMS.index_by(&:itself), validate: true
  end
  ```
  - 향후 플랫폼 추가 용이 (web, desktop 등)
  - 테스트에서 `Device::PLATFORMS` 참조

- **우선순위**: P2 (백로그)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/models/device.rb:6, 10`

---

### 2. 에러 코드 문자열 하드코딩
- **현재 상태**:
  - 에러 코드가 문자열로 중복
  ```ruby
  { error: { code: "unauthorized", message: "..." } }
  { error: { code: "validation_failed", message: "..." } }
  { error: { code: "bad_request", message: "..." } }
  { error: { code: "not_found", message: "..." } }
  ```

- **개선 필요 사항**:
  - `ErrorCodes` 모듈 생성
  ```ruby
  # app/lib/error_codes.rb
  module ErrorCodes
    UNAUTHORIZED = "unauthorized"
    VALIDATION_FAILED = "validation_failed"
    BAD_REQUEST = "bad_request"
    NOT_FOUND = "not_found"
    INTERNAL_ERROR = "internal_error"
  end
  ```
  - 컨트롤러에서 상수 사용
  ```ruby
  render json: { error: { code: ErrorCodes::UNAUTHORIZED, ... } }
  ```
  - 오타 방지, IDE 자동완성 지원

- **우선순위**: P1 (다음 스프린트)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/api/base_controller.rb:19`
  - `/Users/lms/dev/repository/moabom/app/controllers/api/native/push_tokens_controller.rb:24, 32, 47`
  - 추가 필요: `app/lib/error_codes.rb`

---

### 3. 에러 메시지 하드코딩 (I18n 미사용)
- **현재 상태**:
  - 한국어 메시지 직접 입력
  ```ruby
  message: "인증이 필요합니다."
  message: "Device not found"  # 영어 혼재
  ```

- **개선 필요 사항**:
  - I18n으로 다국어 지원
  ```yaml
  # config/locales/api.ko.yml
  ko:
    api:
      errors:
        unauthorized: "인증이 필요합니다."
        not_found: "리소스를 찾을 수 없습니다."
        device_not_found: "기기를 찾을 수 없습니다."
  ```
  ```ruby
  message: I18n.t("api.errors.unauthorized")
  ```
  - Accept-Language 헤더 지원
  - 영어 번역 추가 (`en.yml`)

- **우선순위**: P1 (다음 스프린트)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/api/base_controller.rb:19`
  - `/Users/lms/dev/repository/moabom/app/controllers/api/native/push_tokens_controller.rb:48`
  - 추가 필요: `config/locales/api.ko.yml`, `config/locales/api.en.yml`

---

### 4. 응답 키 이름 하드코딩
- **현재 상태**:
  - JSON 응답 키가 문자열로 직접 입력
  ```ruby
  render json: {
    user: user_data,
    families: families_data,
    children: children_data
  }

  render json: {
    status: "success",
    device: { ... }
  }
  ```

- **개선 필요 사항**:
  - Serializer 도입으로 해결 (temporary-implementations.md #2 참조)
  - 또는 응답 키 상수화
  ```ruby
  module ApiResponseKeys
    USER = "user"
    FAMILIES = "families"
    CHILDREN = "children"
    STATUS = "status"
    DEVICE = "device"
  end
  ```

- **우선순위**: P2 (백로그) - Serializer 도입 시 자동 해결

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/api/native/syncs_controller.rb:7-11`
  - `/Users/lms/dev/repository/moabom/app/controllers/api/native/push_tokens_controller.rb:12, 43`
