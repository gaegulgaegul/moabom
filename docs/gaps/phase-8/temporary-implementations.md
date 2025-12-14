# Temporary Implementations - Phase 8 Native API

## 요약
- 총 항목 수: 4개
- P0 (즉시): 0개
- P1 (다음 스프린트): 3개
- P2 (백로그): 1개

## 항목 목록

### 1. N+1 쿼리 가능성
- **현재 상태**:
  - `families_data`에서 `includes(:family_memberships, :users)` 사용
  - `children_data`에서 `flat_map`으로 children 접근 시 추가 쿼리 발생 가능
  ```ruby
  def children_data
    current_user.families.flat_map do |family|
      family.children.map do |child|  # N+1 발생 가능
        # ...
      end
    end
  end
  ```

- **개선 필요 사항**:
  - `families.includes(:children)` 추가
  - Bullet gem으로 N+1 감지 활성화
  - 성능 테스트 추가 (다수 가족/자녀 시나리오)

- **우선순위**: P1 (다음 스프린트)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/api/native/syncs_controller.rb:46-58`

---

### 2. 응답 포맷 일관성 부족
- **현재 상태**:
  - `SyncsController`: 직접 해시 반환
  ```ruby
  render json: {
    user: user_data,
    families: families_data,
    children: children_data
  }
  ```
  - `PushTokensController`: `{ status: "success", device: {...} }` 형식
  - 수동으로 JSON 구조 작성 (중복, 오류 가능성)

- **개선 필요 사항**:
  - Serializer 도입 (ActiveModel::Serializer 또는 Blueprinter)
  - 통일된 응답 래퍼 (`data`, `meta`, `error` 키)
  - API 버전별 Serializer 관리
  - 응답 스키마 문서화

- **우선순위**: P1 (다음 스프린트)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/api/native/syncs_controller.rb`
  - `/Users/lms/dev/repository/moabom/app/controllers/api/native/push_tokens_controller.rb`

---

### 3. 공통 에러 핸들러 부재
- **현재 상태**:
  - 각 컨트롤러에서 에러 응답 직접 렌더링
  ```ruby
  render json: { error: { code: "unauthorized", message: "..." } }, status: :unauthorized
  ```
  - `PushTokensController`에서만 `rescue` 사용
  - 에러 응답 형식 중복 코드

- **개선 필요 사항**:
  - `Api::BaseController`에 공통 에러 핸들러 추가
  ```ruby
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
  rescue_from ActionController::ParameterMissing, with: :handle_bad_request
  ```
  - 에러 응답 헬퍼 메서드 (`render_error(code, message, status)`)
  - 로깅 통합 (Sentry, Rollbar)

- **우선순위**: P1 (다음 스프린트)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/app/controllers/api/base_controller.rb`
  - `/Users/lms/dev/repository/moabom/app/controllers/api/native/push_tokens_controller.rb`

---

### 4. 테스트 헬퍼 중복
- **현재 상태**:
  - `SyncsControllerTest`와 `PushTokensControllerTest`에서 `login_as` 메서드 중복 정의
  ```ruby
  def login_as(user)
    post login_path, params: { user_id: user.id }
  end
  ```

- **개선 필요 사항**:
  - `test/test_helper.rb`로 이동
  - `api_login_as(user)` 메서드로 통일
  - API 토큰 인증으로 전환 시 헬퍼도 업데이트
  - JSON API 테스트 헬퍼 모듈 분리 (`ApiTestHelpers`)

- **우선순위**: P2 (백로그)

- **관련 파일**:
  - `/Users/lms/dev/repository/moabom/test/controllers/api/native/syncs_controller_test.rb:81-83`
  - `/Users/lms/dev/repository/moabom/test/controllers/api/native/push_tokens_controller_test.rb:139-141`
  - `/Users/lms/dev/repository/moabom/test/test_helper.rb` (추가 필요)
