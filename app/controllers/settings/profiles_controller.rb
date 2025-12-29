# frozen_string_literal: true

module Settings
  # Settings::ProfilesController
  #
  # 역할: 사용자 프로필 설정 관리
  #
  # 주요 기능:
  # - 프로필 설정 페이지 표시 (show)
  # - 닉네임 등 프로필 정보 수정 (update) - HTML/JSON 멀티포맷 응답
  #
  # 연관 클래스: User
  class ProfilesController < ApplicationController
    before_action :authenticate_user!

    def show
    end

    def update
      if current_user.update(profile_params)
        respond_to do |format|
          format.html { redirect_to settings_profile_path, notice: t(".success") }
          format.json { render json: current_user }
        end
      else
        respond_to do |format|
          format.html { render :show, status: :unprocessable_entity }
          format.json { render json: { errors: current_user.errors }, status: :unprocessable_entity }
        end
      end
    end

    private

    def profile_params
      params.require(:user).permit(:nickname)
    end
  end
end
