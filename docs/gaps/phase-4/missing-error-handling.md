# 에러 처리 누락 (Missing Error Handling)

> 예외 상황 처리가 부족한 부분

---

## 1. 글로벌 에러 핸들러 없음 🔴 Critical

| 항목 | 내용 |
|-----|------|
| **파일** | `app/controllers/application_controller.rb` |
| **현재 상태** | `rescue_from` 블록 없음 |
| **우선순위** | **P0** |

### 현재 코드

```ruby
class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  private

  def current_user
    # ...
  end

  # rescue_from 없음!
end
```

### 문제점

1. `ActiveRecord::RecordNotFound` → Rails 기본 500 에러 페이지
2. `ActionController::ParameterMissing` → 사용자 친화적이지 않은 에러
3. 프로덕션에서 스택 트레이스 노출 가능성

### 개선 방향

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from ActionController::InvalidAuthenticityToken, with: :unprocessable_entity

  private

  def not_found
    respond_to do |format|
      format.html { render "errors/404", status: :not_found }
      format.json { render json: { error: "not_found" }, status: :not_found }
    end
  end

  def bad_request(exception)
    respond_to do |format|
      format.html { render "errors/400", status: :bad_request }
      format.json { render json: { error: exception.message }, status: :bad_request }
    end
  end

  def unprocessable_entity
    respond_to do |format|
      format.html { redirect_to root_path, alert: "세션이 만료되었습니다. 다시 시도해주세요." }
      format.json { render json: { error: "invalid_token" }, status: :unprocessable_entity }
    end
  end
end
```

---

## 2. HTTP 상태 코드 누락

| 항목 | 내용 |
|-----|------|
| **위치** | 여러 컨트롤러 |
| **우선순위** | P1 |

### 문제 있는 코드들

```ruby
# app/controllers/families_controller.rb:24
redirect_to root_path, alert: "접근 권한이 없습니다." unless @family
# 문제: 권한 없음인데 302 redirect (403이어야 함)

# app/controllers/families/members_controller.rb:53
redirect_to family_members_path(@family), alert: "권한이 없습니다."
# 문제: 동일

# app/controllers/application_controller.rb:23
redirect_to root_path, alert: "로그인이 필요합니다."
# 문제: 인증 필요인데 302 redirect (401이어야 함)
```

### 개선 방향

```ruby
# 인증 필요
def authenticate_user!
  return if logged_in?

  respond_to do |format|
    format.html { redirect_to root_path, alert: "로그인이 필요합니다." }
    format.json { render json: { error: "unauthorized" }, status: :unauthorized }
  end
end

# 권한 없음
def authorize_edit!
  membership = current_user.family_memberships.find_by(family: @family)
  return if membership&.role_owner? || membership&.role_admin?

  respond_to do |format|
    format.html { redirect_to @family, alert: "수정 권한이 없습니다." }
    format.json { render json: { error: "forbidden" }, status: :forbidden }
  end
end
```

---

## 3. 모델 유효성 검증 부족

### 3.1 User - Email 포맷 검증 없음

| 항목 | 내용 |
|-----|------|
| **파일** | `app/models/user.rb:7` |
| **현재** | `validates :email, presence: true` |
| **우선순위** | P1 |

```ruby
# 현재: 아무 문자열이나 허용
validates :email, presence: true

# 개선: 이메일 형식 검증
validates :email, presence: true,
          format: { with: URI::MailTo::EMAIL_REGEXP, message: "형식이 올바르지 않습니다" }
```

### 3.2 Comment - Body 길이 제한 없음

| 항목 | 내용 |
|-----|------|
| **파일** | `app/models/comment.rb:7` |
| **현재** | `validates :body, presence: true` |
| **우선순위** | P1 |

```ruby
# 현재: 무제한 길이 허용
validates :body, presence: true

# 개선: 길이 제한
validates :body, presence: true, length: { maximum: 1000 }
```

### 3.3 Reaction - Emoji 포맷 검증 없음

| 항목 | 내용 |
|-----|------|
| **파일** | `app/models/reaction.rb:7` |
| **현재** | `validates :emoji, presence: true` |
| **우선순위** | P2 |

```ruby
# 현재: 아무 문자열이나 허용 (예: "asdf")
validates :emoji, presence: true

# 개선: 허용된 이모지만
ALLOWED_EMOJIS = %w[❤️ 😍 😂 👍 🎉 😢].freeze
validates :emoji, presence: true, inclusion: { in: ALLOWED_EMOJIS }
```

### 3.4 Photo - 파일 크기/타입 검증 없음 🔴

| 항목 | 내용 |
|-----|------|
| **파일** | `app/models/photo.rb:13-14` |
| **현재** | `validates :image, presence: true` |
| **우선순위** | **P0** |

```ruby
# 현재: 파일 존재만 확인
validates :image, presence: true

