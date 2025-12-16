# frozen_string_literal: true

class Invitation < ApplicationRecord
  belongs_to :family
  belongs_to :inviter, class_name: "User"

  enum :role, { viewer: 0, member: 1, admin: 2 }

  before_create :generate_token
  before_create :set_default_expires_at

  scope :active, -> { where("expires_at > ?", Time.current) }

  def expired?
    expires_at <= Time.current
  end

  private

  def generate_token
    self.token = SecureRandom.hex(16)
  end

  def set_default_expires_at
    self.expires_at ||= 7.days.from_now
  end
end
