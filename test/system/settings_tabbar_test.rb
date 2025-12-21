# frozen_string_literal: true

require "application_system_test_case"

class SettingsTabbarTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    sign_in @user
  end

  test "should not show bottom tabbar in settings pages" do
    # 프로필 설정 페이지
    visit settings_profile_path

    # 탭바가 표시되지 않아야 함
    assert_no_selector "nav.fixed.bottom-0", text: "홈"

    # 메인 콘텐츠가 탭바 공간 없이 패딩 적용 (pb-20 없음)
    # pt-14는 헤더 공간, pb-20는 탭바 공간
    assert_selector "main.pt-14"
    assert_no_selector "main.pb-20"
  end

  test "should not show bottom tabbar in notification settings" do
    # 알림 설정 페이지
    visit settings_notifications_path

    # 탭바가 표시되지 않아야 함
    assert_no_selector "nav.fixed.bottom-0", text: "홈"
  end

  test "should show back navigation in header" do
    visit settings_profile_path

    # 헤더에 뒤로가기 버튼이 있어야 함 (탭바 대신)
    # 설정 페이지에는 뒤로가기 링크가 있을 것으로 예상
    assert_selector "a[href='#{root_path}'], button[aria-label='뒤로 가기']"
  end
end
