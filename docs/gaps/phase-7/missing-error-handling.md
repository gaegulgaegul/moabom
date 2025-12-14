# Missing Error Handling - Phase 7 설정

## 요약
- 총 항목 수: 7개
- P0 (즉시): 3개
- P1 (다음 스프린트): 3개
- P2 (백로그): 1개

## 항목 목록

### 1. 닉네임 유효성 검증 부족
- **현재 상태**:
  - `validates :nickname, presence: true`만 존재
  - 길이, 형식, 특수문자 검증 없음
- **개선 필요 사항**:
  - 최소/최대 길이 검증 (2~20자)
  - 허용 문자 패턴 정규식
  - 금지어 필터링
  - SQL Injection 방지 (이미 ActiveRecord가 처리하지만 명시적 검증)
- **우선순위**: P0
- **관련 파일**:
  - `app/models/user.rb` (L9)

**개선 예시**:
```ruby
class User < ApplicationRecord
  validates :nickname,
    presence: true,
    length: { minimum: 2, maximum: 20 },
    format: { with: /\A[가-힣a-zA-Z0-9_]+\z/, message: "한글, 영문, 숫자, 언더스코어만 사용 가능합니다" }
  validate :nickname_not_banned

  private

  def nickname_not_banned
    banned_words = Rails.application.config.banned_nicknames
    errors.add(:nickname, "사용할 수 없는 닉네임입니다") if banned_words.include?(nickname&.downcase)
  end
end
```

### 2. 동시 수정 시 충돌 처리 없음
- **현재 상태**:
  - Optimistic locking 미적용
  - 여러 기기에서 동시 수정 시 마지막 저장만 반영
- **개선 필요 사항**:
  - `lock_version` 컬럼 추가
  - `StaleObjectError` 처리
  - 충돌 시 사용자에게 알림 및 재시도 유도
- **우선순위**: P1
- **관련 파일**:
  - `db/migrate/*_add_lock_version_to_users.rb`
  - `app/models/user.rb`
  - `app/controllers/settings/profiles_controller.rb`
  - `app/controllers/settings/notifications_controller.rb`

**개선 예시**:
```ruby
# Migration
add_column :users, :lock_version, :integer, default: 0, null: false

# Controller
def update
  current_user.update(profile_params)
rescue ActiveRecord::StaleObjectError
  flash.now[:alert] = "다른 곳에서 프로필이 수정되었습니다. 페이지를 새로고침해주세요."
  render :show, status: :conflict
end
```

### 3. 네트워크 오류 처리 없음
- **현재 상태**:
  - 클라이언트 측 네트워크 오류 처리 없음
  - 타임아웃 처리 없음
- **개선 필요 사항**:
  - Stimulus controller로 네트워크 오류 감지
  - 재시도 버튼 표시
  - 오프라인 상태 감지 및 알림
  - 낙관적 UI 업데이트 후 실패 시 롤백
- **우선순위**: P1
- **관련 파일**:
  - 신규: `app/javascript/controllers/settings_controller.js`
  - `app/views/settings/profiles/show.html.erb`
  - `app/views/settings/notifications/show.html.erb`

### 4. 파일 업로드 검증 부족 (아바타 업로드 시)
- **현재 상태**: 아바타 업로드 자체가 미구현
- **개선 필요 사항**:
  - 파일 크기 제한 (예: 5MB)
  - 허용 MIME 타입 검증 (image/jpeg, image/png, image/heic)
  - 악성 파일 업로드 방지
  - 이미지 차원 검증 (최소 100x100px)
- **우선순위**: P0 (아바타 업로드 구현 시)
- **관련 파일**:
  - `app/models/user.rb`
  - 신규: `app/validators/avatar_validator.rb`

**개선 예시**:
```ruby
class User < ApplicationRecord
  has_one_attached :avatar

  validates :avatar,
    content_type: { in: %w[image/jpeg image/png image/heic], message: "JPG, PNG, HEIC 형식만 업로드 가능합니다" },
    size: { less_than: 5.megabytes, message: "파일 크기는 5MB 이하여야 합니다" }
end
```

### 5. CSRF 토큰 만료 처리 부족
- **현재 상태**:
  - Rails 기본 CSRF 보호만 의존
  - 토큰 만료 시 사용자 경험 나쁨 (422 에러)
- **개선 필요 사항**:
  - CSRF 토큰 만료 감지
  - 자동 토큰 갱신
  - 사용자 친화적 에러 메시지
- **우선순위**: P2
- **관련 파일**:
  - `app/controllers/application_controller.rb`
  - 신규: `app/javascript/controllers/csrf_refresh_controller.js`

### 6. 알림 설정 유효성 검증 없음
- **현재 상태**:
  - boolean 필드라 잘못된 값 입력 가능성 낮음
  - 하지만 명시적 검증 없음
- **개선 필요 사항**:
  - inclusion 검증
  - 최소 하나의 알림은 켜져 있도록 강제 (선택적)
- **우선순위**: P1
- **관련 파일**:
  - `app/models/user.rb`

**개선 예시**:
```ruby
class User < ApplicationRecord
  validates :notify_on_new_photo, inclusion: { in: [true, false] }
  validates :notify_on_comment, inclusion: { in: [true, false] }
  validates :notify_on_reaction, inclusion: { in: [true, false] }

  # 선택적: 최소 하나는 활성화
  validate :at_least_one_notification_enabled

  private

  def at_least_one_notification_enabled
    unless notify_on_new_photo || notify_on_comment || notify_on_reaction
      errors.add(:base, "최소 하나의 알림은 활성화해야 합니다")
    end
  end
end
```

### 7. 에러 응답 형식 불일치
- **현재 상태**:
  - HTML 응답만 존재
  - API/JSON 에러 응답 형식 미정의
- **개선 필요 사항**:
  - `respond_to` 블록으로 형식별 응답
  - JSON API 에러 형식 표준화 (RFC 7807)
  - 에러 코드 체계 정의
- **우선순위**: P0
- **관련 파일**:
  - `app/controllers/settings/profiles_controller.rb` (L10-15)
  - `app/controllers/settings/notifications_controller.rb` (L10-15)

**개선 예시**:
```ruby
def update
  if current_user.update(profile_params)
    respond_to do |format|
      format.html { redirect_to settings_profile_path, notice: t('.update_success') }
      format.json { render json: current_user, status: :ok }
    end
  else
    respond_to do |format|
      format.html { render :show, status: :unprocessable_entity }
      format.json {
        render json: {
          error: {
            code: "validation_failed",
            message: current_user.errors.full_messages.join(", "),
            details: current_user.errors.as_json
          }
        }, status: :unprocessable_entity
      }
    end
  end
end
```
