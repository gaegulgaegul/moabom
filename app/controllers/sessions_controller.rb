# frozen_string_literal: true

class SessionsController < ApplicationController
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
end
