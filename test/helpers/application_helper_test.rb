# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  # logged_in? 헬퍼 모킹을 위한 설정
  def logged_in?
    @logged_in || false
  end

  def current_user
    @current_user
  end

  test "show_bottom_tabbar returns false for settings profile pages" do
    # 로그인 상태 시뮬레이션
    @logged_in = true

    # Settings::ProfilesController 시뮬레이션
    @controller = Settings::ProfilesController.new
    @controller.action_name = "show"

    assert_not show_bottom_tabbar?, "설정 프로필 페이지에서는 탭바가 표시되지 않아야 함"
  end

  test "show_bottom_tabbar returns false for settings notifications" do
    # 로그인 상태 시뮬레이션
    @logged_in = true

    # Settings::NotificationsController 시뮬레이션
    @controller = Settings::NotificationsController.new
    @controller.action_name = "show"

    assert_not show_bottom_tabbar?, "설정 알림 페이지에서는 탭바가 표시되지 않아야 함"
  end

  test "show_bottom_tabbar returns false for dashboard" do
    # 로그인 상태 시뮬레이션
    @logged_in = true

    # HomeController (대시보드) 시뮬레이션
    controller = ActionController::Base.new
    def controller.controller_name
      "home"
    end
    def controller.action_name
      "index"
    end
    def controller.controller_path
      "home"
    end
    @controller = controller

    assert_not show_bottom_tabbar?, "대시보드에서는 탭바가 표시되지 않아야 함"
  end

  test "show_bottom_tabbar returns true for general pages when logged in" do
    # 로그인 상태 시뮬레이션
    @logged_in = true

    # 일반 페이지 컨트롤러 시뮬레이션
    controller = ActionController::Base.new
    def controller.controller_name
      "photos"
    end
    def controller.action_name
      "index"
    end
    def controller.controller_path
      "photos"
    end
    @controller = controller

    assert show_bottom_tabbar?, "일반 페이지에서는 로그인 시 탭바가 표시되어야 함"
  end

  test "show_bottom_tabbar returns false when not logged in" do
    # 로그아웃 상태 시뮬레이션
    @logged_in = false

    assert_not show_bottom_tabbar?, "로그인하지 않았을 때는 탭바가 표시되지 않아야 함"
  end

  test "unread_notifications_count returns correct count" do
    user = users(:mom)
    @current_user = user
    family = families(:kim_family)

    # 읽지 않은 알림 3개 생성 (동적으로 사진 생성)
    # 주의: fixture에 이미 1개의 unread_notification이 있음
    3.times do |i|
      photo = family.photos.create!(
        uploader: users(:dad),
        taken_at: Time.current - i.days
      )
      photo.image.attach(
        io: File.open(Rails.root.join("test/fixtures/files/photo.jpg")),
        filename: "photo_#{i}.jpg",
        content_type: "image/jpeg"
      )

      reaction = Reaction.create!(photo: photo, user: users(:dad), emoji: "❤️")
      Notification.create!(
        recipient: user,
        actor: users(:dad),
        notifiable: reaction,
        notification_type: "reaction_created"
      )
    end

    assert_equal 4, unread_notifications_count(user)  # 3 + 1(fixture) = 4
  end

  test "unread_notifications_count returns 0 when no notifications" do
    user = users(:uncle)
    @current_user = user

    assert_equal 0, unread_notifications_count(user)
  end

  test "unread_notifications_count uses current_user by default" do
    user = users(:mom)
    @current_user = user
    family = families(:kim_family)

    # 읽지 않은 알림 2개 생성 (동적으로 사진 생성)
    # 주의: fixture에 이미 1개의 unread_notification이 있음
    2.times do |i|
      photo = family.photos.create!(
        uploader: users(:dad),
        taken_at: Time.current - i.days
      )
      photo.image.attach(
        io: File.open(Rails.root.join("test/fixtures/files/photo.jpg")),
        filename: "photo_default_#{i}.jpg",
        content_type: "image/jpeg"
      )

      reaction = Reaction.create!(photo: photo, user: users(:dad), emoji: "👍")
      Notification.create!(
        recipient: user,
        actor: users(:dad),
        notifiable: reaction,
        notification_type: "reaction_created"
      )
    end

    assert_equal 3, unread_notifications_count  # 2 + 1(fixture) = 3
  end
end
