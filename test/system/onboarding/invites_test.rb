# frozen_string_literal: true

require "application_system_test_case"

module Onboarding
  class InvitesTest < ApplicationSystemTestCase
    setup do
      @user = User.create!(
        email: "inviteuser@example.com",
        nickname: "초대엄마",
        provider: "kakao",
        uid: "888888"
      )
      # Create family for the user
      @family = Family.create!(name: "#{@user.nickname}의 가족")
      @family.family_memberships.create!(user: @user, role: :owner)

      sign_in @user
    end

    test "초대 페이지 UI 확인" do
      visit onboarding_invite_path

      # Sketch 디자인 시스템: fixed inset-0 전체 화면, bg-sketch-paper 배경
      assert_selector ".fixed.inset-0.bg-sketch-paper"

      # 타이틀
      assert_text "모아봄"

      # 타이틀과 설명
      assert_selector "h1", text: "가족을 초대해보세요"
      assert_text "함께 추억을 공유할 수 있어요"

      # 초대 링크 카드 (Sketch CardComponent)
      assert_text "초대 링크"
      assert_selector "input[readonly]"

      # 하단 버튼
      assert_button "시작하기"
      assert_button "나중에 초대할게요"
    end

    test "초대 링크가 표시됨" do
      visit onboarding_invite_path

      # Sketch CardComponent 내의 readonly input
      input = find("input[readonly]")
      # URL에는 토큰이 포함되어 있어야 함
      assert input.value.include?("/i/"), "URL should include /i/ path"
      assert input.value.length > 20, "URL should include invitation token"
    end

    test "시작하기 버튼으로 홈으로 이동" do
      visit onboarding_invite_path

      # fixed 레이아웃에서는 scroll_to가 작동하지 않으므로 JavaScript 사용
      button = find_button("시작하기")
      execute_script("arguments[0].scrollIntoView({block: 'center'})", button)
      execute_script("arguments[0].click()", button)

      assert_current_path root_path
    end

    test "나중에 초대 버튼으로 홈으로 이동" do
      visit onboarding_invite_path

      # fixed 레이아웃에서는 scroll_to가 작동하지 않으므로 JavaScript 사용
      button = find_button("나중에 초대할게요")
      execute_script("arguments[0].scrollIntoView({block: 'center'})", button)
      execute_script("arguments[0].click()", button)

      assert_current_path root_path
    end
  end
end
