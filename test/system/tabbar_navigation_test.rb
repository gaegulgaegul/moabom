# frozen_string_literal: true

require "application_system_test_case"

class TabbarNavigationTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    # 온보딩 완료를 sign_in 전에 처리
    @user.complete_onboarding!
    @family.complete_onboarding!

    # Debug: verify onboarding status in database
    @user.reload
    @family.reload
    puts "DEBUG: User onboarding_completed_at: #{@user.onboarding_completed_at}"
    puts "DEBUG: Family onboarding_completed_at: #{@family.onboarding_completed_at}"

    sign_in @user
  end

  test "should navigate to photo upload when clicking upload button" do
    # 탭바가 표시되는 페이지(설정)로 이동
    visit settings_profile_path

    # Debug: check if tabbar is present
    if has_selector?("nav", wait: 1)
      puts "DEBUG: Tabbar is present on settings page"
    else
      puts "DEBUG: Tabbar is NOT present on settings page!"
      puts "DEBUG: Page source: #{page.html[0..500]}"
    end

    # 탭바의 업로드 버튼 클릭
    find('a[aria-label="사진 업로드"]').click

    # 사진 업로드 화면으로 이동 확인
    assert_current_path new_family_photo_path(@family)
  end
end
