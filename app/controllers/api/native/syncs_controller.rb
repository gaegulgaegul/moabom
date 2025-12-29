# frozen_string_literal: true

module Api
  module Native
    # Api::Native::SyncsController
    #
    # 역할: 모바일 앱 초기 데이터 동기화 API
    #
    # 주요 기능:
    # - 사용자/가족/아이 데이터 한번에 조회 (show)
    # - 앱 시작 시 또는 백그라운드 복귀 시 호출
    # - 가족 멤버 목록 포함
    #
    # 연관 클래스: User, Family, FamilyMembership, Child
    class SyncsController < Api::BaseController
      def show
        render json: {
          user: user_data,
          families: families_data,
          children: children_data
        }
      end

      private

      def user_data
        {
          id: current_user.id,
          email: current_user.email,
          nickname: current_user.nickname,
          avatar_url: current_user.avatar_url
        }
      end

      def families_data
        current_user.families.includes(:family_memberships, :users).map do |family|
          {
            id: family.id,
            name: family.name,
            members: family_members_data(family)
          }
        end
      end

      def family_members_data(family)
        family.family_memberships.includes(:user).map do |membership|
          {
            id: membership.user.id,
            nickname: membership.user.nickname,
            avatar_url: membership.user.avatar_url,
            role: membership.role
          }
        end
      end

      def children_data
        current_user.families.flat_map do |family|
          family.children.map do |child|
            {
              id: child.id,
              family_id: child.family_id,
              name: child.name,
              birthdate: child.birthdate,
              gender: child.gender
            }
          end
        end
      end
    end
  end
end
