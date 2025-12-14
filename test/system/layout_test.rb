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
    within "nav" do
      home_link = find("a[href='#{root_path}']")
      assert home_link[:class].include?("text-pink-500")
    end

    # 설정으로 이동
    click_on "설정"

    # 설정 탭 활성화 확인
    within "nav" do
      settings_link = find("a[href='#{settings_profile_path}']")
      assert settings_link[:class].include?("text-pink-500")
    end
  end

  test "플래시 메시지 표시" do
    visit root_path

    # 성공 메시지 확인 (쿼리 파라미터로 전달)
    visit "/?notice=성공했습니다"
    assert_selector ".bg-green-100", text: "성공했습니다"

    # 경고 메시지 확인
    visit "/?alert=오류가 발생했습니다"
    assert_selector ".bg-red-100", text: "오류가 발생했습니다"
  end

  test "카카오 로그인 버튼이 실제 OAuth URL로 연결" do
    visit root_path

    # 카카오 로그인 버튼 찾기
    kakao_button = find("a", text: "카카오로 계속하기")

    # /auth/kakao 경로로 연결되는지 확인
    assert_equal "/auth/kakao", kakao_button[:href]
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

  private

  def sign_in(user)
    # 세션 설정을 위한 헬퍼
    # 실제로는 OmniAuth를 통한 로그인이지만 테스트에서는 세션 직접 설정
    visit root_path
    page.set_rack_session(user_id: user.id)
  end
end
