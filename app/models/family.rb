# frozen_string_literal: true

class Family < ApplicationRecord
  has_many :family_memberships, dependent: :destroy
  has_many :users, through: :family_memberships
  has_many :children, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :invitations, dependent: :destroy

  validates :name, presence: true

  def onboarding_completed?
    onboarding_completed_at.present?
  end

  def complete_onboarding!
    update!(onboarding_completed_at: Time.current)
  end
end
