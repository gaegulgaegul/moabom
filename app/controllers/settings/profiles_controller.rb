# frozen_string_literal: true

module Settings
  class ProfilesController < ApplicationController
    before_action :authenticate_user!

    def show
    end

    def update
      if current_user.update(profile_params)
        redirect_to settings_profile_path, notice: "프로필이 업데이트되었습니다."
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
