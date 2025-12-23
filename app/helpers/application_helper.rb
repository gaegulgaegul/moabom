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
      controller_name == "notifications"
    when :settings
      controller.class.module_parent_name == "Settings"
    else
      false
    end ? "text-pink-500" : "text-gray-600"
  end

  # Wave 5: Phase 2 - 대시보드에서는 탭바 숨김
  # Wave 5: Phase 5 - 설정 페이지에서는 탭바 숨김
  def show_bottom_tabbar?
    return false unless logged_in?
    return false if controller_name == "home" && action_name == "index"
    return false if controller_path.start_with?("onboarding/")
    return false if controller_path.start_with?("settings/")
    return false if controller_name == "sessions"
    true
  end

  # Wave 6: Phase 1 - 읽지 않은 알림 개수
  def unread_notifications_count(user = current_user)
    return 0 unless user

    user.notifications.unread.count
  end
end
