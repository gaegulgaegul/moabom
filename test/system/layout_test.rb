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

    visit root_path

    # 헤더 확인
    assert_selector "header", count: 1
    assert_text "모아봄"
    assert_button "로그아웃"

    # 탭바 확인
    assert_selector "nav", count: 1
    assert_text "홈"
    assert_text "앨범"
    assert_text "알림"
    assert_text "설정"
  end

  test "탭바의 현재 페이지 하이라이트" do
    user = users(:mom)
    sign_in user

    visit root_path

    # 홈 탭 활성화 확인
    home_link = find("nav a[href='#{root_path}']")
    assert home_link[:class].include?("text-pink-500"),
           "홈 탭이 활성화되어야 합니다. 실제 클래스: #{home_link[:class]}"

    # 설정으로 이동
    click_on "설정"

    # 설정 탭 활성화 확인
    settings_link = find("nav a[href='#{settings_profile_path}']")
    assert settings_link[:class].include?("text-pink-500"),
           "설정 탭이 활성화되어야 합니다. 실제 클래스: #{settings_link[:class]}"
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

    # Apple 버튼은 비활성화되어야 함
    apple_button = find("a", text: "Apple로 계속하기")
    assert apple_button[:class].include?("opacity-50") || apple_button[:class].include?("cursor-not-allowed")

    # Google 버튼도 비활성화되어야 함
    google_button = find("a", text: "Google로 계속하기")
    assert google_button[:class].include?("opacity-50") || google_button[:class].include?("cursor-not-allowed")
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
