# Wave 6 Phase 1: 알림 기능 구현

> 실시간 알림 시스템 및 알림 데이터 구현
> 작성일: 2025-12-21

---

## 개요

Wave 5 Phase 4에서 알림 목록 UI와 네비게이션을 구현했으나, 실제 알림 데이터는 빈 상태로 남아있습니다. 이번 Phase에서는 Notification 모델을 생성하고, 반응/댓글 등의 이벤트 발생 시 알림을 생성하여 사용자에게 전달하는 기능을 구현합니다.

---

## 목표

- [ ] Notification 모델 생성 및 마이그레이션
- [ ] 알림 생성 서비스 구현
- [ ] 반응/댓글 이벤트와 알림 연동
- [ ] 알림 목록 뷰 업데이트 (실제 데이터 표시)
- [ ] 읽음/안읽음 상태 관리
- [ ] 알림 배지 동적 처리

---

## 작업 1: Notification 모델 생성

### RED: 테스트 작성

- [ ] **RED**: Notification 모델 단위 테스트 작성

```ruby
# test/models/notification_test.rb
require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    @user = users(:mom)
    @photo = photos(:baby_photo)
    @reaction = reactions(:dad_reaction)
  end

  test "should be valid with required attributes" do
    notification = Notification.new(
      recipient: @user,
      actor: users(:dad),
      notifiable: @reaction,
      notification_type: "reaction_created"
    )
    assert notification.valid?
  end

  test "should require recipient" do
    notification = Notification.new(
      actor: users(:dad),
      notifiable: @reaction,
      notification_type: "reaction_created"
    )
    assert_not notification.valid?
    assert_includes notification.errors[:recipient], "must exist"
  end

  test "should require actor" do
    notification = Notification.new(
      recipient: @user,
      notifiable: @reaction,
      notification_type: "reaction_created"
    )
    assert_not notification.valid?
    assert_includes notification.errors[:actor], "must exist"
  end

  test "should require notifiable" do
    notification = Notification.new(
      recipient: @user,
      actor: users(:dad),
      notification_type: "reaction_created"
    )
    assert_not notification.valid?
    assert_includes notification.errors[:notifiable], "must exist"
  end

  test "should require notification_type" do
    notification = Notification.new(
      recipient: @user,
      actor: users(:dad),
      notifiable: @reaction
    )
    assert_not notification.valid?
    assert_includes notification.errors[:notification_type], "can't be blank"
  end

  test "should default to unread" do
    notification = Notification.create!(
      recipient: @user,
      actor: users(:dad),
      notifiable: @reaction,
      notification_type: "reaction_created"
    )
    assert_not notification.read?
  end

  test "should scope unread notifications" do
    read_notification = notifications(:read_notification)
    unread_notification = notifications(:unread_notification)

    unread = Notification.unread
    assert_includes unread, unread_notification
    assert_not_includes unread, read_notification
  end

  test "should scope recent notifications" do
    recent = Notification.recent
    assert_equal Notification.order(created_at: :desc).to_a, recent.to_a
  end

  test "should mark as read" do
    notification = notifications(:unread_notification)
    assert_not notification.read?

    notification.mark_as_read!
    assert notification.read?
    assert_not_nil notification.read_at
  end

  test "should generate message for reaction_created" do
    notification = Notification.new(
      recipient: @user,
      actor: users(:dad),
      notifiable: @reaction,
      notification_type: "reaction_created"
    )
    assert_match(/반응을 남겼습니다/, notification.message)
  end

  test "should generate message for comment_created" do
    comment = comments(:dad_comment)
    notification = Notification.new(
      recipient: @user,
      actor: users(:dad),
      notifiable: comment,
      notification_type: "comment_created"
    )
    assert_match(/댓글을 남겼습니다/, notification.message)
  end
end
```

### GREEN: 최소 구현

- [ ] **GREEN**: Notification 마이그레이션 생성

```bash
rails generate migration CreateNotifications
```

