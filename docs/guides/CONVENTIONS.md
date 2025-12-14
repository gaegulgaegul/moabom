# 모아봄 컨벤션

> 프로젝트 전반에 적용되는 규칙과 패턴
> 버전: 1.0
> 최종 수정: 2025-12-14

---

## 1. 디렉토리 구조

```
moabom/
├── app/
│   ├── controllers/
│   │   ├── concerns/           # 컨트롤러 공통 모듈
│   │   ├── api/                # API 컨트롤러 (JSON)
│   │   │   └── native/         # Turbo Native 전용
│   │   └── *.rb                # HTML 컨트롤러
│   ├── models/
│   │   ├── concerns/           # 모델 공통 모듈
│   │   └── *.rb
│   ├── views/
│   │   ├── layouts/
│   │   ├── shared/             # 공통 partials
│   │   └── [controller]/
│   ├── services/               # 서비스 객체
│   ├── jobs/                   # Background Jobs
│   ├── mailers/
│   ├── helpers/
│   └── javascript/
│       └── controllers/        # Stimulus 컨트롤러
├── config/
├── db/
│   ├── migrate/
│   └── seeds.rb
├── docs/                       # 프로젝트 문서
│   ├── guides/                 # 개발 가이드
│   └── *.md                    # 기획 문서
├── lib/
│   └── tasks/                  # Rake tasks
├── test/
│   ├── fixtures/
│   ├── models/
│   ├── controllers/
│   ├── integration/
│   └── system/
└── storage/                    # SQLite DB 파일
```

---

## 2. 네이밍 컨벤션

### 2.1 모델명

| 개념 | 모델명 | 테이블명 | 파일명 |
|-----|-------|---------|--------|
| 사용자 | `User` | `users` | `user.rb` |
| 가족 | `Family` | `families` | `family.rb` |
| 가족 구성원 | `FamilyMembership` | `family_memberships` | `family_membership.rb` |
| 아이 | `Child` | `children` | `child.rb` |
| 사진 | `Photo` | `photos` | `photo.rb` |
| 앨범 | `Album` | `albums` | `album.rb` |
| 반응 | `Reaction` | `reactions` | `reaction.rb` |
| 댓글 | `Comment` | `comments` | `comment.rb` |
| 초대 | `Invitation` | `invitations` | `invitation.rb` |
| 기기 | `Device` | `devices` | `device.rb` |

### 2.2 컨트롤러명

```ruby
# RESTful 리소스 컨트롤러
PhotosController          # app/controllers/photos_controller.rb
FamiliesController        # app/controllers/families_controller.rb

# 중첩 리소스
Families::MembersController    # app/controllers/families/members_controller.rb
Families::ChildrenController   # app/controllers/families/children_controller.rb
Photos::ReactionsController    # app/controllers/photos/reactions_controller.rb

# API 네임스페이스
Api::NativeController          # app/controllers/api/native_controller.rb
Api::Native::PhotosController  # app/controllers/api/native/photos_controller.rb
```

### 2.3 서비스명

```ruby
# [동사][명사]Service 형식
PhotoUploadService        # 사진 업로드 처리
InvitationSendService     # 초대 전송
FaceDetectionService      # 얼굴 인식 처리

# 또는 [명사][동사]er 형식
PhotoUploader
InvitationSender
```

### 2.4 Job명

```ruby
# [동사][명사]Job 형식
ProcessPhotoJob           # 사진 처리
SendNotificationJob       # 알림 전송
CleanupExpiredInvitationsJob  # 만료 초대 정리
```

---

## 3. 라우트 컨벤션

### 3.1 RESTful 라우트

