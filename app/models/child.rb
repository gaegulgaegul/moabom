# frozen_string_literal: true

# Child
#
# 역할: 아이 프로필 정보를 관리하는 모델
#
# 주요 기능:
# - 아이의 기본 정보 관리 (이름, 생년월일, 성별)
# - 프로필 사진 첨부 및 썸네일 생성
# - 나이 계산 메서드 제공 (월령, 연령, 일령)
# - 사진과의 연관 관계 관리 (태그)
#
# 연관 클래스: Family, Photo
#
# @!attribute [rw] name
#   @return [String] 아이 이름
# @!attribute [rw] birthdate
#   @return [Date] 생년월일
# @!attribute [rw] gender
#   @return [Integer] 성별 (0: male, 1: female)
class Child < ApplicationRecord
  belongs_to :family
  has_many :photos, dependent: :nullify
  has_one_attached :profile_photo do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [ 100, 100 ]
  end

  enum :gender, { male: 0, female: 1 }

  validates :name, presence: true
  validates :birthdate, presence: true

  def age_in_months
    months = (Date.current.year - birthdate.year) * 12
    months += Date.current.month - birthdate.month
    months -= 1 if Date.current.day < birthdate.day
    months
  end

  def age_in_years
    age_in_months / 12
  end

  def age_string
    years = age_in_years
    months = age_in_months % 12

    if years.zero?
      "#{age_in_months}개월"
    else
      "#{years}년 #{months}개월"
    end
  end

  def days_since_birth
    (Date.current - birthdate).to_i
  end
end
