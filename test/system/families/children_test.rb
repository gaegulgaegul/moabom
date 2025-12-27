# frozen_string_literal: true

require "application_system_test_case"

module Families
  class ChildrenTest < ApplicationSystemTestCase
    setup do
      @mom = users(:mom)
      @family = families(:kim_family)
    end

    test "shows empty state when no children" do
      # 모든 아이 삭제
      @family.children.destroy_all

      sign_in @mom
      visit family_children_path(@family)

      # 빈 상태 확인
      assert_selector ".empty-state"
      assert_selector "h3", text: "등록된 아이가 없어요"
      assert_text "아이를 등록하고 성장 기록을 시작하세요"
    end

    test "displays children list with profile photos" do
      sign_in @mom
      visit family_children_path(@family)

      # 페이지 제목 확인
      assert_selector "h1", text: "우리 아이들"

      # 아이 목록 확인 (fixtures에 아이가 있다고 가정)
      @family.children.each do |child|
        assert_text child.name
        assert_text child.birthdate.strftime("%Y.%m.%d")
      end
    end

    test "displays days since birth" do
      child = @family.children.first
      sign_in @mom

      visit family_children_path(@family)

      # D+일 표시 확인
      within ".card-glass", text: child.name do
        assert_text "D+"
      end
    end

    test "displays photo count" do
      child = @family.children.first
      sign_in @mom

      visit family_children_path(@family)

      # 사진 수 표시 확인
      within ".card-glass", text: child.name do
        assert_text "사진"
        assert_text "장"
      end
    end

    test "shows add child button for managers" do
      sign_in @mom # owner

      visit family_children_path(@family)

      # 아이 추가 버튼 확인
      assert_link "아이 추가하기"
    end

    test "hides add child button for viewers" do
      grandma = users(:grandma) # viewer
      sign_in grandma

      visit family_children_path(@family)

      # 아이 추가 버튼 없음
      assert_no_link "아이 추가하기"
    end

    test "child cards are clickable and link to edit page" do
      child = @family.children.first
      sign_in @mom

      visit family_children_path(@family)

      # 카드 자체가 링크인지 확인
      card_link = find("a.card-glass", text: child.name)
      expected_path = edit_family_child_path(@family, child)
      assert card_link[:href].end_with?(expected_path), "Expected href to end with #{expected_path}, but got #{card_link[:href]}"
    end

    test "displays profile photo icon when no photo attached" do
      child = @family.children.first
      sign_in @mom

      visit family_children_path(@family)

      # 프로필 사진이 없을 때 아이콘 표시
      within ".card-glass", text: child.name do
        # face-smile 아이콘 확인
        assert_selector "svg"
      end
    end

    test "uses card-glass component" do
      sign_in @mom
      visit family_children_path(@family)

      # card-glass 클래스 확인
      assert_selector ".card-glass"
    end

    test "displays chevron-right icon for navigation" do
      sign_in @mom
      visit family_children_path(@family)

      # chevron-right 아이콘 확인 (각 카드에)
      @family.children.each do |child|
        within ".card-glass", text: child.name do
          assert_selector "svg" # lucide chevron-right
        end
      end
    end

    test "unauthorized user cannot access children page" do
      other_user = users(:other_family_user)
      sign_in other_user

      visit family_children_path(@family)

      # 리다이렉트 및 에러 메시지 확인
      assert_current_path root_path
      assert_text "접근 권한이 없습니다."
    end
  end
end