```ruby
# config/routes.rb

Rails.application.routes.draw do
  # 인증
  get "auth/:provider", to: "oauth#start", as: :oauth
  get "auth/:provider/callback", to: "oauth#callback"
  delete "logout", to: "sessions#destroy"

  # 초대 수락 (짧은 URL)
  get "i/:token", to: "invitations#accept", as: :accept_invitation

  # 메인 리소스
  resources :families do
    resources :members, controller: "families/members", only: [:index, :update, :destroy]
    resources :children, controller: "families/children"
    resources :invitations, controller: "families/invitations", only: [:create, :destroy]

    resources :photos, controller: "families/photos" do
      collection do
        post :batch
      end
      resources :reactions, controller: "photos/reactions", only: [:create, :destroy]
      resources :comments, controller: "photos/comments", only: [:index, :create, :destroy]
    end
  end

  # 설정
  namespace :settings do
    resource :profile, only: [:show, :update]
    resource :notifications, only: [:show, :update]
  end

  # API (Native Bridge)
  namespace :api do
    get :me, to: "users#me"
    resources :devices, only: [:create, :destroy]

    namespace :native do
      post :photos
      post :push_token
      get :sync
    end
  end

  # 온보딩
  namespace :onboarding do
    resource :profile, only: [:show, :create]
    resource :child, only: [:show, :create]
    resource :invite, only: [:show]
  end

  root "home#index"
end
```

### 3.2 URL 설계 원칙

```
# Good: 계층적, 명확한 리소스
GET    /families/1/photos          # 가족의 사진 목록
POST   /families/1/photos          # 사진 업로드
GET    /families/1/photos/123      # 사진 상세
DELETE /families/1/photos/123      # 사진 삭제

# Good: 짧은 공개 URL
GET    /i/abc123                   # 초대 링크

# Bad: 동사 기반 URL
GET    /getPhotos
POST   /uploadPhoto
```

---

## 4. 응답 형식

### 4.1 Turbo Native 지원

```ruby
class PhotosController < ApplicationController
  def index
    @photos = @family.photos.recent.page(params[:page])

    respond_to do |format|
      format.html  # HTML (웹 + Turbo Native)
      format.json { render json: @photos }  # API
    end
  end
end
```

### 4.2 JSON API 응답

```ruby
# 성공 응답
{
  "id": 1,
  "caption": "첫 걸음!",
  "thumbnail_url": "https://...",
  "created_at": "2025-01-01T00:00:00Z"
}

# 목록 응답 (페이지네이션)
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 245
  }
}

# 에러 응답
{
  "error": {
    "code": "validation_failed",
    "message": "입력값을 확인해주세요.",
    "details": {
      "name": ["이름을 입력해주세요."]
    }
  }
}
```

---

## 5. 에러 처리

### 5.1 컨트롤러 에러 처리

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def not_found
    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found }
      format.json { render json: { error: { code: "not_found", message: "리소스를 찾을 수 없습니다." } }, status: :not_found }
    end
  end

  def bad_request(exception)
    respond_to do |format|
      format.html { render "errors/bad_request", status: :bad_request }
      format.json { render json: { error: { code: "bad_request", message: exception.message } }, status: :bad_request }
    end
  end
end
```

### 5.2 서비스 에러 처리

```ruby
class PhotoUploadService
  class UploadError < StandardError; end
  class FileTooLargeError < UploadError; end
  class InvalidTypeError < UploadError; end

  def call
    validate_file!
    upload_file
  rescue UploadError => e
    Result.new(success?: false, error: e.message)
  end

  private

  def validate_file!
    raise FileTooLargeError, "파일이 너무 큽니다." if file_too_large?
    raise InvalidTypeError, "지원하지 않는 파일 형식입니다." if invalid_type?
  end
end
```

---

## 6. 시간/날짜 처리

### 6.1 타임존

```ruby
# config/application.rb
config.time_zone = "Seoul"

# DB에는 UTC로 저장, 표시할 때 변환
photo.taken_at                    # => 2025-01-01 09:00:00 +0900 (KST)
photo.taken_at.utc                # => 2025-01-01 00:00:00 UTC

# 뷰에서 표시
<%= l(photo.taken_at, format: :short) %>  # => 2025년 1월 1일
```

### 6.2 날짜 포맷

```ruby
# config/locales/ko.yml
ko:
  date:
    formats:
      default: "%Y년 %m월 %d일"
      short: "%m월 %d일"
      long: "%Y년 %m월 %d일 %A"
  time:
    formats:
      default: "%Y년 %m월 %d일 %H:%M"
      short: "%m/%d %H:%M"
      time_only: "%H:%M"
```

---

## 7. 국제화 (i18n)

### 7.1 구조

```
config/locales/
├── ko.yml              # 한국어 (기본)
├── en.yml              # 영어
├── models/
│   └── ko.yml          # 모델 번역
└── views/
    ├── photos.ko.yml   # 사진 뷰 번역
    └── families.ko.yml # 가족 뷰 번역
