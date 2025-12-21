# frozen_string_literal: true

require "application_system_test_case"

class DashboardNavigationTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    @family.complete_onboarding!
    sign_in @user
  end

  # 5.2.1 하단 탭바 제거 테스트
  test "dashboard should not have bottom tab bar" do
    visit root_path

    # 탭바가 없어야 함
    assert_no_selector "nav", text: "홈"
    assert_no_selector "nav", text: "앨범"

    # 대신 상단 헤더만 있어야 함
    assert_selector "header", count: 1
  end

  test "dashboard should have clean single-page layout" do
    visit root_path

    # 전체 페이지가 하나의 스크롤 가능한 영역
    assert_selector "main.min-h-screen"

    # 하단 패딩이 탭바 높이가 아님 (pb-20 제거)
    main = find("main")
    assert_not main[:class].include?("pb-20"),
               "대시보드 main에 pb-20이 없어야 합니다. 실제 클래스: #{main[:class]}"
  end

  # 5.2.2 상단 바 설정 아이콘 테스트
  test "dashboard header should have settings icon" do
    visit root_path

    within "header" do
      # 로고
      assert_selector "a[href='/']", text: "모아봄"

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

  test "should navigate to notifications from tabbar" do
    # 탭바가 표시되는 페이지(설정)로 이동
    visit settings_profile_path

    # 탭바의 알림 탭 클릭
    within "nav" do
      click_link "알림"
    end

    # 알림 목록 화면으로 이동 확인
    assert_current_path notifications_path
    assert_text "알림"
  end
end
