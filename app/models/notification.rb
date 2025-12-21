class Notification < ApplicationRecord
  # 연관관계
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User"
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
    case notification_type
    when "reaction_created"
      "#{actor.nickname}님이 사진에 반응을 남겼습니다"
    when "comment_created"
      "#{actor.nickname}님이 댓글을 남겼습니다"
    else
      "새로운 알림이 있습니다"
    end
  end
end
