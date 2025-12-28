# frozen_string_literal: true

class SessionsController < ApplicationController
  # Skip CSRF verification for test login endpoint
  skip_before_action :verify_authenticity_token, only: [ :create ], if: -> { Rails.env.test? }
  skip_before_action :check_onboarding, only: [ :new, :create, :destroy, :dev_login ]

  def new
    redirect_to root_path if logged_in?
  end

  # For testing purposes - allows direct login
  def create
    user = User.find_by(id: params[:user_id])

    if user
      session[:user_id] = user.id
      redirect_to root_path, notice: "로그인되었습니다."
    else
      redirect_to root_path, alert: "로그인에 실패했습니다."
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "로그아웃되었습니다."
  end

  # Development only - quick login without OAuth
  def dev_login
    unless Rails.env.development?
      redirect_to root_path, alert: "개발 환경에서만 사용 가능합니다."
      return
    end

    user = User.find_or_create_by!(provider: "dev", uid: "dev_user") do |u|
      u.email = "dev@example.com"
      u.nickname = "개발자"
    end

    # Ensure user has a family
    if user.families.empty?
      family = Family.create!(name: "#{user.nickname}의 가족")
      user.family_memberships.create!(family: family, role: :owner)
    end

    session[:user_id] = user.id
    redirect_to root_path, notice: "개발 모드로 진입했습니다."
  end
end
