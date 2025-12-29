# frozen_string_literal: true

module Onboarding
  # Onboarding::ProfilesController
  #
  # 역할: 온보딩 1단계 - 사용자 프로필(닉네임) 설정
  #
  # 주요 기능:
  # - 닉네임 설정 폼 표시 (show)
  # - 닉네임 저장 후 아이 등록 단계로 이동 (update)
  # - 온보딩 체크 건너뛰기 (skip_before_action :check_onboarding)
  #
  # 연관 클래스: User, Onboarding::ChildrenController
  class ProfilesController < ApplicationController
    before_action :authenticate_user!
    skip_before_action :check_onboarding

    def show
    end

    def update
      if current_user.update(profile_params)
        redirect_to onboarding_child_path
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      params.require(:user).permit(:nickname)
    end
  end
end
