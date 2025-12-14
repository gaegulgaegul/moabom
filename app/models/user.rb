# frozen_string_literal: true

class User < ApplicationRecord
  has_many :family_memberships, dependent: :destroy
  has_many :families, through: :family_memberships

  validates :email, presence: true
  validates :nickname, presence: true
  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }
end
