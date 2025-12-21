# frozen_string_literal: true

module ApplicationHelper
  include Heroicon::ApplicationHelper
  def can_manage_members?
    return false unless current_user && @family

    membership = current_user.family_memberships.find_by(family: @family)
    membership&.role_owner? || membership&.role_admin?
  end

  def current_page_tab?(tab_name)
    case tab_name
    when :home
      current_page?(root_path) || controller_path == "dashboard"
    when :albums
      false # 앨범 기능은 Phase 5에서 구현
    when :upload
      false # 업로드 기능은 Phase 4에서 구현
    when :notifications
      false # 알림 기능은 Phase 6에서 구현
    when :settings
      controller.class.module_parent_name == "Settings"
    else
      false
    end ? "text-pink-500" : "text-gray-600"
  end

  # Wave 5: Phase 2 - 대시보드에서는 탭바 숨김
  # Wave 5: Phase 5 - 설정 페이지에서는 탭바 숨김
  def show_bottom_tabbar?
    # 로그인하지 않은 경우 탭바 미표시
    return false unless logged_in?

    # 대시보드(홈)에서는 탭바 제거
    return false if controller_name == "home" && action_name == "index"

    # 온보딩 페이지에서는 탭바 미표시
    return false if controller_path.start_with?("onboarding/")

    # 설정 페이지에서는 탭바 미표시 (Wave 5 Phase 5)
    return false if controller_path.start_with?("settings/")

    # 세션 페이지에서는 탭바 미표시
    return false if controller_name == "sessions"

    true
  end
end
