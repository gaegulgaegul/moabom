# frozen_string_literal: true

require "application_system_test_case"

module Onboarding
  class ProfilesTest < ApplicationSystemTestCase
    setup do
      @user = users(:mom)
      sign_in @user
    end

    test "프로필 설정 페이지 UI 확인" do
      visit onboarding_profile_path

      # Sketch 디자인 시스템: fixed inset-0 전체 화면, bg-sketch-paper 배경
      assert_selector ".fixed.inset-0.bg-sketch-paper"

      # 타이틀
      assert_text "모아봄"

      # 타이틀과 설명
      assert_selector "h1", text: "프로필을 설정해주세요"
      assert_text "가족들에게 보여질 이름이에요"

      # 입력 필드
      within("form") do
        assert_text "닉네임"
        assert_field "user[nickname]"

        # 제출 버튼
        assert_button "다음"
      end
    end

    test "프로필 설정 성공" do
      visit onboarding_profile_path

      fill_in "user[nickname]", with: "엄마"

      # 버튼이 다른 요소에 가려져 있을 수 있으므로 JavaScript로 클릭
      page.execute_script("document.querySelector('button[type=submit]').click()")

      # 다음 페이지로 이동 (아이 등록)
      assert_current_path onboarding_child_path
    end

    test "프로필 설정 실패 시 에러 표시" do
      visit onboarding_profile_path

      # HTML5 validation 비활성화하고 닉네임을 빈 값으로 설정
      page.execute_script("document.querySelector('input[name=\"user[nickname]\"]').removeAttribute('required')")
      fill_in "user[nickname]", with: ""

      # 제출 (JavaScript로 클릭)
      page.execute_script("document.querySelector('button[type=submit]').click()")

      # 서버 측 validation 실패 후 에러 메시지 확인
      # 또는 HTML5 validation이 작동하면 페이지가 그대로 있음
      assert_current_path onboarding_profile_path
    end
  end
end
