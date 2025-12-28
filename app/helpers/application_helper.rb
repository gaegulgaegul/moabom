# frozen_string_literal: true

module ApplicationHelper
  include LucideRails::RailsHelper
  def can_manage_members?
    return false unless current_user && @family

    membership = current_user.family_memberships.find_by(family: @family)
    membership&.role_owner? || membership&.role_admin?
  end

  # Wave 6: Phase 1 - 읽지 않은 알림 개수
  def unread_notifications_count(user = current_user)
    return 0 unless user

    user.notifications.unread.count
  end
end
