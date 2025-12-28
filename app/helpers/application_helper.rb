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

  # 상대 날짜 표시 (오늘, 어제, n일 전, 날짜)
  def relative_date(date)
    today = Date.current
    days_ago = (today - date).to_i

    case days_ago
    when 0
      "오늘"
    when 1
      "어제"
    when 2..6
      "#{days_ago}일 전"
    else
      I18n.l(date, format: :long)
    end
  end
end
