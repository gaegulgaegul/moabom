# frozen_string_literal: true

# Family
#
# 역할: 가족 그룹을 관리하는 Aggregate Root 모델
#
# 주요 기능:
# - 가족 그룹 생성 및 관리
# - 구성원(FamilyMembership) 관리
# - 아이(Children) 프로필 관리
# - 사진(Photos) 타임라인 관리
# - 초대(Invitations) 관리
# - 온보딩 상태 관리 (Onboardable concern)
#
# 연관 클래스: User (through FamilyMembership), Child, Photo, Invitation
#
# @!attribute [rw] name
#   @return [String] 가족 그룹 이름
# @!attribute [rw] onboarding_completed_at
#   @return [DateTime] 온보딩 완료 시각
class Family < ApplicationRecord
  include Onboardable

  has_many :family_memberships, dependent: :destroy
  has_many :users, through: :family_memberships
  has_many :children, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :invitations, dependent: :destroy

  validates :name, presence: true
end
