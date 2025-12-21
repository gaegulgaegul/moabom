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
end
