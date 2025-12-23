# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_onboarding!

  def index
    @notifications = current_user.notifications.recent.includes(:actor, notifiable: :photo)
  end

  def update
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!

    # 알림 대상으로 리다이렉트
    redirect_to notification_target_path(@notification)
  end

  private

  def notification_target_path(notification)
    case notification.notifiable
    when Reaction, Comment
      family_photo_path(
        notification.notifiable.photo.family,
        notification.notifiable.photo
      )
    else
      notifications_path
    end
  end
end
