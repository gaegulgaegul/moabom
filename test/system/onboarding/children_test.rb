# frozen_string_literal: true

require "application_system_test_case"

module Onboarding
  class ChildrenTest < ApplicationSystemTestCase
    setup do
      # Create a new user without a family for onboarding tests
      @user = User.create!(
        email: "newuser@example.com",
        nickname: "새엄마",
        provider: "kakao",
        uid: "999999"
      )
      sign_in @user
    end

    test "아이 등록 페이지 UI 확인" do
      visit onboarding_child_path

      # Sketch 디자인 시스템: fixed inset-0 전체 화면, bg-sketch-paper 배경
      assert_selector ".fixed.inset-0.bg-sketch-paper"

      # 타이틀
      assert_text "모아봄"

      # 타이틀과 설명
      assert_selector "h1", text: "아이 정보를 등록해주세요"
      assert_text "성장 기록의 주인공이에요"

      # 입력 필드
      within("form") do
        assert_text "이름"
        assert_field "child[name]"

        assert_text "생년월일"
        assert_field "child[birthdate]"

        assert_text "성별"
        assert_button "여아"
        assert_button "남아"

        # 제출 버튼
        assert_button "다음"
      end

      # 스킵 버튼 (form 밖에서 확인)
      assert_button "나중에 할게요"
    end

    test "성별 선택 버튼 상태 변경" do
      visit onboarding_child_path

      within("form") do
        female_btn = find_button("여아")

        # 초기: 여아 선택됨 (Sketch 디자인 - border-sketch-ink)
        assert female_btn[:class].include?("border-sketch-ink")
      end
    end

    test "아이 등록 성공" do
      visit onboarding_child_path

      fill_in "child[name]", with: "서연"
      # date_field는 JavaScript로 설정해야 함
      page.execute_script("document.querySelector('input[name=\"child[birthdate]\"]').value = '2023-03-15'")

      # 폼 제출 (z-index 문제로 JavaScript 사용)
      page.execute_script("document.querySelector('form').submit()")

      # 다음 페이지로 이동 (가족 초대)
      assert_current_path onboarding_invite_path
    end
  end
end
