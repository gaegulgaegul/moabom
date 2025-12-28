# frozen_string_literal: true

require "application_system_test_case"

class HomeLoginTest < ApplicationSystemTestCase
  test "비로그인 상태에서 로그인 페이지 UI 확인" do
    visit login_path

    # 디자인 시스템: bg-sketch-paper 배경 확인
    assert_selector ".min-h-screen.bg-sketch-paper", count: 1

    # 타이틀 확인
    assert_selector "h1", text: "우리 아이의 소중한 순간,"
    assert_text "가족과 함께 모아봄"

    # 로그인 버튼 확인
    # Apple 로그인
    assert_text "Apple로 계속하기"

    # 카카오 로그인
    assert_selector "a[href='/auth/kakao']", text: "카카오로 계속하기"

    # Google 로그인
    assert_text "Google로 계속하기"

    # 약관 텍스트
    assert_text "로그인 시 이용약관 및 개인정보 처리방침에 동의하게 됩니다."
  end

  test "비로그인 시 root_path 접근하면 login으로 리다이렉트" do
    visit root_path
    assert_current_path login_path
  end

  test "개발 환경에서 빠른 진입 버튼 표시" do
    skip "개발 환경에서만 동작하는 기능으로 테스트 환경에서는 스킵"
  end
end
