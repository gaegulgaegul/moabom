# frozen_string_literal: true

module Families
  # Families::ChildrenController
  #
  # 역할: 가족 내 아이 프로필 CRUD
  #
  # 주요 기능:
  # - 아이 목록 조회 (index)
  # - 아이 상세 정보 조회 (show)
  # - 아이 등록/수정/삭제 (create, update, destroy) - owner/admin만 가능
  # - 이름, 생년월일, 성별 정보 관리
  #
  # 연관 클래스: Child, Family, FamilyMembership
  class ChildrenController < ApplicationController
    before_action :authenticate_user!
    before_action :require_onboarding!
    before_action :set_family
    before_action :set_child, only: [ :show, :edit, :update, :destroy ]
    before_action :authorize_manage!, only: [ :new, :create, :edit, :update, :destroy ]

    def index
      @children = @family.children.includes(:photos)
    end

    def show
    end

    def new
      @child = @family.children.build
    end

    def create
      @child = @family.children.build(child_params)

      if @child.save
        redirect_to family_children_path(@family), notice: "아이가 등록되었습니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @child.update(child_params)
        redirect_to family_children_path(@family), notice: "아이 정보가 수정되었습니다."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @child.destroy
      redirect_to family_children_path(@family), notice: "아이가 삭제되었습니다."
    end

    private

    def set_family
      @family = current_user.families.find_by(id: params[:family_id])
      redirect_to root_path, alert: "접근 권한이 없습니다." unless @family
    end

    def set_child
      @child = @family.children.find(params[:id])
    end

    def authorize_manage!
      membership = current_user.family_memberships.find_by(family: @family)
      return if membership&.role_owner? || membership&.role_admin?

      redirect_to family_children_path(@family), alert: "권한이 없습니다."
    end

    def child_params
      params.require(:child).permit(:name, :birthdate, :gender)
    end
  end
end
