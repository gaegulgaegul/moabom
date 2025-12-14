# 모아봄 아키텍처 가이드

> 애플리케이션 아키텍처 및 코드 구성 원칙
> 버전: 1.0
> 최종 수정: 2025-12-14

---

## 1. 시스템 개요

```
┌─────────────────────────────────────────────────────────────────┐
│                        클라이언트                                │
├─────────────────────┬─────────────────────┬─────────────────────┤
│   iOS (Turbo Native)│ Android (Turbo Native)│    Web Browser     │
└─────────────────────┴─────────────────────┴─────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Rails 8 Application                          │
├─────────────────────────────────────────────────────────────────┤
│  Hotwire (Turbo + Stimulus)  │  JSON API (Native Bridge)       │
├─────────────────────────────────────────────────────────────────┤
│  Controllers  │  Services  │  Models  │  Jobs  │  Mailers      │
├─────────────────────────────────────────────────────────────────┤
│              SQLite (Solid Cache/Queue/Cable)                   │
├─────────────────────────────────────────────────────────────────┤
│              Active Storage (S3/R2 or Local)                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. 레이어 아키텍처

### 2.1 레이어 구조

```
┌─────────────────────────────────────────────────────┐
│                    Presentation Layer               │
│  (Controllers, Views, Stimulus, Turbo)              │
├─────────────────────────────────────────────────────┤
│                    Application Layer                │
│  (Services, Jobs, Form Objects)                     │
├─────────────────────────────────────────────────────┤
│                    Domain Layer                     │
│  (Models, Concerns, Value Objects)                  │
├─────────────────────────────────────────────────────┤
│                    Infrastructure Layer             │
│  (Active Record, Active Storage, External APIs)     │
└─────────────────────────────────────────────────────┘
```

### 2.2 의존성 규칙

- **상위 레이어는 하위 레이어에만 의존**
- Controller → Service → Model → Database
- View는 Model을 직접 참조하지 않음 (Presenter/Decorator 사용 권장)

---

## 3. 컴포넌트 책임

### 3.1 Controller

**책임:**
- HTTP 요청/응답 처리
- 인증/인가 확인
- 서비스 호출 및 결과 처리
- 응답 형식 결정 (HTML/JSON)

```ruby
class PhotosController < ApplicationController
  def create
    result = PhotoUploadService.call(
      family: current_family,
      user: current_user,
      params: photo_params
    )

    if result.success?
      respond_to do |format|
        format.html { redirect_to result.photo }
        format.turbo_stream
        format.json { render json: result.photo }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

**하지 말 것:**
- 비즈니스 로직 포함
- 복잡한 쿼리 작성
- 외부 API 직접 호출

### 3.2 Service

**책임:**
- 비즈니스 로직 캡슐화
- 여러 모델에 걸친 작업 조율
- 트랜잭션 관리
- 외부 API 통합

```ruby
# app/services/photo_upload_service.rb
class PhotoUploadService
  Result = Data.define(:success?, :photo, :error)

  def self.call(...) = new(...).call

  def initialize(family:, user:, params:)
    @family = family
    @user = user
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      photo = create_photo
      schedule_processing(photo)
      notify_family(photo)
      Result.new(success?: true, photo: photo, error: nil)
    end
  rescue StandardError => e
    Result.new(success?: false, photo: nil, error: e.message)
  end

  private

  attr_reader :family, :user, :params

  def create_photo
    family.photos.create!(params.merge(uploader: user))
  end

  def schedule_processing(photo)
    ProcessPhotoJob.perform_later(photo)
  end

  def notify_family(photo)
    NotifyFamilyJob.perform_later(photo)
  end
end
```

### 3.3 Model

**책임:**
- 데이터 영속성
- 유효성 검증
- 연관관계 정의
- 도메인 로직 (해당 모델에 국한된)

```ruby
class Photo < ApplicationRecord
  # 연관관계
  belongs_to :family
  belongs_to :uploader, class_name: "User"
  has_one_attached :image

  # 유효성 검증
  validates :image, presence: true
  validates :taken_at, presence: true

  # 스코프
  scope :recent, -> { order(taken_at: :desc) }
  scope :by_month, ->(year, month) { where(taken_at: month_range(year, month)) }

  # 도메인 로직 (이 모델에 국한된)
  def thumbnail_url
    image.variant(:thumbnail).processed.url
  end

  def owned_by?(user)
    uploader == user
  end

  private

  def self.month_range(year, month)
    date = Date.new(year, month)
    date.beginning_of_month..date.end_of_month
  end
end
```

