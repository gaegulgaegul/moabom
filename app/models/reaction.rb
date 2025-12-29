# frozen_string_literal: true

# Reaction
#
# 역할: 사진에 대한 이모지 반응을 관리하는 모델
#
# 주요 기능:
# - 사진에 이모지 반응 추가/삭제
# - 허용된 이모지 목록 관리 (❤️, 👍, 😊 등 8종)
# - 사용자당 사진 1개 반응 제한 (uniqueness 검증)
# - 반응 생성 시 알림 발송 연동
#
# 연관 클래스: Photo, User, Notification
class Reaction < ApplicationRecord
  # 허용된 이모지 목록
  ALLOWED_EMOJIS = %w[
    ❤️
    👍
    😊
    😍
    😂
    🎉
    👏
    🔥
  ].freeze

  belongs_to :photo
  belongs_to :user
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :emoji, presence: true
  validates :emoji, inclusion: { in: ALLOWED_EMOJIS }
  validates :user_id, uniqueness: { scope: :photo_id }
end
