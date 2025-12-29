# frozen_string_literal: true

# FamiliesController
#
# 역할: 가족 그룹 정보 조회 및 수정
#
# 주요 기능:
# - 가족 정보 조회 (show)
# - 가족 정보 수정 (update) - owner/admin만 가능
#
# 연관 클래스: Family, FamilyMembership
class FamiliesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_onboarding!
  before_action :set_family
  before_action :authorize_edit!, only: [ :update ]

  def show
  end

  def update
    if @family.update(family_params)
      redirect_to @family, notice: "가족 정보가 수정되었습니다."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_family
    @family = current_user.families.find_by(id: params[:id])
    redirect_to root_path, alert: "접근 권한이 없습니다." unless @family
  end

  def authorize_edit!
    membership = current_user.family_memberships.find_by(family: @family)
    return if membership&.role_owner? || membership&.role_admin?

    redirect_to @family, alert: "수정 권한이 없습니다."
  end

  def family_params
    params.require(:family).permit(:name)
  end
end
