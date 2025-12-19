# frozen_string_literal: true

class Family < ApplicationRecord
  include Onboardable

  has_many :family_memberships, dependent: :destroy
  has_many :users, through: :family_memberships
  has_many :children, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :invitations, dependent: :destroy

  validates :name, presence: true
end
