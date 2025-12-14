# frozen_string_literal: true

class Photo < ApplicationRecord
  belongs_to :family
  belongs_to :uploader, class_name: "User"
  belongs_to :child, optional: true

  has_many :reactions, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_one_attached :image

  validates :taken_at, presence: true
  validates :image, presence: true

  scope :recent, -> { order(taken_at: :desc) }
  scope :by_month, ->(year, month) {
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    where(taken_at: start_date.beginning_of_day..end_date.end_of_day)
  }
end
