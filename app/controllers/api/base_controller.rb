# frozen_string_literal: true

module Api
  class BaseController < ActionController::Base
    # Skip CSRF protection for API endpoints
    skip_before_action :verify_authenticity_token

    before_action :authenticate_user!

    private

    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def authenticate_user!
      return if current_user

      render json: { error: { code: "unauthorized", message: "인증이 필요합니다." } }, status: :unauthorized
    end
  end
end
