# frozen_string_literal: true

class FamilyMembership < ApplicationRecord
  belongs_to :user
  belongs_to :family

  enum :role, { viewer: 0, member: 1, admin: 2, owner: 3 }, prefix: true

  validates :user_id, uniqueness: { scope: :family_id }

  # 관리자 또는 소유자 여부
  def admin_or_owner?
    role_admin? || role_owner?
  end

  # 사진 업로드 권한 (member 이상)
  def can_upload?
    role_member? || admin_or_owner?
  end

  # 사진 삭제 권한 (본인이 업로드하거나, admin/owner)
  def can_delete_photo?(photo)
    photo.uploader == user || admin_or_owner?
  end
end
