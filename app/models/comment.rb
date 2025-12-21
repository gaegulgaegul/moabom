# frozen_string_literal: true

class Comment < ApplicationRecord
  MAX_BODY_LENGTH = 1000

  belongs_to :photo
  belongs_to :user
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :body, presence: true
  validates :body, length: { maximum: MAX_BODY_LENGTH }
end
