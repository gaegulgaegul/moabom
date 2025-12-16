# frozen_string_literal: true

class Device < ApplicationRecord
  belongs_to :user

  validates :platform, presence: true, inclusion: { in: %w[ios android] }
  validates :device_id, presence: true, uniqueness: { scope: :user_id }
  validates :push_token, uniqueness: true, allow_nil: true

  enum :platform, { ios: "ios", android: "android" }, validate: true

  def update_activity!
    update!(last_active_at: Time.current)
  end
end
