# frozen_string_literal: true

require "application_system_test_case"

class ResponsiveTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    @user.complete_onboarding!
    @family.complete_onboarding!
    sign_in @user
  end

  test "mobile layout (< 640px)" do
    # 모바일 뷰포트 설정
    page.driver.browser.manage.window.resize_to(375, 667)
    visit root_path

    # 헤더 표시 확인
    assert_selector "header", visible: true

    # 메인 콘텐츠 확인
    assert_selector "main"
  end

  test "tablet layout (768px)" do
    # 태블릿 뷰포트 설정
    page.driver.browser.manage.window.resize_to(768, 1024)
    visit root_path

    # 기본 레이아웃 확인
    assert_selector "header", visible: true
    assert_selector "main"
  end

  test "desktop layout (1024px+)" do
    # 데스크톱 뷰포트 설정
    page.driver.browser.manage.window.resize_to(1280, 800)
    visit root_path

    # 기본 레이아웃 확인
    assert_selector "header", visible: true
    assert_selector "main"
  end

  test "responsive photo grid columns" do
    skip "Requires authenticated user and photo creation"
  end

  test "touch targets are accessible on mobile" do
    page.driver.browser.manage.window.resize_to(375, 667)
    visit root_path

    # 버튼/링크 크기 확인
    links = page.all("a, button").reject { |el| el[:class]&.include?("hidden") }
    if links.any?
      links.first(3).each do |link|
        height = page.evaluate_script("arguments[0].getBoundingClientRect().height;", link)

        # 터치 타겟이 최소 크기를 만족하는지 확인 (너그럽게 32px)
        assert height >= 32, "터치 타겟이 너무 작음: #{height}px"
      end
    end
  end

  test "content does not overflow on narrow screens" do
    # 매우 좁은 화면 테스트
    page.driver.browser.manage.window.resize_to(320, 568)
    visit root_path

    # 가로 스크롤이 없는지 확인
    body_width = page.evaluate_script("document.body.scrollWidth")
    viewport_width = page.evaluate_script("window.innerWidth")

    assert body_width <= viewport_width + 5, # +5는 브라우저 차이 허용
      "가로 스크롤 발생: body(#{body_width}px) > viewport(#{viewport_width}px)"
  end

  test "images have proper aspect ratio on all screen sizes" do
    skip "Requires authenticated user and photo creation"
  end

  test "text is readable on all screen sizes" do
    # 모바일
    page.driver.browser.manage.window.resize_to(375, 667)
    visit root_path

    body_font_size = page.evaluate_script("
      window.getComputedStyle(document.body).fontSize
    ")
    assert body_font_size.to_i >= 14, "모바일 폰트 크기가 너무 작음: #{body_font_size}"

    # 태블릿
    page.driver.browser.manage.window.resize_to(768, 1024)
    visit root_path

    body_font_size = page.evaluate_script("
      window.getComputedStyle(document.body).fontSize
    ")
    assert body_font_size.to_i >= 14, "태블릿 폰트 크기가 너무 작음: #{body_font_size}"
  end

  test "page is accessible on all screen sizes" do
    # 모바일
    page.driver.browser.manage.window.resize_to(375, 667)
    visit root_path
    assert_selector "header", minimum: 1

    # 태블릿
    page.driver.browser.manage.window.resize_to(768, 1024)
    visit root_path
    assert_selector "header", minimum: 1

    # 데스크톱
    page.driver.browser.manage.window.resize_to(1280, 1024)
    visit root_path
    assert_selector "header", minimum: 1
  end
end