# 개선: 크기와 타입 검증
validates :image, presence: true,
          content_type: ['image/jpeg', 'image/png', 'image/heic', 'image/webp'],
          size: { less_than: 50.megabytes, message: '파일 크기는 50MB 이하여야 합니다' }

# 또는 커스텀 검증
validate :acceptable_image

private

def acceptable_image
  return unless image.attached?

  unless image.blob.byte_size <= 50.megabytes
    errors.add(:image, "파일 크기는 50MB 이하여야 합니다")
  end

  acceptable_types = ["image/jpeg", "image/png", "image/heic", "image/webp"]
  unless acceptable_types.include?(image.content_type)
    errors.add(:image, "지원하지 않는 파일 형식입니다")
  end
end
```

---

## 4. 예외 상황 미처리

### 4.1 초대 수락 동시 요청

| 항목 | 내용 |
|-----|------|
| **파일** | `app/controllers/invitations_controller.rb` |
| **시나리오** | 같은 사용자가 동시에 두 번 수락 클릭 |
| **우선순위** | P2 |

```ruby
# 현재: 중복 FamilyMembership 생성 시도 → DB 에러
def accept
  # ...
  FamilyMembership.create!(...)  # 두 번째 요청에서 실패
end

# 개선: find_or_create 사용
def accept
  membership = FamilyMembership.find_or_create_by!(
    user: current_user,
    family: @invitation.family
  ) do |m|
    m.role = @invitation.role
  end
  # ...
end
```

### 4.2 파일 업로드 실패

| 항목 | 내용 |
|-----|------|
| **파일** | (PhotosController 미구현) |
| **시나리오** | S3/스토리지 연결 실패 |
| **우선순위** | P1 |

```ruby
# 개선: 업로드 실패 처리
def create
  @photo = @family.photos.build(photo_params)
  @photo.uploader = current_user

  if @photo.save
    redirect_to family_photos_path(@family), notice: "업로드 완료"
  else
    # Active Storage 에러 포함 처리
    flash.now[:alert] = @photo.errors.full_messages.join(", ")
    render :new, status: :unprocessable_entity
  end
rescue ActiveStorage::IntegrityError => e
  Rails.logger.error("Storage error: #{e.message}")
  flash[:alert] = "파일 업로드에 실패했습니다. 다시 시도해주세요."
  redirect_to new_family_photo_path(@family)
end
```

### 4.3 OAuth 콜백 실패

| 항목 | 내용 |
|-----|------|
| **파일** | `app/controllers/oauth_callbacks_controller.rb` |
| **시나리오** | OAuth 제공자 오류, 사용자 거부 |
| **우선순위** | P1 |

```ruby
# 현재: 기본 처리만
def kakao
  auth = request.env["omniauth.auth"]
  user = User.find_or_create_from_oauth(auth)
  # ...
end

# 개선: 실패 케이스 처리
def kakao
  auth = request.env["omniauth.auth"]

  if auth.nil?
    redirect_to root_path, alert: "카카오 로그인에 실패했습니다."
    return
  end

  user = User.find_or_create_from_oauth(auth)
  # ...
rescue StandardError => e
  Rails.logger.error("OAuth error: #{e.message}")
  redirect_to root_path, alert: "로그인 처리 중 오류가 발생했습니다."
end

def failure
  redirect_to root_path, alert: "로그인이 취소되었습니다."
end
```

---

## 5. 로깅 부족

| 항목 | 현재 상태 |
|-----|----------|
| 에러 로깅 | Rails 기본만 사용 |
| 감사 로깅 | 없음 |
| 성능 로깅 | 없음 |

### 개선 방향

```ruby
# 주요 액션에 로깅 추가
def create
  @photo = @family.photos.build(photo_params)

  if @photo.save
    Rails.logger.info("Photo created: #{@photo.id} by user #{current_user.id}")
    # ...
  else
    Rails.logger.warn("Photo creation failed: #{@photo.errors.full_messages}")
    # ...
  end
end
```

---

## 요약

| 항목 | 우선순위 | 위험도 | 예상 공수 |
|-----|---------|-------|---------|
| 글로벌 에러 핸들러 | P0 | High | 2시간 |
| Photo 파일 검증 | P0 | High | 1시간 |
| HTTP 상태 코드 | P1 | Medium | 1시간 |
| Email 포맷 검증 | P1 | Medium | 15분 |
| Comment 길이 제한 | P1 | Medium | 15분 |
| OAuth 실패 처리 | P1 | Medium | 1시간 |
| Reaction 이모지 검증 | P2 | Low | 30분 |
| 동시 요청 처리 | P2 | Low | 1시간 |
| 로깅 개선 | P2 | Low | 2시간 |

### 즉시 조치 체크리스트 (P0)

- [ ] `ApplicationController`에 `rescue_from` 추가
- [ ] `Photo` 모델에 파일 크기/타입 검증 추가
- [ ] 에러 페이지 뷰 생성 (`errors/404.html.erb`, `errors/500.html.erb`)
