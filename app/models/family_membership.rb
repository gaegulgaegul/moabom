# frozen_string_literal: true

class FamilyMembership < ApplicationRecord
  belongs_to :user
  belongs_to :family

  enum :role, { viewer: 0, member: 1, admin: 2, owner: 3 }, prefix: true

  validates :user_id, uniqueness: { scope: :family_id }
end
