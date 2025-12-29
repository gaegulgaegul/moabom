# frozen_string_literal: true

# NotificationsController
#
# 역할: 사용자 알림 목록 조회 및 읽음 처리
#
# 주요 기능:
# - 알림 목록 조회 (index)
# - 알림 읽음 처리 및 해당 리소스로 이동 (update)
# - 알림 타입별 리다이렉트 경로 결정 (Reaction, Comment → 사진 상세)
#
# 연관 클래스: Notification, User, Reaction, Comment, Photo
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
