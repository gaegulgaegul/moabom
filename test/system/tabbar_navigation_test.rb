# frozen_string_literal: true

require "application_system_test_case"

class TabbarNavigationTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    # 온보딩 완료를 sign_in 전에 처리
    @user.complete_onboarding!
    @family.complete_onboarding!

    sign_in @user
  end

  test "should navigate to photo upload when clicking upload button" do
    # 탭바가 제거됨 (e535a7e 커밋)
    # 사진 업로드는 별도 경로를 통해 접근 가능
    skip "탭바가 제거되었으므로 테스트 스킵"
  end
end
