# frozen_string_literal: true

module FamilyAccessible
  extend ActiveSupport::Concern

  private

  def set_family
    @family = current_user.families.find_by(id: params[:family_id])
    redirect_to root_path, alert: "접근 권한이 없습니다." unless @family
  end
end
