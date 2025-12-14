# 모아봄 코딩 가이드

> Rails 8 Best Practices 기반
> 버전: 1.0
> 최종 수정: 2025-12-14

---

## 1. Ruby 스타일

### 1.1 기본 포맷팅

```ruby
# 들여쓰기: 2 spaces (탭 사용 금지)
# 줄 끝 공백 금지
# 파일 끝 빈 줄 1개
# 최대 줄 길이: 120자
```

### 1.2 네이밍 컨벤션

| 타입 | 스타일 | 예시 |
|-----|--------|------|
| 클래스/모듈 | PascalCase | `PhotoUploader`, `FamilyMembership` |
| 메서드/변수 | snake_case | `upload_photo`, `current_user` |
| 상수 | SCREAMING_SNAKE | `MAX_UPLOAD_SIZE`, `DEFAULT_ROLE` |
| 파일명 | snake_case | `photo_uploader.rb`, `family_membership.rb` |
| 테이블명 | snake_case (복수형) | `photos`, `family_memberships` |

### 1.3 메서드 정의

```ruby
# Good: 짧고 명확한 메서드
def full_name
  "#{first_name} #{last_name}"
end

# Good: 키워드 인자 사용
def create_photo(image:, caption: nil, child: nil)
  Photo.create!(image: image, caption: caption, child: child)
end

# Bad: 위치 인자 3개 이상
def create_photo(image, caption, child, family)
  # ...
end
```

### 1.4 조건문

```ruby
# Good: guard clause 사용
def process
  return unless valid?
  return if processed?

  do_processing
end

# Good: safe navigation operator
user&.family&.name

# Bad: 중첩 if문
def process
  if valid?
    if !processed?
      do_processing
    end
  end
end
```

### 1.5 컬렉션

```ruby
# Good: 블록 한 줄
photos.map(&:thumbnail_url)
photos.select(&:published?)

# Good: 여러 줄 블록은 do...end
photos.each do |photo|
  photo.process
  photo.notify_family
end

# Bad: 한 줄 블록에 do...end
photos.each do |photo| photo.process end
```

---

## 2. Rails 컨벤션

### 2.1 모델 (Model)

```ruby
class Photo < ApplicationRecord
  # 1. 상수
  MAX_FILE_SIZE = 50.megabytes
  ALLOWED_TYPES = %w[image/jpeg image/png image/heic video/mp4].freeze

  # 2. 연관관계
  belongs_to :family
  belongs_to :uploader, class_name: "User"
  belongs_to :child, optional: true
  has_many :reactions, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one_attached :image

  # 3. Validations
  validates :image, presence: true
  validates :taken_at, presence: true

  # 4. Callbacks (최소화)
  before_validation :set_taken_at, on: :create

  # 5. Scopes
  scope :recent, -> { order(taken_at: :desc) }
  scope :by_month, ->(year, month) { where(taken_at: Date.new(year, month)..Date.new(year, month).end_of_month) }
  scope :for_child, ->(child) { where(child: child) }

  # 6. 클래스 메서드
  def self.timeline_for(family, page: 1)
    where(family: family).recent.page(page)
  end

  # 7. 인스턴스 메서드
  def thumbnail_url
    image.variant(resize_to_limit: [300, 300]).processed.url
  end

  private

  def set_taken_at
    self.taken_at ||= image.blob&.created_at || Time.current
  end
end
```

### 2.2 컨트롤러 (Controller)

```ruby
class PhotosController < ApplicationController
  # 1. Callbacks
  before_action :authenticate_user!
  before_action :set_family
  before_action :set_photo, only: [:show, :edit, :update, :destroy]
  before_action :authorize_photo, only: [:edit, :update, :destroy]

  # 2. RESTful actions (index, show, new, create, edit, update, destroy)
  def index
    @photos = @family.photos.recent.page(params[:page])
  end

  def show
  end

  def create
    @photo = @family.photos.build(photo_params)
    @photo.uploader = current_user

    if @photo.save
      redirect_to family_photo_path(@family, @photo), notice: "사진이 업로드되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @photo.destroy
    redirect_to family_photos_path(@family), notice: "사진이 삭제되었습니다."
  end

  private

  # 3. Private 메서드
  def set_family
    @family = current_user.families.find(params[:family_id])
  end

  def set_photo
    @photo = @family.photos.find(params[:id])
  end

  def authorize_photo
    unless @photo.uploader == current_user || current_user.admin_of?(@family)
      redirect_to family_photos_path(@family), alert: "권한이 없습니다."
    end
  end

  def photo_params
    params.require(:photo).permit(:image, :caption, :taken_at, :child_id)
  end
end
```

