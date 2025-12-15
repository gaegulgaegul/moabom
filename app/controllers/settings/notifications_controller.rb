# frozen_string_literal: true

module Settings
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
