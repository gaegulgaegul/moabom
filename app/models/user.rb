# frozen_string_literal: true

class User < ApplicationRecord
  # 닉네임 상수
  NICKNAME_REGEX = /\A[가-힣a-zA-Z0-9_]+\z/
  FORBIDDEN_NICKNAMES = %w[관리자 admin 운영자 moderator 시스템 system root].freeze
  MIN_NICKNAME_LENGTH = 2
  MAX_NICKNAME_LENGTH = 20

  # 아바타 상수
  AVATAR_MAX_SIZE = 5.megabytes
  AVATAR_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze

  has_many :family_memberships, dependent: :destroy
  has_many :families, through: :family_memberships
  has_many :devices, dependent: :destroy
  has_one_attached :avatar

  validates :email, presence: true
  validates :nickname, presence: true,
                       length: { in: MIN_NICKNAME_LENGTH..MAX_NICKNAME_LENGTH },
                       format: { with: NICKNAME_REGEX }
  validate :nickname_not_forbidden
  validate :acceptable_avatar

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

  def membership_for(family)
    family_memberships.find_by(family: family)
  end

  def role_for_family(family)
    membership_for(family)&.role
  end

  def owner_of?(family)
    membership_for(family)&.role_owner?
  end

  private

  def nickname_not_forbidden
    return if nickname.blank?

    if FORBIDDEN_NICKNAMES.include?(nickname.downcase)
      errors.add(:nickname, "사용할 수 없는 닉네임입니다")
    end
  end

  def acceptable_avatar
    return unless avatar.attached?

    unless AVATAR_CONTENT_TYPES.include?(avatar.content_type)
      errors.add(:avatar, "허용되지 않는 파일 형식입니다")
    end

    if avatar.blob.byte_size > AVATAR_MAX_SIZE
      errors.add(:avatar, "파일 크기가 5MB를 초과합니다")
    end
  end
end
