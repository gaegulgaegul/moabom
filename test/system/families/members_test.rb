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
      assert_text "관리자" # admin도 관리자로 표시

      assert_text @grandma.nickname
      assert_text @grandma.email
      assert_text "구성원" # viewer는 구성원으로 표시

      assert_text @uncle.nickname
      assert_text @uncle.email
      assert_text "구성원" # member는 구성원으로 표시
    end

    test "displays avatar with first letter of nickname" do
      sign_in @mom

      visit family_members_path(@family)

      # 아바타 컴포넌트 확인
      within ".avatar", text: @mom.nickname.first do
        assert_selector ".text-primary-600"
      end
    end

    test "owner can see invite button" do
      sign_in @mom

      visit family_members_path(@family)

      # 초대 버튼 확인
      assert_link "가족 초대하기"
    end

    test "member cannot see invite button" do
      sign_in @uncle # member 역할

      visit family_members_path(@family)

      # 초대 버튼 없음
      assert_no_link "가족 초대하기"
    end

    test "owner can see action menu for other members" do
      sign_in @mom

      visit family_members_path(@family)

      # 다른 구성원에 대한 액션 메뉴 확인 (email로 행 찾기)
      within ".card-solid" do
        # 아빠 이메일을 찾아서 그 부모 행에서 버튼 확인
        dad_email = find("p.text-sm.text-warm-gray-500", text: @dad.email)
        dad_row = dad_email.ancestor(".flex.items-center.justify-between")
        within dad_row do
          assert_selector "button.p-2"
        end

        # 자신에 대한 액션 메뉴 없음
        mom_email = find("p.text-sm.text-warm-gray-500", text: @mom.email)
        mom_row = mom_email.ancestor(".flex.items-center.justify-between")
        within mom_row do
          assert_no_selector "button.p-2"
        end
      end
    end

    test "displays correct badge colors for roles" do
      sign_in @mom

      visit family_members_path(@family)

      within ".card-solid" do
        # admin 배지 (badge-primary)
        dad_email = find("p.text-sm.text-warm-gray-500", text: @dad.email)
        dad_row = dad_email.ancestor(".flex.items-center.justify-between")
        within dad_row do
          assert_selector ".badge-primary", text: "관리자"
        end

        # viewer 배지 (badge-secondary)
        grandma_email = find("p.text-sm.text-warm-gray-500", text: @grandma.email)
        grandma_row = grandma_email.ancestor(".flex.items-center.justify-between")
        within grandma_row do
          assert_selector ".badge-secondary", text: "구성원"
        end
      end
    end

    test "card-solid component is used" do
      sign_in @mom

      visit family_members_path(@family)

      # card-solid 클래스 확인
      assert_selector ".card-solid"
    end

    test "members are displayed in a divided list" do
      sign_in @mom

      visit family_members_path(@family)

      # divide-y 클래스로 구분선 확인
      assert_selector ".divide-y.divide-warm-gray-100"
    end

    test "unauthorized user cannot access members page" do
      other_user = users(:other_family_user)
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

      # 초대 버튼 없음
      assert_no_link "가족 초대하기"

      # 액션 메뉴 없음 (card-solid 내부에서만 확인)
      within ".card-solid" do
        assert_no_selector "button.p-2"
      end
    end

    test "admin can see invite button and action menus" do
      sign_in @dad # admin 역할

      visit family_members_path(@family)

      # 초대 버튼 확인
      assert_link "가족 초대하기"

      # 다른 구성원에 대한 액션 메뉴 확인
      within ".card-solid" do
        grandma_email = find("p.text-sm.text-warm-gray-500", text: @grandma.email)
        grandma_row = grandma_email.ancestor(".flex.items-center.justify-between")
        within grandma_row do
          assert_selector "button.p-2"
        end
      end
    end
  end
end
