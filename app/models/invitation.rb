# frozen_string_literal: true

# Invitation
#
# 역할: 가족 초대 링크를 관리하는 모델
#
# 주요 기능:
# - 가족 초대 토큰 생성 (SecureRandom)
# - 초대 만료 시간 관리 (기본 7일)
# - 초대 역할 설정 (viewer, member, admin)
# - 활성 초대 조회 (만료되지 않은 초대)
#
# 연관 클래스: Family, User (inviter)
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
