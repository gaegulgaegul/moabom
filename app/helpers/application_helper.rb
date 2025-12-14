# frozen_string_literal: true

module ApplicationHelper
  def can_manage_members?
    return false unless current_user && @family

    membership = current_user.family_memberships.find_by(family: @family)
    membership&.role_owner? || membership&.role_admin?
  end
end
