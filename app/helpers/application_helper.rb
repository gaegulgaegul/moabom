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
  def show_bottom_tabbar?
    # Debug logging for CI
    if Rails.env.test?
      Rails.logger.info "=== show_bottom_tabbar? DEBUG ==="
      Rails.logger.info "logged_in?: #{logged_in?}"
      Rails.logger.info "controller_name: #{controller_name}"
      Rails.logger.info "action_name: #{action_name}"
      Rails.logger.info "controller_path: #{controller_path}"
    end

    # 로그인하지 않은 경우 탭바 미표시
    unless logged_in?
      Rails.logger.info "Returning false: not logged in" if Rails.env.test?
      return false
    end

    # 대시보드(홈)에서는 탭바 제거
    if controller_name == "home" && action_name == "index"
      Rails.logger.info "Returning false: home#index" if Rails.env.test?
      return false
    end

    # 온보딩 페이지에서는 탭바 미표시
    if controller_path.start_with?("onboarding/")
      Rails.logger.info "Returning false: onboarding page" if Rails.env.test?
      return false
    end

    # 세션 페이지에서는 탭바 미표시
    if controller_name == "sessions"
      Rails.logger.info "Returning false: sessions controller" if Rails.env.test?
      return false
    end

    Rails.logger.info "Returning true: should show tabbar" if Rails.env.test?
    true
  end
end