### 2.3 Slim 컨트롤러 원칙

```ruby
# Good: 컨트롤러는 얇게, 로직은 모델/서비스로
class PhotosController < ApplicationController
  def create
    result = PhotoUploadService.call(
      family: @family,
      user: current_user,
      params: photo_params
    )

    if result.success?
      redirect_to result.photo, notice: result.message
    else
      @photo = result.photo
      render :new, status: :unprocessable_entity
    end
  end
end

# Bad: 컨트롤러에 비즈니스 로직
class PhotosController < ApplicationController
  def create
    @photo = Photo.new(photo_params)
    @photo.family = @family
    @photo.uploader = current_user

    if @photo.image.content_type.start_with?("video")
      @photo.process_video
    end

    @photo.extract_exif_data
    @photo.generate_thumbnails

    # ... 더 많은 로직
  end
end
```

---

## 3. 서비스 객체

### 3.1 서비스 객체 패턴

```ruby
# app/services/photo_upload_service.rb
class PhotoUploadService
  Result = Struct.new(:success?, :photo, :message, keyword_init: true)

  def self.call(...)
    new(...).call
  end

  def initialize(family:, user:, params:)
    @family = family
    @user = user
    @params = params
  end

  def call
    photo = build_photo

    if photo.save
      notify_family_members(photo)
      Result.new(success?: true, photo: photo, message: "업로드 완료")
    else
      Result.new(success?: false, photo: photo, message: photo.errors.full_messages.join(", "))
    end
  end

  private

  attr_reader :family, :user, :params

  def build_photo
    family.photos.build(params).tap do |photo|
      photo.uploader = user
    end
  end

  def notify_family_members(photo)
    NotifyFamilyJob.perform_later(photo)
  end
end
```

### 3.2 서비스 사용 시점

- 여러 모델에 걸친 복잡한 작업
- 외부 API 호출
- 비즈니스 로직이 컨트롤러/모델에 적합하지 않을 때
- 트랜잭션이 필요한 여러 단계 작업

---

## 4. 뷰 (View)

### 4.1 ERB 템플릿

```erb
<%# app/views/photos/index.html.erb %>

<%# Good: 로직 최소화 %>
<%= render @photos %>

<%# Good: 헬퍼 사용 %>
<%= time_ago_in_words(photo.created_at) %>

<%# Bad: 뷰에서 복잡한 로직 %>
<% if photo.uploader == current_user || current_user.memberships.find_by(family: photo.family)&.role == "admin" %>
  ...
<% end %>
```

### 4.2 Partials

```erb
<%# app/views/photos/_photo.html.erb %>
<%= turbo_frame_tag dom_id(photo) do %>
  <article class="photo-card">
    <%= image_tag photo.thumbnail_url, loading: "lazy" %>
    <div class="photo-meta">
      <%= photo.caption %>
    </div>
  </article>
<% end %>
```

### 4.3 Turbo Frames & Streams

```erb
<%# Turbo Frame: 페이지 일부 교체 %>
<%= turbo_frame_tag "photos" do %>
  <%= render @photos %>
<% end %>

<%# Turbo Stream: 실시간 업데이트 %>
<%# app/views/photos/create.turbo_stream.erb %>
<%= turbo_stream.prepend "photos", @photo %>
<%= turbo_stream.update "flash", partial: "shared/flash" %>
```

---

## 5. 데이터베이스

### 5.1 마이그레이션

```ruby
class CreatePhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :photos do |t|
      # 외래 키는 references 사용
      t.references :family, null: false, foreign_key: true
      t.references :uploader, null: false, foreign_key: { to_table: :users }
      t.references :child, foreign_key: true

      t.string :caption
      t.datetime :taken_at, null: false

      t.timestamps
    end

    # 인덱스는 명시적으로
    add_index :photos, [:family_id, :taken_at]
  end
end
```

### 5.2 쿼리 최적화

