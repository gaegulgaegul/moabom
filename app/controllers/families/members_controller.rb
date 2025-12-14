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

      if @membership.update(membership_params)
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

    def membership_params
      params.require(:family_membership).permit(:role)
    end
  end
end
