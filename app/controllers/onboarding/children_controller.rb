# frozen_string_literal: true

module Onboarding
  # Onboarding::ChildrenController
  #
  # 역할: 온보딩 2단계 - 가족 생성 및 첫 아이 등록
  #
  # 주요 기능:
  # - 아이 등록 폼 표시 (show)
  # - 트랜잭션으로 가족 생성 + 아이 등록 + 온보딩 완료 처리 (create)
  # - 가족 생성 시 현재 사용자를 owner로 설정
  #
  # 연관 클래스: Family, Child, FamilyMembership, User
  class ChildrenController < ApplicationController
    before_action :authenticate_user!
    skip_before_action :check_onboarding

    def show
      @child = Child.new
    end

    def create
      ActiveRecord::Base.transaction do
        @family = create_family
        @child = create_child

        if @child.valid?
          @child.save!
          # 아이 추가 시 가족 온보딩 자동 완료 처리
          @family.complete_onboarding!
          current_user.complete_onboarding! unless current_user.onboarding_completed?
          redirect_to onboarding_invite_path
        else
          raise ActiveRecord::Rollback
        end
      end

      render :show, status: :unprocessable_entity unless performed?
    end

    private

    def create_family
      family = Family.create!(name: "#{current_user.nickname}의 가족")
      family.family_memberships.create!(user: current_user, role: :owner)
      family
    end

    def create_child
      @family.children.build(child_params)
    end

    def child_params
      params.require(:child).permit(:name, :birthdate, :gender)
    end
  end
end
