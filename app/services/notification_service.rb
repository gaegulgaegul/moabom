# frozen_string_literal: true

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