```

### 7.2 사용

```ruby
# 컨트롤러
redirect_to @photo, notice: t(".created")

# 뷰
<%= t(".title") %>

# 모델 속성
Photo.human_attribute_name(:caption)  # => "캡션"
```

---

## 8. 테스트 컨벤션

### 8.1 Fixtures

```yaml
# test/fixtures/users.yml
mom:
  email: mom@example.com
  nickname: 엄마
  provider: kakao
  uid: "12345"

dad:
  email: dad@example.com
  nickname: 아빠
  provider: kakao
  uid: "67890"
```

### 8.2 테스트 파일 위치

```
test/
├── models/
│   └── photo_test.rb           # Photo 모델 테스트
├── controllers/
│   └── photos_controller_test.rb
├── integration/
│   └── photo_upload_flow_test.rb
├── system/
│   └── photo_uploads_test.rb   # 브라우저 E2E 테스트
└── services/
    └── photo_upload_service_test.rb
```

### 8.3 테스트 명명

```ruby
# test/models/photo_test.rb
class PhotoTest < ActiveSupport::TestCase
  # 형식: test "should [동작] when [조건]"
  test "should be valid with required attributes" do
  end

  test "should require image" do
  end

  test "should belong to family" do
  end

  # 또는 context/describe 스타일 (minitest-spec 사용 시)
  describe "validations" do
    it "requires image" do
    end
  end
end
```

---

## 9. 환경 설정

### 9.1 환경 변수

```bash
# .env.development (gitignore 대상)
RAILS_MASTER_KEY=xxx
KAKAO_CLIENT_ID=xxx
KAKAO_CLIENT_SECRET=xxx
APPLE_CLIENT_ID=xxx
AWS_ACCESS_KEY_ID=xxx
AWS_SECRET_ACCESS_KEY=xxx
AWS_BUCKET=moabom-dev
```

### 9.2 Rails Credentials

```bash
# 편집
EDITOR="code --wait" rails credentials:edit

# 구조
secret_key_base: xxx
kakao:
  client_id: xxx
  client_secret: xxx
apple:
  client_id: xxx
aws:
  access_key_id: xxx
  secret_access_key: xxx
  bucket: moabom-production
```

---

## 10. Active Storage

### 10.1 이미지 Variant

```ruby
# app/models/photo.rb
class Photo < ApplicationRecord
  has_one_attached :image do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [300, 300]
    attachable.variant :medium, resize_to_limit: [800, 800]
    attachable.variant :large, resize_to_limit: [1600, 1600]
  end
end

# 사용
photo.image.variant(:thumbnail)
```

### 10.2 Direct Upload

```erb
<%# 폼에서 direct upload 사용 %>
<%= form.file_field :image, direct_upload: true %>
```

---

## 11. Hotwire (Turbo + Stimulus)

### 11.1 Turbo Frame 명명

```erb
<%# ID 형식: [리소스]_[id] 또는 [컨텍스트] %>
<%= turbo_frame_tag dom_id(@photo) %>        <%# photo_123 %>
<%= turbo_frame_tag "photos" %>              <%# photos %>
<%= turbo_frame_tag "photo_reactions" %>     <%# photo_reactions %>
```

### 11.2 Stimulus Controller 명명

```javascript
// app/javascript/controllers/photo_upload_controller.js
// HTML: data-controller="photo-upload"

// app/javascript/controllers/infinite_scroll_controller.js
// HTML: data-controller="infinite-scroll"
```

---

## 12. 브랜치 전략

### 12.1 브랜치 명명

```
main                    # 프로덕션 배포 브랜치
develop                 # 개발 통합 브랜치

feature/photo-upload    # 기능 개발
feature/face-detection

fix/photo-rotation      # 버그 수정
fix/upload-timeout

refactor/photo-service  # 리팩토링

docs/api-guide          # 문서 작업
```

### 12.2 PR 규칙

- 모든 변경은 PR을 통해 main에 병합
- PR 제목: `[타입] 간단한 설명`
- 최소 1명 리뷰 후 병합
- 테스트 통과 필수
