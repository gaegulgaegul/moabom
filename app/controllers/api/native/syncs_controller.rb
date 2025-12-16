# frozen_string_literal: true

module Api
  module Native
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
