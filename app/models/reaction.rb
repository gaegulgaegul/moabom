# frozen_string_literal: true

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

  validates :emoji, presence: true
  validates :user_id, uniqueness: { scope: :photo_id }
end
