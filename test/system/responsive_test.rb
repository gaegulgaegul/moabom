# frozen_string_literal: true

require "application_system_test_case"

class ResponsiveTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    sign_in @user
  end

  test "mobile layout (< 640px)" do
    # 모바일 뷰포트 설정
    page.driver.browser.manage.window.resize_to(375, 667)
    visit root_path

    # 헤더 표시 확인
    assert_selector "header", visible: true
    assert_text "모아봄"

    # 탭바 표시 확인
    assert_selector "nav", visible: true
    assert_selector ".tab-item", count: 5

    # 메인 콘텐츠 padding 확인 (헤더/탭바 겹침 방지)
    main_element = page.find("main")
    assert main_element[:class].include?("pt-14"), "헤더 공간 확보"
    assert main_element[:class].include?("pb-20"), "탭바 공간 확보"
  end

  test "tablet layout (768px)" do
    # 태블릿 뷰포트 설정
    page.driver.browser.manage.window.resize_to(768, 1024)
    visit root_path

    # 기본 레이아웃 확인
    assert_selector "header", visible: true
    assert_selector "nav", visible: true

    # 사진이 있는 경우 그리드 확인
    if @family.photos.any?
      visit family_photos_path(@family)
      # 태블릿에서는 4열 그리드 (TailwindCSS: md:grid-cols-4)
      grid = page.find(".grid")
      assert grid[:class].include?("md:grid-cols-4"), "태블릿 4열 그리드"
    end
  end

  test "desktop layout (1024px+)" do
    # 데스크톱 뷰포트 설정
    page.driver.browser.manage.window.resize_to(1280, 800)
    visit root_path

    # 기본 레이아웃 확인
    assert_selector "header", visible: true
    assert_selector "nav", visible: true

    # 사진이 있는 경우 그리드 확인
    if @family.photos.any?
      visit family_photos_path(@family)
      # 데스크톱에서는 6열 그리드 (TailwindCSS: lg:grid-cols-6)
      grid = page.find(".grid")
      assert grid[:class].include?("lg:grid-cols-6"), "데스크톱 6열 그리드"
    end
  end

  test "responsive photo grid columns" do
    # 사진 3개 생성
    3.times do |i|
      photo = @family.photos.create!(
        uploader: @user,
        taken_at: Time.current,
        caption: "테스트 사진 #{i + 1}"
      )
      photo.image.attach(
        io: File.open(Rails.root.join("test/fixtures/files/photo.jpg")),
        filename: "photo_#{i + 1}.jpg",
        content_type: "image/jpeg"
      )
    end

    visit family_photos_path(@family)

    # 그리드가 올바른 클래스를 가지고 있는지 확인
    grid = page.find(".grid", match: :first)
    assert grid[:class].include?("grid-cols-3"), "모바일 기본 3열"
    assert grid[:class].include?("md:grid-cols-4"), "태블릿 4열"
    assert grid[:class].include?("lg:grid-cols-6"), "데스크톱 6열"
  end

  test "touch targets are at least 48px on mobile" do
    page.driver.browser.manage.window.resize_to(375, 667)
    visit root_path

    # 탭바 아이템 크기 확인
    tab_items = page.all(".tab-item")
    tab_items.each do |item|
      size = page.evaluate_script("
        const el = arguments[0];
        const rect = el.getBoundingClientRect();
        Math.min(rect.width, rect.height);
      ", item)

      assert size >= 48, "터치 타겟이 48px 미만: #{size}px"
    end

    # FAB 버튼 크기 확인
    fab = page.find(".w-14.h-14") # 56px (14 * 4)
    fab_size = page.evaluate_script("
      const el = arguments[0];
      const rect = el.getBoundingClientRect();
      Math.min(rect.width, rect.height);
    ", fab)

    assert fab_size >= 48, "FAB 터치 타겟이 48px 미만: #{fab_size}px"
  end

  test "content does not overflow on narrow screens" do
    # 매우 좁은 화면 테스트
    page.driver.browser.manage.window.resize_to(320, 568)
    visit root_path

    # 가로 스크롤이 없는지 확인
    body_width = page.evaluate_script("document.body.scrollWidth")
    viewport_width = page.evaluate_script("window.innerWidth")

    assert body_width <= viewport_width + 1, # +1은 브라우저 차이 허용
      "가로 스크롤 발생: body(#{body_width}px) > viewport(#{viewport_width}px)"
  end

  test "images have proper aspect ratio on all screen sizes" do
    # 사진 1개 생성
    photo = @family.photos.create!(
      uploader: @user,
      taken_at: Time.current,
      caption: "테스트"
    )
    photo.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/photo.jpg")),
      filename: "test.jpg",
      content_type: "image/jpeg"
    )

    visit family_photos_path(@family)

    # aspect-square 클래스 확인
    photo_links = page.all(".aspect-square")
    assert photo_links.any?, "aspect-square 클래스를 가진 요소가 없음"
  end

  private

  def sign_in(user)
    visit root_path
    # 실제 로그인 로직은 프로젝트에 맞게 구현
    # 여기서는 세션 직접 설정 (Rails helper 사용)
    post sessions_path, params: { user_id: user.id } if defined?(sessions_path)
  end
end