```ruby
# db/migrate/YYYYMMDDHHMMSS_create_notifications.rb
class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      # 수신자 (알림을 받는 사용자)
      t.references :recipient, null: false, foreign_key: { to_table: :users }

      # 행위자 (알림을 발생시킨 사용자)
      t.references :actor, null: false, foreign_key: { to_table: :users }

      # 알림 대상 (Polymorphic)
      t.references :notifiable, polymorphic: true, null: false

      # 알림 타입
      t.string :notification_type, null: false

      # 읽음 여부
      t.datetime :read_at

      t.timestamps
    end

    # 인덱스
    add_index :notifications, [:recipient_id, :read_at]
    add_index :notifications, [:recipient_id, :created_at]
  end
end
```

- [ ] **GREEN**: Notification 모델 생성

```ruby
# app/models/notification.rb
class Notification < ApplicationRecord
  # 연관관계
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  # Validations
  validates :notification_type, presence: true
  validates :notification_type, inclusion: {
    in: %w[reaction_created comment_created],
    message: "%{value} is not a valid notification type"
  }

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # 인스턴스 메서드
  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def message
    case notification_type
    when "reaction_created"
      "#{actor.nickname}님이 사진에 반응을 남겼습니다"
    when "comment_created"
      "#{actor.nickname}님이 댓글을 남겼습니다"
    else
      "새로운 알림이 있습니다"
    end
  end
end
```

- [ ] **GREEN**: User 모델에 연관관계 추가

```ruby
# app/models/user.rb
class User < ApplicationRecord
  # 기존 연관관계...

  # 알림
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_many :sent_notifications, class_name: "Notification", foreign_key: :actor_id, dependent: :destroy

  # Counter cache를 사용할 경우 아래 association 추가 필요
  # has_many :unread_notifications, -> { where(read_at: nil) },
  #          foreign_key: :recipient_id,
  #          class_name: "Notification"
  #
  # 하지만 현재는 manual callback 방식 사용 (Notification 모델 참조)
end
```

- [ ] **GREEN**: Reaction/Comment 모델에 연관관계 추가

```ruby
# app/models/reaction.rb
class Reaction < ApplicationRecord
  # 기존 코드...

  has_many :notifications, as: :notifiable, dependent: :destroy
end

# app/models/comment.rb
class Comment < ApplicationRecord
  # 기존 코드...

  has_many :notifications, as: :notifiable, dependent: :destroy
end
```

### REFACTOR: 리팩토링

- [ ] **REFACTOR**: Notification 타입을 Enum으로 변경 검토

```ruby
# app/models/notification.rb (선택적)
class Notification < ApplicationRecord
  enum :notification_type, {
    reaction_created: "reaction_created",
    comment_created: "comment_created"
  }, prefix: true
end
```

---

## 작업 2: 알림 생성 서비스 구현

### RED: 테스트 작성

- [ ] **RED**: NotificationService 테스트 작성

```ruby
# test/services/notification_service_test.rb
require "test_helper"

class NotificationServiceTest < ActiveSupport::TestCase
  setup do
    @photo = photos(:baby_photo)
    @uploader = @photo.uploader
    @actor = users(:dad)
  end

  test "should create notification for reaction" do
    reaction = Reaction.create!(
      photo: @photo,
      user: @actor,
      emoji: "❤️"
    )

    assert_difference "Notification.count", 1 do
      NotificationService.notify_reaction_created(reaction)
    end

    notification = Notification.last
    assert_equal @uploader, notification.recipient
    assert_equal @actor, notification.actor
    assert_equal reaction, notification.notifiable
    assert_equal "reaction_created", notification.notification_type
  end

  test "should create notification for comment" do
    comment = Comment.create!(
      photo: @photo,
      user: @actor,
      content: "귀여워요!"
    )

    assert_difference "Notification.count", 1 do
      NotificationService.notify_comment_created(comment)
    end

    notification = Notification.last
    assert_equal @uploader, notification.recipient
    assert_equal @actor, notification.actor
    assert_equal comment, notification.notifiable
    assert_equal "comment_created", notification.notification_type
  end

  test "should not create notification if actor is photo uploader" do
    reaction = Reaction.create!(
      photo: @photo,
      user: @uploader, # 본인이 반응
      emoji: "❤️"
    )

    assert_no_difference "Notification.count" do
      NotificationService.notify_reaction_created(reaction)
    end
  end

  test "should not create duplicate notification for same reaction update" do
    reaction = Reaction.create!(
      photo: @photo,
      user: @actor,
      emoji: "❤️"
    )

    # 첫 번째 알림 생성
    NotificationService.notify_reaction_created(reaction)

    # 같은 반응 업데이트 시 중복 알림 생성 안 함
    reaction.update!(emoji: "👍")

    assert_no_difference "Notification.count" do
      NotificationService.notify_reaction_created(reaction)
    end
  end
end
```

