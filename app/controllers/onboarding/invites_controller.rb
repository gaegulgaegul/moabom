# frozen_string_literal: true

module Onboarding
  # Onboarding::InvitesController
  #
  # 역할: 온보딩 3단계 - 가족 초대 링크 생성 및 온보딩 완료
  #
  # 주요 기능:
  # - 초대 링크 표시 및 공유 (show) - 기존 활성 초대 재사용 또는 새로 생성
  # - 온보딩 완료 처리 (complete) - 가족/사용자 onboarding_completed 플래그 설정
  #
  # 연관 클래스: Family, Invitation, User
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
