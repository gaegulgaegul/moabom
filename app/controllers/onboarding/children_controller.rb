# frozen_string_literal: true

module Onboarding
  class ChildrenController < ApplicationController
    before_action :authenticate_user!

    def show
      @child = Child.new
    end

    def create
      ActiveRecord::Base.transaction do
        @family = create_family
        @child = create_child

        if @child.valid?
          @child.save!
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
