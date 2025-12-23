# frozen_string_literal: true

module Onboarding
  class InvitesController < ApplicationController
    before_action :authenticate_user!
    skip_before_action :check_onboarding

    def show
      @family = current_family
      unless @family
        redirect_to root_path, alert: "가족을 찾을 수 없습니다. 먼저 프로필을 완성해주세요."
        return
      end

      @invitation = find_or_create_invitation
      @invite_url = accept_invitation_url(@invitation.token)
    end

    def complete
      @family = current_family
      unless @family
        redirect_to root_path, alert: "가족을 찾을 수 없습니다."
        return
      end

      # 가족과 사용자 온보딩 둘 다 완료 처리
      @family.complete_onboarding!
      current_user.complete_onboarding! unless current_user.onboarding_completed?

      redirect_to root_path, notice: "온보딩이 완료되었습니다. 환영합니다!"
    end

    private

    def find_or_create_invitation
      @family.invitations.active.first || @family.invitations.create!(
        inviter: current_user,
        role: :member
      )
    end
  end
end
