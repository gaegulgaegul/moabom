# frozen_string_literal: true

require "application_system_test_case"

class LayoutTest < ApplicationSystemTestCase
  test "비로그인 사용자는 로그인 페이지로 리다이렉트" do
    visit root_path

    # 로그인 페이지로 리다이렉트
    assert_current_path login_path

    # 로그인 페이지 기본 요소 확인
    assert_text "모아봄"
    assert_text "카카오로 계속하기"
  end

  test "로그인 사용자는 헤더 표시" do
    user = users(:mom)
    sign_in user

    visit root_path

    # 헤더 확인
    assert_selector "header", count: 1
    assert_text "모아봄"
  end

  # Wave 2: 디자인 시스템 적용 테스트
  test "body에 sketch-paper 배경색 적용" do
    user = users(:mom)
    sign_in user
    visit root_path

    # body 태그에 bg-sketch-paper 클래스가 있는지 확인
    assert_selector "body.bg-sketch-paper"
  end

  test "로그인 사용자의 main 영역 확인" do
    user = users(:mom)
    sign_in user
    visit root_path

    # main 태그가 있는지 확인
    assert_selector "main"
  end

  test "로그인 페이지의 레이아웃 확인" do
    visit login_path

    # 로그인 페이지는 전체 화면 레이아웃
    assert_selector ".min-h-screen.bg-sketch-paper"
  end

  # Wave 2: Header 재디자인 테스트
  test "로그인 사용자의 header 확인" do
    user = users(:mom)
    sign_in user
    visit root_path

    # header가 있는지 확인
    assert_selector "header"
  end

  test "로그인 사용자에게 알림 아이콘 표시" do
    user = users(:mom)
    sign_in user
    visit root_path

    # 헤더가 반드시 있어야 함
    assert_selector "header", count: 1

    # 헤더 내에 알림 링크 확인
    within "header" do
      assert_selector "a[href='#{notifications_path}']",
        message: "헤더 내에 알림 링크가 없습니다"
    end
  end

  # 탭바 테스트 - 탭바가 제거됨 (e535a7e 커밋)
  # 향후 탭바 재도입 시 테스트 활성화 필요

  test "로그인 후 메인 페이지 정상 로드" do
    user = users(:mom)
    sign_in user

    # 로그인 후 페이지 접근
    visit root_path

    # 정상적으로 페이지가 로드되는지 확인
    assert_selector "main"
    assert_current_path root_path
  end

  test "카카오 로그인 버튼이 실제 OAuth URL로 연결" do
    visit login_path

    # 카카오 로그인 버튼 찾기
    kakao_button = find("a[href='/auth/kakao']")

    # /auth/kakao 경로로 연결되는지 확인
    assert_equal "/auth/kakao", kakao_button[:href].gsub(%r{^https?://[^/]+}, "")
  end

  test "로그인 버튼에 '#' 하드코딩이 없음" do
    visit login_path

    # 카카오 버튼은 실제 경로를 가져야 함
    kakao_button = find("a[href='/auth/kakao']")
    refute_equal "#", kakao_button[:href]
  end
end
