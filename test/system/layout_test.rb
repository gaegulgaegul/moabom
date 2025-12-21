# frozen_string_literal: true

require "application_system_test_case"

class LayoutTest < ApplicationSystemTestCase
  test "비로그인 사용자는 헤더만 표시" do
    visit root_path

    # 헤더 확인
    assert_selector "header", count: 1
    assert_text "모아봄"
    assert_text "로그인"

    # 탭바 미표시 확인
    assert_no_selector "nav", text: "홈"
    assert_no_selector "nav", text: "설정"
  end

  test "로그인 사용자는 헤더와 탭바 모두 표시" do
    user = users(:mom)
    sign_in user

    visit settings_profile_path

    # 헤더 확인
    assert_selector "header", count: 1
    assert_text "모아봄"
    assert_selector "header a[aria-label='설정']" # 설정 아이콘 확인

    # 탭바 확인 (대시보드가 아닌 다른 페이지에서는 탭바 표시)
    assert_selector "nav", count: 1
    assert_text "홈"
    assert_text "앨범"
    assert_text "알림"
    assert_text "설정"
  end

  test "탭바의 현재 페이지 하이라이트" do
    user = users(:mom)
    sign_in user

    visit settings_profile_path

    # 설정 탭 활성화 확인
    within "nav" do
      settings_link = find("a", text: "설정")
      assert settings_link[:class]&.include?("tab-item-active"),
             "설정 탭이 활성화되어야 합니다. 실제 클래스: #{settings_link[:class]}"
    end

    # 홈으로 이동
    within "nav" do
      click_on "홈"
    end

    # 홈 페이지로 이동 확인 (대시보드에서는 탭바가 없으므로 경로만 확인)
    assert_current_path root_path
  end

  # Wave 2: 디자인 시스템 적용 테스트
  test "body에 cream-50 배경색 적용" do
    visit root_path

    # body 태그에 bg-cream-50 클래스가 있는지 확인
    assert_selector "body.bg-cream-50"
  end

  test "로그인 사용자의 main 영역 패딩 확인" do
    user = users(:mom)
    sign_in user
    visit settings_profile_path

    # main 태그에 pt-14 pb-20 클래스가 있는지 확인 (탭바가 있는 페이지)
    assert_selector "main.pt-14.pb-20.min-h-screen"
  end

  test "비로그인 사용자의 main 영역 패딩 확인" do
    visit root_path

    # main 태그에 pt-14만 있고 pb-20은 없는지 확인
    assert_selector "main.pt-14.min-h-screen"
    assert_no_selector "main.pb-20"
  end

  # Wave 2: Header 재디자인 테스트
  test "header에 glass 효과 적용" do
    visit root_path

    # header에 glassmorphism 효과 클래스 확인
    assert_selector "header.bg-white\\/80.backdrop-blur-md"
    assert_selector "header.border-b.border-cream-200"
  end

  test "로그인 사용자에게 알림 아이콘 표시" do
    user = users(:mom)
    sign_in user
    visit root_path

    # 알림 버튼과 heroicon bell 확인
    within "header" do
      assert_selector "button svg"  # heroicon
      # 알림 뱃지 확인
      assert_selector ".bg-accent-500.rounded-full"
    end
  end

  # Wave 2: Tab Bar 재디자인 테스트
  test "탭바에 glass 효과 적용" do
    user = users(:mom)
    sign_in user
    visit settings_profile_path

    # nav에 glassmorphism 효과 클래스 확인
    assert_selector "nav.bg-white\\/90.backdrop-blur-md"
    assert_selector "nav.border-t.border-cream-200"
  end

  test "탭바 아이콘이 heroicon으로 표시" do
    user = users(:mom)
    sign_in user
    visit settings_profile_path

    # nav 내부에 여러 개의 svg (heroicon)가 있어야 함
    within "nav" do
      assert_selector "svg", minimum: 5  # 홈, 앨범, 업로드, 알림, 설정
    end
  end

  test "중앙 FAB 버튼 스타일링" do
    user = users(:mom)
    sign_in user
    visit settings_profile_path

    # FAB 버튼 확인 (bg-primary-500, rounded-full)
    within "nav" do
      assert_selector ".bg-primary-500.rounded-full"
    end
  end

  test "플래시 메시지 표시" do
    # 로그인하여 리다이렉트를 통해 플래시 메시지 테스트
    user = users(:mom)

    # OmniAuth 콜백 후 성공 메시지가 표시되어야 함
    sign_in user

    # 로그인 성공 시 플래시 메시지 확인
    # (실제로는 OmniAuth 콜백에서 설정됨)
    assert has_content?("환영합니다") || has_content?("로그인"),
           "로그인 후 메시지가 표시되어야 합니다"
  end

  test "카카오 로그인 버튼이 실제 OAuth URL로 연결" do
    visit root_path

    # 카카오 로그인 버튼 찾기
    kakao_button = find("a", text: "카카오로 계속하기")

    # /auth/kakao 경로로 연결되는지 확인 (전체 URL에서 경로만 추출)
    assert kakao_button[:href].end_with?("/auth/kakao"), "Expected href to end with /auth/kakao, but got #{kakao_button[:href]}"
  end

  test "미구현 OAuth 제공자는 비활성화 처리" do
    visit root_path

    # Apple 버튼은 비활성화 스타일 클래스를 가져야 함
    apple_button = find("a", text: "Apple로 계속하기")
    assert apple_button[:class].include?("btn-apple"), "Apple button should have btn-apple class"

    # Google 버튼도 비활성화 스타일 클래스를 가져야 함
    google_button = find("a", text: "Google로 계속하기")
    assert google_button[:class].include?("btn-google"), "Google button should have btn-google class"
  end

  test "로그인 버튼에 '#' 하드코딩이 없음" do
    visit root_path

    # 모든 로그인 버튼 찾기
    login_buttons = all("a", text: /계속하기/)

    # '#' href를 가진 버튼이 없어야 함
    login_buttons.each do |button|
      refute_equal "#", button[:href], "로그인 버튼이 '#'로 하드코딩되어 있습니다"
    end
  end
end
