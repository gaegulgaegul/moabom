# frozen_string_literal: true

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