### GREEN: 최소 구현

- [ ] **GREEN**: NotificationService 생성

```ruby
# app/services/notification_service.rb
class NotificationService
  class << self
    def notify_reaction_created(reaction)
      photo = reaction.photo
      recipient = photo.uploader
      actor = reaction.user

      # 본인이 남긴 반응에는 알림 생성 안 함
      return if recipient == actor

      # 기존 알림 확인 (중복 방지)
      existing = Notification.find_by(
        recipient: recipient,
        actor: actor,
        notifiable: reaction,
        notification_type: "reaction_created"
      )
      return if existing

      Notification.create!(
        recipient: recipient,
        actor: actor,
        notifiable: reaction,
        notification_type: "reaction_created"
      )
    end

    def notify_comment_created(comment)
      photo = comment.photo
      recipient = photo.uploader
      actor = comment.user

      # 본인이 남긴 댓글에는 알림 생성 안 함
      return if recipient == actor

      Notification.create!(
        recipient: recipient,
        actor: actor,
        notifiable: comment,
        notification_type: "comment_created"
      )
    end
  end
end
```

### REFACTOR: 리팩토링

- [ ] **REFACTOR**: 공통 로직 추출

```ruby
# app/services/notification_service.rb
class NotificationService
  class << self
    def notify_reaction_created(reaction)
      create_notification(
        recipient: reaction.photo.uploader,
        actor: reaction.user,
        notifiable: reaction,
        notification_type: "reaction_created",
        check_duplicate: true
      )
    end

    def notify_comment_created(comment)
      create_notification(
        recipient: comment.photo.uploader,
        actor: comment.user,
        notifiable: comment,
        notification_type: "comment_created"
      )
    end

    private

    def create_notification(recipient:, actor:, notifiable:, notification_type:, check_duplicate: false)
      # 본인에게는 알림 생성 안 함
      return if recipient == actor

      # 중복 체크
      if check_duplicate
        existing = Notification.find_by(
          recipient: recipient,
          actor: actor,
          notifiable: notifiable,
          notification_type: notification_type
        )
        return if existing
      end

      Notification.create!(
        recipient: recipient,
        actor: actor,
        notifiable: notifiable,
        notification_type: notification_type
      )
    end
  end
end
```

---

## 작업 3: 반응/댓글 컨트롤러에 알림 연동

### RED: 테스트 작성

- [ ] **RED**: 컨트롤러 테스트 업데이트

```ruby
# test/controllers/photos/reactions_controller_test.rb
test "should create notification when creating reaction" do
  photo = photos(:baby_photo)
  uploader = photo.uploader

  assert_difference "Notification.count", 1 do
    post family_photo_reactions_path(@family, photo),
         params: { reaction: { emoji: "❤️" } }
  end

  notification = Notification.last
  assert_equal uploader, notification.recipient
  assert_equal @user, notification.actor
end

# test/controllers/photos/comments_controller_test.rb
test "should create notification when creating comment" do
  photo = photos(:baby_photo)
  uploader = photo.uploader

  assert_difference "Notification.count", 1 do
    post family_photo_comments_path(@family, photo),
         params: { comment: { content: "귀여워요!" } }
  end

  notification = Notification.last
  assert_equal uploader, notification.recipient
  assert_equal @user, notification.actor
end
```

### GREEN: 최소 구현

- [ ] **GREEN**: ReactionsController 업데이트

```ruby
# app/controllers/photos/reactions_controller.rb
def create
  @reaction = @photo.reactions.find_or_initialize_by(user: current_user)
  @reaction.emoji = reaction_params[:emoji]

  if @reaction.save
    # 알림 생성
    NotificationService.notify_reaction_created(@reaction)

    respond_to do |format|
      format.turbo_stream
      format.json { render json: @reaction, status: :created }
    end
  else
    # 에러 처리...
  end
end
```

- [ ] **GREEN**: CommentsController 업데이트

