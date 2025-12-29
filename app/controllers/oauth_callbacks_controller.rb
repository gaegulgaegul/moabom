# frozen_string_literal: true

# OauthCallbacksController
#
# 역할: OAuth 인증 콜백 처리
#
# 주요 기능:
# - 카카오/애플/구글 OAuth 콜백 처리 (create)
# - 사용자 생성 또는 로그인
# - 인증 실패 처리 (failure)
#
# 연관 클래스: User
class OauthCallbacksController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_from_oauth(auth)

    if user.persisted?
      session[:user_id] = user.id
      redirect_to root_path, notice: "로그인되었습니다."
    else
      redirect_to root_path, alert: "로그인에 실패했습니다."
    end
  end

  def failure
    redirect_to root_path, alert: "로그인에 실패했습니다."
  end
end
