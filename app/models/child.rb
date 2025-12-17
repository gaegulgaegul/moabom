# frozen_string_literal: true

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
