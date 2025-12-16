# frozen_string_literal: true

module Onboarding
  class ProfilesController < ApplicationController
    before_action :authenticate_user!

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