**하지 말 것:**
- 컨트롤러 로직 포함
- 외부 API 호출
- 다른 모델의 비즈니스 로직 포함

### 3.4 Job

**책임:**
- 비동기 작업 처리
- 시간이 오래 걸리는 작업
- 외부 서비스 호출
- 스케줄링된 작업

```ruby
class ProcessPhotoJob < ApplicationJob
  queue_as :default

  def perform(photo)
    photo.image.analyze
    photo.update!(
      width: photo.image.metadata[:width],
      height: photo.image.metadata[:height]
    )
  end
end
```

### 3.5 Concern

**책임:**
- 재사용 가능한 모듈 추출
- 횡단 관심사 분리

```ruby
# app/models/concerns/has_family.rb
module HasFamily
  extend ActiveSupport::Concern

  included do
    belongs_to :family
    scope :for_family, ->(family) { where(family: family) }
  end

  def family_members
    family.members
  end
end
```

---

## 4. 도메인 모델 설계

### 4.1 핵심 도메인

```
┌─────────────────────────────────────────────────────────────────┐
│                         Family                                  │
│  (가족 그룹 - Aggregate Root)                                   │
├─────────────────────────────────────────────────────────────────┤
│                              │                                  │
│     ┌───────────────────────┼───────────────────────┐          │
│     ▼                       ▼                       ▼          │
│ ┌────────────┐      ┌────────────┐          ┌────────────┐     │
│ │   Child    │      │   Photo    │          │Membership  │     │
│ │ (아이)     │      │ (사진)     │          │(구성원)    │     │
│ └────────────┘      └─────┬──────┘          └──────┬─────┘     │
│                           │                        │           │
│                     ┌─────┴──────┐                 │           │
│                     ▼            ▼                 ▼           │
│               ┌──────────┐ ┌──────────┐      ┌──────────┐     │
│               │ Reaction │ │ Comment  │      │   User   │     │
│               │ (반응)   │ │ (댓글)   │      │ (사용자) │     │
│               └──────────┘ └──────────┘      └──────────┘     │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Aggregate 경계

| Aggregate | Root | 포함 Entity |
|-----------|------|-------------|
| Family | Family | Membership, Child, Invitation |
| Photo | Photo | Reaction, Comment |
| User | User | Device |

### 4.3 접근 규칙

```ruby
# Good: Aggregate Root를 통해 접근
family = current_user.families.find(params[:family_id])
photo = family.photos.find(params[:id])

# Bad: 직접 접근
photo = Photo.find(params[:id])  # 권한 체크 누락 가능
```

---

## 5. 데이터 흐름

### 5.1 사진 업로드 플로우

```
User                    Controller              Service                 Model/Job
  │                         │                      │                        │
  │  POST /photos           │                      │                        │
  │────────────────────────>│                      │                        │
  │                         │                      │                        │
  │                         │  call(params)        │                        │
  │                         │─────────────────────>│                        │
  │                         │                      │                        │
  │                         │                      │  Photo.create!         │
  │                         │                      │───────────────────────>│
  │                         │                      │                        │
  │                         │                      │  perform_later         │
  │                         │                      │───────────────────────>│
  │                         │                      │                        │
  │                         │  Result              │                        │
  │                         │<─────────────────────│                        │
  │                         │                      │                        │
  │  HTML/Turbo Stream      │                      │                        │
  │<────────────────────────│                      │                        │
```

### 5.2 실시간 업데이트 (Turbo Stream)

```
Photo Created           Job                     Turbo Cable
      │                  │                          │
      │  perform_later   │                          │
      │─────────────────>│                          │
      │                  │                          │
      │                  │  broadcast_prepend_to    │
      │                  │─────────────────────────>│
      │                  │                          │
      │                  │                          │  Stream to clients
      │                  │                          │─────────────────>
```

---

## 6. 에러 처리 전략

### 6.1 레이어별 에러 처리

```ruby
# Controller: HTTP 에러로 변환
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  private

  def not_found
    render "errors/not_found", status: :not_found
  end
end

# Service: 도메인 에러 정의
class PhotoUploadService
  class UploadError < StandardError; end
  class FileTooLargeError < UploadError; end

  def call
    # ...
  rescue FileTooLargeError => e
    Result.new(success?: false, error: e.message)
  end
