# frozen_string_literal: true

require "application_system_test_case"

class DashboardNavigationTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    # 온보딩 완료를 sign_in 전에 처리
    @user.complete_onboarding!
    @family.complete_onboarding!

    sign_in @user
  end

  # 5.2.1 대시보드 레이아웃 테스트
  test "dashboard should have header" do
    visit root_path

    # 헤더가 있어야 함
    assert_selector "header", count: 1
  end

  test "dashboard should have story filter and timeline" do
    visit root_path

    # 인사 메시지 확인
    assert_text "안녕하세요, #{@user.nickname}님!"

    # 스토리 필터 확인
    assert_selector "[data-controller='story-filter']"
  end

  # 5.2.2 상단 바 설정 아이콘 테스트
  test "dashboard header should have settings icon" do
    visit root_path

    within "header" do
      # 로고
      assert_text "모아봄"

      # 알림 아이콘
      assert_selector "a[aria-label='알림']"

      # 설정 아이콘
      assert_selector "a[aria-label='설정']"
    end
  end

  test "clicking settings icon should navigate to settings" do
    visit root_path

    # aria-label로 설정 아이콘을 찾아 클릭
    within "header" do
      find("a[aria-label='설정']").click
    end

    assert_current_path settings_profile_path
    assert_text "설정"
  end

  # 5.4 알림 네비게이션 테스트
  test "should navigate to notifications from header bell icon" do
    visit root_path

    # 헤더의 알림 버튼 클릭
    within "header" do
      find("a[aria-label='알림']").click
    end

    # 알림 목록 화면으로 이동 확인
    assert_current_path notifications_path
    assert_text "알림"
  end

  # 탭바 테스트 - 탭바가 제거됨 (e535a7e 커밋)
  # 설정 네비게이션은 헤더 아이콘을 통해 가능
end
