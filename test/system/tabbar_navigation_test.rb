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
    # 탭바가 표시되는 페이지(알림)로 이동
    # 설정 페이지는 Wave 5 Phase 5에서 탭바 숨김 처리됨
    visit notifications_path

    # 탭바가 표시되는지 확인
    assert_selector "nav", count: 1

    # 탭바의 업로드 버튼 클릭
    find('a[aria-label="사진 업로드"]').click

    # 사진 업로드 화면으로 이동 확인
    assert_current_path new_family_photo_path(@family)
  end
end
