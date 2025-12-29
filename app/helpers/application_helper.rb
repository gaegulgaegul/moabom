# frozen_string_literal: true

# ApplicationHelper
#
# 역할: 전역 뷰 헬퍼 메서드 모음
#
# 주요 기능:
# - 가족 구성원 관리 권한 확인 (can_manage_members?)
# - 읽지 않은 알림 개수 조회 (unread_notifications_count)
# - 상대 날짜 표시 (relative_date) - 오늘, 어제, n일 전
# - Lucide 아이콘 헬퍼 포함 (LucideRails::RailsHelper)
#
# 연관 클래스: User, Family, FamilyMembership, Notification
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
