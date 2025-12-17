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

      # 디자인 시스템: fixed inset-0 전체 화면, bg-cream-50 배경
      assert_selector ".fixed.inset-0.bg-cream-50"

      # 헤더 확인
      within(".onboarding-header") do
        # 뒤로가기 버튼 (Heroicon)
        assert_selector "button svg.w-6.h-6"
        # 타이틀
        assert_text "모아봄"
        # 진행률 표시 (1/3 - 첫 번째 활성)
        assert_selector ".bg-primary-500", count: 1
        assert_selector ".bg-warm-gray-300", count: 2
      end

      # 아이콘 영역 확인
      assert_selector ".w-20.h-20.bg-primary-100.rounded-full svg.w-10.h-10"

      # 타이틀과 설명
      assert_selector "h1.text-2xl.font-bold.text-warm-gray-800", text: "프로필을 설정해주세요"
      assert_selector "p.text-warm-gray-500", text: "가족들에게 보여질 이름이에요"

      # 입력 필드
      within("form") do
        assert_selector "label.text-sm.font-medium.text-warm-gray-700", text: "닉네임"
        assert_field "user[nickname]", class: "input-text"

        # 제출 버튼 (btn-primary)
        assert_button "다음", class: "btn-primary"
      end
    end

    test "프로필 설정 성공" do
      visit onboarding_profile_path

      fill_in "user[nickname]", with: "엄마"

      # 버튼이 다른 요소에 가려져 있을 수 있으므로 JavaScript로 클릭
      page.execute_script("document.querySelector('input[type=submit]').click()")

      # 다음 페이지로 이동 (아이 등록)
      assert_current_path onboarding_child_path
    end

    test "프로필 설정 실패 시 에러 표시" do
      visit onboarding_profile_path

      # 닉네임을 빈 값으로 설정
      fill_in "user[nickname]", with: ""

      # 제출 (JavaScript로 클릭)
      page.execute_script("document.querySelector('input[type=submit]').click()")

      # 페이지가 그대로 있어야 함 (리다이렉트 안 됨)
      assert_current_path onboarding_profile_path

      # 에러 메시지 표시
      assert_selector ".alert-error"
    end
  end
end
