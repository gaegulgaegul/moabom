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

      # 디자인 시스템: fixed inset-0 전체 화면, bg-cream-50 배경
      assert_selector ".fixed.inset-0.bg-cream-50"

      # 헤더 확인 (3/3 진행률)
      within(".onboarding-header") do
        # 뒤로가기 버튼
        assert_selector "button svg.w-6.h-6"
        # 타이틀
        assert_text "모아봄"
        # 진행률 표시 (3번째 활성)
        dots = all(".w-2.h-2.rounded-full")
        assert_equal 3, dots.size
        assert dots[0][:class].include?("bg-warm-gray-300"), "첫 번째 점은 비활성"
        assert dots[1][:class].include?("bg-warm-gray-300"), "두 번째 점은 비활성"
        assert dots[2][:class].include?("bg-primary-500"), "세 번째 점은 활성"
      end

      # 아이콘 영역 확인 (accent 색상)
      assert_selector ".w-20.h-20.bg-accent-100.rounded-full svg.w-10.h-10"

      # 타이틀과 설명
      assert_selector "h1.text-2xl.font-bold.text-warm-gray-800", text: "가족을 초대해보세요"
      assert_selector "p.text-warm-gray-500", text: "함께 추억을 공유할 수 있어요"

      # 초대 링크 카드
      within(".card-glass") do
        assert_text "초대 링크"
        assert_selector "input[readonly].input-text.flex-1"
        assert_button class: "btn-primary"
      end

      # 공유 버튼들
      within("div.flex.justify-center.gap-4") do
        assert_selector "button .bg-\\[\\#FEE500\\]", text: "💬" # 카카오톡 버튼
        assert_selector "button svg.w-6.h-6" # 링크 복사 아이콘
      end

      # 하단 버튼
      assert_button "시작하기", class: "btn-primary"
      assert_button "나중에 초대할게요", class: "text-warm-gray-400"
    end

    test "초대 링크가 표시됨" do
      visit onboarding_invite_path

      within(".card-glass") do
        input = find("input[readonly]")
        # URL에는 토큰이 포함되어 있어야 함
        assert input.value.include?("/i/"), "URL should include /i/ path"
        assert input.value.length > 20, "URL should include invitation token"
      end
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
