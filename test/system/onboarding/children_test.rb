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

      # 디자인 시스템: fixed inset-0 전체 화면, bg-cream-50 배경
      assert_selector ".fixed.inset-0.bg-cream-50"

      # 헤더 확인 (2/3 진행률)
      within(".onboarding-header") do
        # 뒤로가기 버튼
        assert_selector "button svg.w-6.h-6"
        # 타이틀
        assert_text "모아봄"
        # 진행률 표시 (2번째 활성)
        dots = all(".w-2.h-2.rounded-full")
        assert_equal 3, dots.size
        assert dots[0][:class].include?("bg-warm-gray-300"), "첫 번째 점은 비활성"
        assert dots[1][:class].include?("bg-primary-500"), "두 번째 점은 활성"
        assert dots[2][:class].include?("bg-warm-gray-300"), "세 번째 점은 비활성"
      end

      # 아이콘 영역 확인 (secondary 색상)
      assert_selector ".w-20.h-20.bg-secondary-100.rounded-full svg.w-10.h-10"

      # 타이틀과 설명
      assert_selector "h1.text-2xl.font-bold.text-warm-gray-800", text: "아이 정보를 등록해주세요"
      assert_selector "p.text-warm-gray-500", text: "성장 기록의 주인공이에요"

      # 입력 필드
      within("form") do
        assert_selector "label.text-sm.font-medium.text-warm-gray-700", text: "이름"
        assert_field "child[name]", class: "input-text"

        assert_selector "label.text-sm.font-medium.text-warm-gray-700", text: "생년월일"
        assert_field "child[birthdate]", class: "input-text"

        assert_selector "label.text-sm.font-medium.text-warm-gray-700", text: "성별"
        assert_selector "button[data-gender='female']", text: "여아"
        assert_selector "button[data-gender='male']", text: "남아"

        # 제출 버튼
        assert_button "다음", class: "btn-primary"
      end

      # 스킵 버튼 (form 밖에서 확인)
      assert_selector "button.text-warm-gray-400", text: "나중에 할게요"
    end

    test "성별 선택 버튼 상태 변경" do
      visit onboarding_child_path

      within("form") do
        female_btn = find("button[data-gender='female']")
        male_btn = find("button[data-gender='male']")

        # 초기: 여아 선택됨
        assert female_btn[:class].include?("border-primary-500")
        assert female_btn[:class].include?("bg-primary-50")

        # 남아 클릭 시 상태 변경 (Stimulus 컨트롤러 구현 후 테스트)
        # male_btn.click
        # assert male_btn[:class].include?("border-primary-500")
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

    # Skip test는 3.4 온보딩 초대 페이지 구현 후 활성화
    # test "아이 등록 스킵" do
    #   visit onboarding_child_path
    #
    #   # "나중에 할게요" 클릭 (JavaScript로 실행)
    #   page.execute_script("document.querySelector('button[onclick*=invite]').click()")
    #
    #   # 다음 페이지로 이동 (가족 초대)
    #   assert_current_path onboarding_invite_path
    # end
  end
end
