# frozen_string_literal: true

class Reaction < ApplicationRecord
  belongs_to :photo
  belongs_to :user

  validates :emoji, presence: true
  validates :user_id, uniqueness: { scope: :photo_id }
end
