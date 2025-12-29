# frozen_string_literal: true

# FamilyMembership
#
# 역할: 사용자와 가족 간의 구성원 관계를 관리하는 조인 모델
#
# 주요 기능:
# - 사용자의 가족 그룹 멤버십 관리
# - 가족 내 역할 관리 (viewer, member, admin, owner)
# - 권한 확인 메서드 제공 (업로드 권한, 삭제 권한)
# - 사용자당 가족별 1개 멤버십 보장 (uniqueness 검증)
#
# 연관 클래스: User, Family
#
# @!attribute [rw] role
#   @return [Integer] 가족 내 역할 (0: viewer, 1: member, 2: admin, 3: owner)
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
