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

      # 온보딩 완료 처리 (나중에 뷰의 버튼으로 이동 예정)
      @family.complete_onboarding! unless @family.onboarding_completed?
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
