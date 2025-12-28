# frozen_string_literal: true

require "application_system_test_case"

module Families
  class MembersTest < ApplicationSystemTestCase
    setup do
      @mom = users(:mom)
      @dad = users(:dad)
      @grandma = users(:grandma)
      @uncle = users(:uncle)
      @family = families(:kim_family)
    end

    test "owner can view family members list" do
      sign_in @mom

      visit family_members_path(@family)

      # 페이지 제목 확인
      assert_selector "h1", text: "가족 구성원"

      # 구성원 목록 확인
      assert_text @mom.nickname
      assert_text @mom.email
      assert_text "관리자" # owner는 관리자로 표시

      assert_text @dad.nickname
      assert_text @dad.email

      assert_text @grandma.nickname
      assert_text @grandma.email
      assert_text "구성원" # viewer는 구성원으로 표시

      assert_text @uncle.nickname
      assert_text @uncle.email
    end

    test "displays avatar with Sketch AvatarComponent" do
      sign_in @mom

      visit family_members_path(@family)

      # Sketch AvatarComponent 확인 - 아바타 스타일 클래스 확인
      assert_selector ".rounded-full"
    end

    test "owner can see action menu for other members" do
      sign_in @mom

      visit family_members_path(@family)

      # 다른 구성원에 대한 액션 메뉴 확인 - aria-label로 버튼 찾기
      assert_selector "button[aria-label='#{@dad.nickname} 관리']"

      # 자신에 대한 액션 메뉴 없음
      assert_no_selector "button[aria-label='#{@mom.nickname} 관리']"
    end

    test "displays correct badge for roles" do
      sign_in @mom

      visit family_members_path(@family)

      # Sketch BadgeComponent 확인
      assert_text "관리자"
      assert_text "구성원"
    end

    test "Sketch CardComponent is used" do
      sign_in @mom

      visit family_members_path(@family)

      # Sketch CardComponent 클래스 확인
      assert_selector ".bg-sketch-paper.border-2"
    end

    test "members are displayed in a divided list" do
      sign_in @mom

      visit family_members_path(@family)

      # divide 클래스로 구분선 확인
      assert_selector ".divide-y-2"
    end

    test "unauthorized user cannot access members page" do
      other_user = users(:other_family_user)
      # lee_family에 멤버십 생성 (kim_family 접근 불가 테스트용)
      lee_family = families(:lee_family)
      lee_family.family_memberships.create!(user: other_user, role: :member)
      lee_family.complete_onboarding!
      sign_in other_user

      visit family_members_path(@family)

      # 리다이렉트 및 에러 메시지 확인
      assert_current_path root_path
      assert_text "접근 권한이 없습니다."
    end

    test "viewer can view members but cannot manage" do
      sign_in @grandma # viewer 역할

      visit family_members_path(@family)

      # 목록 볼 수 있음
      assert_text @mom.nickname
      assert_text @dad.nickname

      # 액션 메뉴 없음 - aria-label에 "관리"가 포함된 버튼이 없어야 함
      @family.family_memberships.each do |membership|
        next if membership.user == @grandma # 자기 자신은 제외
        assert_no_selector "button[aria-label*='관리']"
      end
    end

    test "admin can see action menus" do
      sign_in @dad # admin 역할

      visit family_members_path(@family)

      # 다른 구성원에 대한 액션 메뉴 확인
      assert_selector "button[aria-label='#{@grandma.nickname} 관리']"
    end
  end
end
