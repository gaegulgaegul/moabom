# frozen_string_literal: true

require "application_system_test_case"

class TabbarNavigationTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    # 온보딩 완료를 sign_in 전에 처리
    @user.complete_onboarding!
    @family.complete_onboarding!

    # Debug: verify onboarding status in database with fresh query
    fresh_user = User.find(@user.id)
    fresh_family = Family.find(@family.id)
    puts "DEBUG: Fresh User onboarding_completed_at: #{fresh_user.onboarding_completed_at}"
    puts "DEBUG: Fresh Family onboarding_completed_at: #{fresh_family.onboarding_completed_at}"

    sign_in @user
  end

  test "should navigate to photo upload when clicking upload button" do
    # 탭바가 표시되는 페이지(설정)로 이동
    visit settings_profile_path

    # Debug: check if we were redirected to onboarding
    if current_path.start_with?("/onboarding")
      puts "DEBUG: REDIRECTED to onboarding page: #{current_path}"
      puts "DEBUG: This means check_onboarding redirected because current_family.onboarding_completed? returned false"

      # Query the database from the test process to see what we see
      test_process_family = Family.find(@family.id)
      puts "DEBUG: Family onboarding_completed_at from test process: #{test_process_family.onboarding_completed_at}"
    end

    # Debug: check if tabbar is present
    if has_selector?("nav", wait: 1)
      puts "DEBUG: Tabbar is present on settings page ✓"
    else
      puts "DEBUG: Tabbar is NOT present on settings page!"
    end

    # 탭바의 업로드 버튼 클릭
    find('a[aria-label="사진 업로드"]').click

    # 사진 업로드 화면으로 이동 확인
    assert_current_path new_family_photo_path(@family)
  end
end