```ruby
# Good: N+1 방지 - includes 사용
@photos = Photo.includes(:uploader, :child, :reactions).recent

# Good: 필요한 컬럼만 선택
Photo.select(:id, :caption, :taken_at).recent

# Good: 카운트는 별도 쿼리
@photos_count = @family.photos.count
@photos = @family.photos.limit(50)

# Bad: N+1 쿼리
@photos.each do |photo|
  puts photo.uploader.name  # 매번 쿼리 발생
end
```

### 5.3 Enum 사용

```ruby
class FamilyMembership < ApplicationRecord
  # Good: Hash 문법 사용 (값 명시)
  enum :role, {
    viewer: 0,
    member: 1,
    admin: 2,
    owner: 3
  }, prefix: true

  # Usage
  membership.role_admin?
  membership.role_owner!
end
```

---

## 6. 테스팅

### 6.1 Minitest 구조

```ruby
# test/models/photo_test.rb
require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  # setup은 간결하게
  setup do
    @family = families(:kim_family)
    @user = users(:mom)
  end

  # 테스트명: should_동작_when_조건
  test "should be valid with required attributes" do
    photo = Photo.new(
      family: @family,
      uploader: @user,
      image: fixture_file_upload("photo.jpg"),
      taken_at: Time.current
    )
    assert photo.valid?
  end

  test "should require image" do
    photo = Photo.new(family: @family, uploader: @user, taken_at: Time.current)
    assert_not photo.valid?
    assert_includes photo.errors[:image], "can't be blank"
  end

  test "should scope by month" do
    jan_photo = photos(:january_photo)
    feb_photo = photos(:february_photo)

    result = Photo.by_month(2025, 1)

    assert_includes result, jan_photo
    assert_not_includes result, feb_photo
  end
end
```

### 6.2 시스템 테스트

```ruby
# test/system/photo_uploads_test.rb
require "application_system_test_case"

class PhotoUploadsTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    sign_in @user
  end

  test "uploading a photo" do
    visit family_photos_path(@user.families.first)

    click_on "사진 업로드"
    attach_file "photo[image]", Rails.root.join("test/fixtures/files/photo.jpg")
    fill_in "photo[caption]", with: "첫 걸음!"
    click_on "업로드"

    assert_text "사진이 업로드되었습니다"
    assert_selector "img[alt='첫 걸음!']"
  end
end
```

---

## 7. 보안

### 7.1 Strong Parameters

```ruby
# 항상 permit으로 허용 목록 지정
def photo_params
  params.require(:photo).permit(:image, :caption, :taken_at, :child_id)
end

# 중첩 속성
def family_params
  params.require(:family).permit(
    :name,
    children_attributes: [:id, :name, :birthdate, :_destroy]
  )
end
```

### 7.2 인가 (Authorization)

```ruby
# 리소스 접근은 항상 현재 사용자 기준으로 scope
@family = current_user.families.find(params[:family_id])
@photo = @family.photos.find(params[:id])

# 직접 find 금지
@photo = Photo.find(params[:id])  # Bad: 다른 가족 사진 접근 가능
```

### 7.3 SQL Injection 방지

```ruby
# Good: Parameterized query
Photo.where("caption LIKE ?", "%#{query}%")
Photo.where(family_id: family_ids)

# Bad: String interpolation
Photo.where("caption LIKE '%#{query}%'")
```

---

## 8. 성능

### 8.1 캐싱

```ruby
# Fragment caching
<% cache photo do %>
  <%= render photo %>
<% end %>

# Russian doll caching
<% cache [@family, @family.updated_at] do %>
  <% @family.photos.each do |photo| %>
    <% cache photo do %>
      <%= render photo %>
    <% end %>
  <% end %>
<% end %>
```

### 8.2 Background Jobs

```ruby
# 시간이 오래 걸리는 작업은 Job으로
class ProcessPhotoJob < ApplicationJob
  queue_as :default

  def perform(photo)
    photo.generate_thumbnails
    photo.extract_metadata
  end
end

# 호출
ProcessPhotoJob.perform_later(@photo)
```

---

## 9. 참고 자료

- [RuboCop Rails Style Guide](https://github.com/rubocop/rails-style-guide)
- [Shopify Ruby Style Guide](https://ruby-style-guide.shopify.dev/)
- [Rails Guides](https://guides.rubyonrails.org/)
- [10 Best Practices for Clean Rails Code](https://rubyroidlabs.com/blog/2025/06/best-practices-clean-and-maintainable-ror-code/)
