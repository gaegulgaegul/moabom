# frozen_string_literal: true

# NotificationService
#
# 역할: 인앱 알림 생성 서비스
#
# 주요 기능:
# - 반응 알림 생성 (notify_reaction_created) - 사진 업로더에게 알림
# - 댓글 알림 생성 (notify_comment_created) - 사진 업로더에게 알림
# - 본인 액션에 대한 알림 제외
# - 반응 알림 중복 방지 (동일 사용자의 반복 반응)
#
# 연관 클래스: Notification, Reaction, Comment, Photo, User
class NotificationService
  class << self
    def notify_reaction_created(reaction)
      photo = reaction.photo
      recipient = photo.uploader
      actor = reaction.user

      # 본인이 남긴 반응에는 알림 생성 안 함
      return if recipient == actor

      # 기존 알림 확인 (중복 방지)
      existing = Notification.find_by(
        recipient: recipient,
        actor: actor,
        notifiable: reaction,
        notification_type: "reaction_created"
      )
      return if existing

      Notification.create!(
        recipient: recipient,
        actor: actor,
        notifiable: reaction,
        notification_type: "reaction_created"
      )
    end

    def notify_comment_created(comment)
      photo = comment.photo
      recipient = photo.uploader
      actor = comment.user

      # 본인이 남긴 댓글에는 알림 생성 안 함
      return if recipient == actor

      Notification.create!(
        recipient: recipient,
        actor: actor,
        notifiable: comment,
        notification_type: "comment_created"
      )
    end
  end
end
