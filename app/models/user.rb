# frozen_string_literal: true

class User < ApplicationRecord
  has_many :family_memberships, dependent: :destroy
  has_many :families, through: :family_memberships

  validates :email, presence: true
  validates :nickname, presence: true
  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

  def self.find_or_create_from_oauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.nickname = auth.info.nickname || auth.info.name
      user.avatar_url = auth.info.image
    end
  end

  def onboarding_completed?
    onboarding_completed_at.present?
  end

  def complete_onboarding!
    update!(onboarding_completed_at: Time.current)
  end
end