```ruby
# app/controllers/photos/comments_controller.rb
def create
  @comment = @photo.comments.build(comment_params)
  @comment.user = current_user

  if @comment.save
    # 알림 생성
    NotificationService.notify_comment_created(@comment)

    respond_to do |format|
      format.turbo_stream
      format.json { render json: @comment, status: :created }
    end
  else
    # 에러 처리...
  end
end
```

### REFACTOR: 리팩토링

- [ ] **REFACTOR**: Job으로 비동기 처리

```ruby
# app/jobs/create_notification_job.rb
class CreateNotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_type, notifiable)
    case notification_type
    when "reaction_created"
      NotificationService.notify_reaction_created(notifiable)
    when "comment_created"
      NotificationService.notify_comment_created(notifiable)
    end
  end
end

# 컨트롤러에서 사용
CreateNotificationJob.perform_later("reaction_created", @reaction)
```

---

## 작업 4: 알림 목록 뷰 업데이트

### RED: 테스트 작성

- [ ] **RED**: NotificationsController 테스트 업데이트

```ruby
# test/controllers/notifications_controller_test.rb
test "should get index with notifications" do
  # 알림 생성
  notification = Notification.create!(
    recipient: @user,
    actor: users(:dad),
    notifiable: reactions(:dad_reaction),
    notification_type: "reaction_created"
  )

  get notifications_path
  assert_response :success
  assert_select ".notification-item", count: 1
end

test "should show unread badge" do
  # 읽지 않은 알림 생성
  Notification.create!(
    recipient: @user,
    actor: users(:dad),
    notifiable: reactions(:dad_reaction),
    notification_type: "reaction_created"
  )

  get notifications_path
  assert_select ".notification-item.unread", count: 1
end
```

- [ ] **RED**: 시스템 테스트 작성

```ruby
# test/system/notifications_test.rb
require "application_system_test_case"

class NotificationsTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    @family.complete_onboarding!
    sign_in @user
  end

  test "should display notifications in list" do
    notification = Notification.create!(
      recipient: @user,
      actor: users(:dad),
      notifiable: reactions(:dad_reaction),
      notification_type: "reaction_created"
    )

    visit notifications_path

    assert_text "아빠님이 사진에 반응을 남겼습니다"
    assert_no_text "알림이 없습니다"
  end

  test "should mark notification as read when clicked" do
    notification = Notification.create!(
      recipient: @user,
      actor: users(:dad),
      notifiable: reactions(:dad_reaction),
      notification_type: "reaction_created"
    )

    visit notifications_path

    # 알림 클릭
    find(".notification-item").click

    # 사진 상세로 이동
    assert_current_path family_photo_path(@family, notification.notifiable.photo)

    # 알림이 읽음 처리됨
    assert notification.reload.read?
  end

  test "should show unread count badge in header" do
    Notification.create!(
      recipient: @user,
      actor: users(:dad),
      notifiable: reactions(:dad_reaction),
      notification_type: "reaction_created"
    )

    visit root_path

    within "header" do
      assert_selector ".notification-badge", text: "1"
    end
  end
end
```

### GREEN: 최소 구현

- [ ] **GREEN**: NotificationsController 업데이트

```ruby
# app/controllers/notifications_controller.rb
class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_onboarding!

  def index
    @notifications = current_user.notifications.recent.includes(:actor, :notifiable)
  end

  def update
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!

    # 알림 대상으로 리다이렉트
    redirect_to notification_target_path(@notification)
  end

  private

  def notification_target_path(notification)
    case notification.notifiable
    when Reaction, Comment
      family_photo_path(
        notification.notifiable.photo.family,
        notification.notifiable.photo
      )
    else
      notifications_path
    end
  end
end
```

- [ ] **GREEN**: 라우트 업데이트

```ruby
# config/routes.rb
resources :notifications, only: [ :index, :update ]
```

- [ ] **GREEN**: 알림 목록 뷰 업데이트

