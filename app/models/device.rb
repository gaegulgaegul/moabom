# frozen_string_literal: true

# Device
#
# 역할: 모바일 디바이스 정보 및 푸시 토큰을 관리하는 모델
#
# 주요 기능:
# - 디바이스 등록 및 푸시 토큰 저장 (iOS, Android)
# - 디바이스별 고유성 보장 (user_id + device_id)
# - 마지막 활동 시간 추적
# - 푸시 알림 발송용 토큰 관리
#
# 연관 클래스: User
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
