# frozen_string_literal: true

require "application_system_test_case"

class HomeLoginTest < ApplicationSystemTestCase
  test "비로그인 상태에서 로그인 페이지 UI 확인" do
    visit root_path

    # 디자인 시스템: bg-gradient-warm 배경 확인
    assert_selector ".min-h-screen.bg-gradient-warm", count: 1

    # 로고/일러스트 영역
    assert_selector ".w-32.h-32.bg-primary-100.rounded-full", text: "🌸"

    # 타이틀 확인
    assert_selector "h1.text-2xl.font-bold.text-warm-gray-800", text: "우리 아이의 소중한 순간,"
    assert_selector "p.text-lg.text-warm-gray-600", text: "가족과 함께 모아봄"

    # 로그인 버튼 확인 (디자인 시스템 클래스 사용)
    # Apple 로그인 (비활성화)
    assert_selector "a.btn-apple", text: "Apple로 계속하기"

    # 카카오 로그인 (활성화, 디자인 시스템: #FEE500)
    assert_selector "a.btn-kakao[href='/auth/kakao']", text: "💬 카카오로 계속하기"
    kakao_button = find("a[href='/auth/kakao']")
    # 카카오 노란색 확인
    assert kakao_button[:class].include?("btn-kakao")

    # Google 로그인 (비활성화)
    assert_selector "a.btn-google", text: "Google로 계속하기"

    # 약관 텍스트
    assert_text "로그인 시 이용약관 및 개인정보 처리방침에 동의하게 됩니다."
  end

  test "개발 환경에서 빠른 진입 버튼 표시" do
    skip "개발 환경에서만 동작하는 기능으로 테스트 환경에서는 스킵"
    # 실제 개발 환경에서는 수동으로 확인
    # visit root_path
    # within("form[action='/dev_login']") do
    #   assert_button "🚀 개발 모드로 빠른 진입"
    # end
  end
end