```erb
# app/views/notifications/index.html.erb
<div class="px-4 py-6">
  <h1 class="text-2xl font-bold text-warm-gray-800 mb-6">알림</h1>

  <% if @notifications.empty? %>
    <!-- 빈 상태 -->
    <div class="flex flex-col items-center justify-center py-16 text-center">
      <%= heroicon "bell", variant: :outline, options: { class: "w-16 h-16 text-warm-gray-300" } %>
      <h3 class="mt-4 text-lg font-medium text-warm-gray-800">알림이 없습니다</h3>
      <p class="mt-2 text-sm text-warm-gray-500">새로운 소식이 있으면 알려드릴게요.</p>
    </div>
  <% else %>
    <!-- 알림 목록 -->
    <div class="space-y-2">
      <% @notifications.each do |notification| %>
        <%= link_to notification_path(notification),
                    data: { turbo_method: :patch },
                    class: "block p-4 rounded-xl hover:bg-cream-50 transition-colors #{notification.read? ? '' : 'bg-primary-50 border-l-4 border-primary-500'}" do %>
          <div class="flex items-start gap-3">
            <!-- 아바타 -->
            <div class="w-10 h-10 rounded-full bg-primary-200 flex items-center justify-center flex-shrink-0">
              <span class="text-lg"><%= notification.actor.nickname.first %></span>
            </div>

            <!-- 내용 -->
            <div class="flex-1 min-w-0">
              <p class="text-sm text-warm-gray-800 font-medium">
                <%= notification.message %>
              </p>
              <p class="text-xs text-warm-gray-500 mt-1">
                <%= time_ago_in_words(notification.created_at) %> 전
              </p>
            </div>

            <!-- 읽지 않음 표시 -->
            <% unless notification.read? %>
              <div class="w-2 h-2 bg-primary-500 rounded-full flex-shrink-0 mt-2"></div>
            <% end %>
          </div>
        <% end %>
      <% end %>
    </div>
  <% end %>
</div>
```

### REFACTOR: 리팩토링

- [ ] **REFACTOR**: 알림 아이템 partial 분리

```erb
# app/views/notifications/_notification.html.erb
<%= link_to notification_path(notification),
            data: { turbo_method: :patch },
            class: "notification-item block p-4 rounded-xl hover:bg-cream-50 transition-colors #{notification.read? ? '' : 'unread bg-primary-50 border-l-4 border-primary-500'}" do %>
  <div class="flex items-start gap-3">
    <%= render "notifications/avatar", actor: notification.actor %>
    <%= render "notifications/content", notification: notification %>
    <%= render "notifications/unread_badge" unless notification.read? %>
  </div>
<% end %>
```

---

## 작업 5: 알림 배지 동적 처리

### RED: 테스트 작성

- [ ] **RED**: 헤더 알림 배지 테스트

```ruby
# test/helpers/application_helper_test.rb
test "unread_notifications_count returns correct count" do
  user = users(:mom)

  # 읽지 않은 알림 3개 생성
  3.times do |i|
    Notification.create!(
      recipient: user,
      actor: users(:dad),
      notifiable: reactions(:dad_reaction),
      notification_type: "reaction_created"
    )
  end

  assert_equal 3, unread_notifications_count(user)
end

test "unread_notifications_count returns 0 when no notifications" do
  user = users(:uncle)
  assert_equal 0, unread_notifications_count(user)
end
```

### GREEN: 최소 구현

- [ ] **GREEN**: 헬퍼 메서드 추가

```ruby
# app/helpers/application_helper.rb
def unread_notifications_count(user = current_user)
  return 0 unless user

  user.notifications.unread.count
end
```

- [ ] **GREEN**: 헤더 업데이트

```erb
# app/views/shared/_header.html.erb
<!-- 알림 -->
<%= link_to notifications_path,
            class: "relative p-2 rounded-full hover:bg-cream-100 tap-highlight-none",
            "aria-label": "알림" do %>
  <%= heroicon "bell", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-700" } %>
  <% if unread_notifications_count > 0 %>
    <span class="absolute top-1 right-1 min-w-[18px] h-[18px] px-1
                 bg-accent-500 text-white text-xs font-semibold
                 rounded-full flex items-center justify-center"
          aria-label="읽지 않은 알림">
      <%= unread_notifications_count > 9 ? "9+" : unread_notifications_count %>
    </span>
  <% end %>
<% end %>
```

### REFACTOR: 리팩토링

- [ ] **REFACTOR**: Counter Cache 적용

