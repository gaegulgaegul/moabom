# frozen_string_literal: true

module Api
  class BaseController < ActionController::Base
    # Skip CSRF protection for API endpoints
    skip_before_action :verify_authenticity_token

    before_action :verify_origin
    before_action :authenticate_user!

    # Allowed origins for API requests
    ALLOWED_ORIGINS = [
      "capacitor://localhost", # Turbo Native iOS/Android
      %r{^http://localhost(:\d+)?$}, # Development (any port)
      %r{^http://127\.0\.0\.1(:\d+)?$} # Development (IP)
    ].freeze

    private

    def verify_origin
      origin = request.headers["Origin"]

      # Reject requests without Origin header
      unless origin.present?
        render json: {
          error: {
            code: "forbidden",
            message: "Origin 헤더가 필요합니다."
          }
        }, status: :forbidden
        return
      end

      # Check if origin is allowed
      allowed = ALLOWED_ORIGINS.any? do |allowed_origin|
        if allowed_origin.is_a?(Regexp)
          origin.match?(allowed_origin)
        else
          origin == allowed_origin
        end
      end

      unless allowed
        render json: {
          error: {
            code: "forbidden",
            message: "허용되지 않은 Origin입니다."
          }
        }, status: :forbidden
      end
    end

    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def authenticate_user!
      return if current_user

      render json: { error: { code: "unauthorized", message: "인증이 필요합니다." } }, status: :unauthorized
    end
  end
end