end

# Model: 유효성 검증 에러
class Photo < ApplicationRecord
  validates :image, presence: true
  # errors.full_messages로 접근
end
```

### 6.2 에러 코드 체계

```ruby
# app/lib/error_codes.rb
module ErrorCodes
  # 인증/인가
  UNAUTHORIZED = "unauthorized"
  FORBIDDEN = "forbidden"

  # 유효성
  VALIDATION_FAILED = "validation_failed"
  INVALID_PARAMETER = "invalid_parameter"

  # 리소스
  NOT_FOUND = "not_found"
  CONFLICT = "conflict"

  # 서버
  INTERNAL_ERROR = "internal_error"
  SERVICE_UNAVAILABLE = "service_unavailable"
end
```

---

## 7. 보안 아키텍처

### 7.1 인증 플로우

```
┌─────────────────────────────────────────────────────────────────┐
│                        OAuth 2.0 Flow                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  User ──> App ──> OAuth Provider (Kakao/Apple/Google)           │
│                         │                                       │
│                         ▼                                       │
│                    Authorization Code                           │
│                         │                                       │
│                         ▼                                       │
│  App ──> Exchange Code for Token ──> Provider                   │
│                         │                                       │
│                         ▼                                       │
│                    Access Token + User Info                     │
│                         │                                       │
│                         ▼                                       │
│  App ──> Create/Update User ──> Session Cookie                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 7.2 인가 규칙

```ruby
# app/policies/photo_policy.rb (Pundit 사용 시)
class PhotoPolicy < ApplicationPolicy
  def show?
    user.member_of?(record.family)
  end

  def create?
    membership = user.membership_for(record.family)
    membership&.can_upload?
  end

  def destroy?
    record.uploader == user || user.admin_of?(record.family)
  end
end
```

---

## 8. 스케일링 고려사항

### 8.1 현재 아키텍처 (MVP)

```
┌─────────────────────────────────────────┐
│           Railway (단일 인스턴스)        │
│  ┌─────────────────────────────────────┐│
│  │  Rails App + SQLite + Active Storage ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

### 8.2 스케일 아웃 시 (미래)

```
┌─────────────────────────────────────────────────────────────────┐
│                         Load Balancer                           │
├───────────────────────────┬─────────────────────────────────────┤
│                           │                                     │
│    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    │
│    │   Rails #1   │    │   Rails #2   │    │   Rails #3   │    │
│    └──────────────┘    └──────────────┘    └──────────────┘    │
│                           │                                     │
├───────────────────────────┴─────────────────────────────────────┤
│    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    │
│    │  PostgreSQL  │    │    Redis     │    │  S3/R2       │    │
│    │  (Primary)   │    │  (Cache/Job) │    │  (Storage)   │    │
│    └──────────────┘    └──────────────┘    └──────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

### 8.3 마이그레이션 포인트

| 시점 | 변경 사항 |
|-----|----------|
| 사용자 100명+ | SQLite → PostgreSQL |
| 사용자 1,000명+ | Active Storage Local → S3/R2 |
| 사용자 10,000명+ | Solid Queue → Sidekiq + Redis |
| 사용자 100,000명+ | 멀티 인스턴스 + CDN |

---

## 9. 테스트 아키텍처

### 9.1 테스트 피라미드

```
                    /\
                   /  \
                  / E2E \        (적음, 느림)
                 /  Tests \
                /──────────\
               /            \
              / Integration  \   (중간)
             /     Tests      \
            /──────────────────\
           /                    \
          /     Unit Tests       \  (많음, 빠름)
         /________________________\
```

### 9.2 테스트 전략

| 레이어 | 테스트 종류 | 도구 |
|-------|-----------|------|
| Model | Unit Test | Minitest |
| Service | Unit Test | Minitest |
| Controller | Integration Test | Minitest |
| View/UI | System Test | Capybara + Selenium |

---

## 10. 참고 자료

- [Rails Architecture - Martin Fowler](https://martinfowler.com/articles/railsArch.html)
- [Domain-Driven Rails](https://blog.arkency.com/domain-driven-rails/)
- [Tidy First? - Kent Beck](https://www.oreilly.com/library/view/tidy-first/9781098151232/)
- [모아봄 상세 아키텍처](/docs/features/ARCHITECTURE.md)
