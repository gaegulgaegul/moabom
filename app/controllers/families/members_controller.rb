# frozen_string_literal: true

module Families
  class MembersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_onboarding!
    before_action :set_family
    before_action :set_membership, only: [ :update, :destroy ]
    before_action :authorize_manage!, only: [ :update, :destroy ]

    def index
      @memberships = @family.family_memberships.includes(:user)
    end

    def update
      if @membership.user == current_user
        redirect_to family_members_path(@family), alert: "자신의 역할은 변경할 수 없습니다."
        return
      end

      if @membership.role_owner?
        redirect_to family_members_path(@family), alert: "소유자의 역할은 변경할 수 없습니다."
        return
      end

      new_role = validate_role_param
      unless new_role
        redirect_to family_members_path(@family), alert: "유효하지 않은 역할입니다."
        return
      end

      if @membership.update(role: new_role)
        redirect_to family_members_path(@family), notice: "역할이 변경되었습니다."
      else
        redirect_to family_members_path(@family), alert: "역할 변경에 실패했습니다."
      end
    end

    def destroy
      if @membership.user == current_user
        redirect_to family_members_path(@family), alert: "자신은 내보낼 수 없습니다."
        return
      end

      @membership.destroy
      redirect_to family_members_path(@family), notice: "구성원이 제거되었습니다."
    end

    private

    def set_family
      @family = current_user.families.find_by(id: params[:family_id])
      redirect_to root_path, alert: "접근 권한이 없습니다." unless @family
    end

    def set_membership
      @membership = @family.family_memberships.find(params[:id])
    end

    def authorize_manage!
      my_membership = current_user.family_memberships.find_by(family: @family)
      return if my_membership&.role_owner? || my_membership&.role_admin?

      redirect_to family_members_path(@family), alert: "권한이 없습니다."
    end

    # role 파라미터 검증 - owner는 변경 불가, 허용된 역할만 설정 가능
    def validate_role_param
      role_param = params.require(:family_membership)[:role]
      return nil unless role_param

      # 허용된 역할 목록 (owner 제외)
      allowed_roles = %w[viewer member admin]
      return nil unless allowed_roles.include?(role_param)

      # owner는 admin만 부여 가능
      my_membership = current_user.family_memberships.find_by(family: @family)
      if role_param == "admin" && !my_membership&.role_owner?
        return nil
      end

      role_param
    end
  end
end
