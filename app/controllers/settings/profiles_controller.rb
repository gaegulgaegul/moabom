# frozen_string_literal: true

module Settings
  class ProfilesController < ApplicationController
    before_action :authenticate_user!

    def show
    end

    def update
      if current_user.update(profile_params)
        respond_to do |format|
          format.html { redirect_to settings_profile_path, notice: "프로필이 업데이트되었습니다." }
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
