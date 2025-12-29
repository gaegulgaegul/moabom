# frozen_string_literal: true

# Onboardable
#
# 역할: 온보딩 완료 상태를 관리하는 Concern 모듈
#
# 주요 기능:
# - 온보딩 완료 여부 확인 메서드 제공
# - 온보딩 완료 처리 (complete_onboarding!)
# - 온보딩 완료/미완료 스코프 제공
#
# 사용 클래스: Family, User에서 include
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
