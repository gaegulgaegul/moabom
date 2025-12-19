# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Global error handlers
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from ActionController::InvalidAuthenticityToken, with: :unprocessable_entity
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :json_parse_error

  before_action :check_onboarding

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.includes(:families).find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_family
    return @current_family if defined?(@current_family)

    # Family selection strategy:
    # 1. Use params[:family_id] when present (explicit family context)
    # 2. Fall back to user's first family (default for single-family users)
    # This assumes single-family-per-user for MVP; for multi-family support,
    # consider adding a user.default_family_id column or session[:current_family_id]
    @current_family = if params[:family_id].present?
      current_user&.families&.find_by(id: params[:family_id])
    else
      current_user&.families&.first
    end
  end

  def logged_in?
    current_user.present?
  end

  def authenticate_user!
    return if logged_in?

    redirect_to root_path, alert: "로그인이 필요합니다."
  end

  def require_onboarding!
    return unless logged_in?
    return if current_user.onboarding_completed?

    redirect_to onboarding_profile_path, alert: "온보딩을 완료해주세요."
  end

  def check_onboarding
    return unless logged_in?
    return if controller_name == "sessions" || controller_path.start_with?("onboarding/")
    return unless current_family # 가족이 없으면 체크 안함
    return unless current_user.owner_of?(current_family) # 가족 소유자만 온보딩 체크
    return if current_family.onboarding_completed?

    redirect_to onboarding_profile_path
  end

  helper_method :current_user, :current_family, :logged_in?

  # Error handlers
  def not_found
    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found, layout: "error" }
      format.json { render json: { error: { code: "not_found", message: "리소스를 찾을 수 없습니다." } }, status: :not_found }
    end
  end

  def bad_request(exception = nil)
    message = exception&.message || "잘못된 요청입니다."
    respond_to do |format|
      format.html { render "errors/bad_request", status: :bad_request, layout: "error" }
      format.json { render json: { error: { code: "bad_request", message: message } }, status: :bad_request }
    end
  end

  def unprocessable_entity
    respond_to do |format|
      format.html { redirect_to root_path, alert: "세션이 만료되었습니다. 다시 시도해주세요." }
      format.json { render json: { error: { code: "unprocessable_entity", message: "요청을 처리할 수 없습니다." } }, status: :unprocessable_entity }
    end
  end

  def json_parse_error
    render json: {
      error: {
        code: "bad_request",
        message: "잘못된 JSON 형식입니다. 요청 데이터를 확인해주세요."
      }
    }, status: :bad_request
  end
end