```ruby
# db/migrate/YYYYMMDDHHMMSS_add_unread_notifications_count_to_users.rb
class AddUnreadNotificationsCountToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :unread_notifications_count, :integer, default: 0, null: false

    # 기존 데이터 업데이트 (Notification 모델 생성 후 backfill)
    reversible do |dir|
      dir.up do
        User.find_each do |user|
          unread_count = Notification.where(recipient_id: user.id, read_at: nil).count
          user.update_column(:unread_notifications_count, unread_count)
        end
      end
    end
  end
end

# app/models/notification.rb
class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"

  # 생성 시: 읽지 않은 알림이면 카운터 증가
  after_commit :increment_unread_count, on: :create

  # 삭제 시: 읽지 않은 알림이면 카운터 감소
  after_commit :decrement_unread_count, on: :destroy

  # 업데이트 시: read 상태 변경에 따라 카운터 조정
  after_commit :update_unread_count, on: :update

  private

  def increment_unread_count
    recipient.increment!(:unread_notifications_count) unless read?
  end

  def decrement_unread_count
    recipient.decrement!(:unread_notifications_count) unless read?
  end

  def update_unread_count
    if saved_change_to_read_at?
      if read?
        # 읽지 않음 → 읽음: 카운터 감소
        recipient.decrement!(:unread_notifications_count)
      else
        # 읽음 → 읽지 않음: 카운터 증가
        recipient.increment!(:unread_notifications_count)
      end
    end
  end
end

# app/helpers/application_helper.rb
def unread_notifications_count(user = current_user)
  return 0 unless user

  user.unread_notifications_count
end
```

---

## 검증 체크리스트

### 기능 테스트
- [ ] 반응 생성 시 사진 업로더에게 알림 전송
- [ ] 댓글 생성 시 사진 업로더에게 알림 전송
- [ ] 본인이 남긴 반응/댓글에는 알림 미생성
- [ ] 알림 목록에서 알림 표시
- [ ] 알림 클릭 시 대상 페이지로 이동
- [ ] 알림 클릭 시 읽음 처리
- [ ] 헤더 알림 아이콘에 읽지 않은 알림 수 배지 표시
- [ ] 읽지 않은 알림은 강조 표시

### 성능 테스트
- [ ] N+1 쿼리 방지 (includes 사용)
- [ ] Counter cache로 배지 성능 최적화
- [ ] 알림 목록 페이지네이션 고려 (추후)

### 코드 품질
- [ ] `rails test` - 모든 테스트 통과
- [ ] `rubocop` - Lint 에러 없음
- [ ] 디버그 코드 제거 (puts, binding.pry)
- [ ] 주석 처리된 코드 제거

### 설계 문서 확인
- [ ] PRD.md의 알림 기능 요구사항 충족
- [ ] API_DESIGN.md의 엔드포인트 규격 준수
- [ ] ARCHITECTURE.md의 레이어 책임 준수
- [ ] DESIGN_GUIDE.md의 컴포넌트 스타일 준수

---

## 추후 개선 사항

### Phase 6.2: 알림 고도화
- 알림 그룹핑 (같은 사진에 여러 반응 → "3명이 반응했습니다")
- 알림 설정 (알림 타입별 on/off)
- 알림 삭제 기능
- 모든 알림 읽음 처리
- 알림 필터링 (읽음/안읽음)

### Phase 6.3: 실시간 알림
- Turbo Streams를 통한 실시간 알림 업데이트
- Action Cable을 통한 WebSocket 연결
- 푸시 알림 (Turbo Native)

### Phase 6.4: 알림 페이지네이션
- 무한 스크롤 또는 페이지네이션
- 오래된 알림 자동 정리 (30일 이상)

---

## 참고사항

- Phase 6 Gap 분석 문서: `docs/gaps/phase-6/`
- 현재 반응/댓글 기능은 구현되어 있으나 알림 연동이 누락됨
- 보안 이슈 (이모지 검증, 댓글 길이 제한)는 별도 작업으로 진행

---

## 커밋 전략

1. **작업 1 커밋**: `feat(notifications): Notification 모델 및 마이그레이션 생성`
2. **작업 2 커밋**: `feat(notifications): 알림 생성 서비스 구현`
3. **작업 3 커밋**: `feat(notifications): 반응/댓글과 알림 연동`
4. **작업 4 커밋**: `feat(notifications): 알림 목록 뷰 실제 데이터 표시`
5. **작업 5 커밋**: `feat(notifications): 헤더 알림 배지 동적 처리`
