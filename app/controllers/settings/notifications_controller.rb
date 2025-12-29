# frozen_string_literal: true

module Settings
  # Settings::NotificationsController
  #
  # 역할: 알림 설정 관리
  #
  # 주요 기능:
  # - 알림 설정 페이지 표시 (show)
  # - 알림 설정 수정 (update) - 새 사진/댓글/반응 알림 on/off
  #
  # 연관 클래스: User
  class NotificationsController < ApplicationController
    before_action :authenticate_user!

    def show
    end

    def update
      if current_user.update(notification_params)
        redirect_to settings_notifications_path, notice: t(".success")
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def notification_params
      params.require(:user).permit(:notify_on_new_photo, :notify_on_comment, :notify_on_reaction)
    end
  end
end
