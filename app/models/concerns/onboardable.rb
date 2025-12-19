# frozen_string_literal: true

module Onboardable
  extend ActiveSupport::Concern

  included do
    scope :onboarding_completed, -> { where.not(onboarding_completed_at: nil) }
    scope :onboarding_pending, -> { where(onboarding_completed_at: nil) }
  end

  def onboarding_completed?
    onboarding_completed_at.present?
  end

  def onboarding_pending?
    !onboarding_completed?
  end

  def complete_onboarding!
    update!(onboarding_completed_at: Time.current)
  end
end
