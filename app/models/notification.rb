# frozen_string_literal: true

class Notification < ApplicationRecord
  # 연관관계
  belongs_to :recipient, class_name: "User", inverse_of: :notifications
  belongs_to :actor, class_name: "User", inverse_of: :sent_notifications
  belongs_to :notifiable, polymorphic: true

  # Validations
  validates :notification_type, presence: true
  validates :notification_type, inclusion: {
    in: %w[reaction_created comment_created],
    message: "%{value} is not a valid notification type"
  }

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # 인스턴스 메서드
  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def message
    key = case notification_type
    when "reaction_created"
            "notifications.messages.reaction_created"
    when "comment_created"
            "notifications.messages.comment_created"
    else
            "notifications.messages.default"
    end

    I18n.t(key, actor_nickname: actor.nickname, default: I18n.t("notifications.messages.default"))
  end
end
