# frozen_string_literal: true

require "application_system_test_case"

class AccessibilityTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    sign_in @user
  end

  # 12.1 색상 대비 테스트
  test "text has sufficient color contrast" do
    visit root_path

    # 주요 텍스트 색상 확인 (warm-gray-800: #292524 on cream-50: #FFFDFB)
    # 실제 대비 비율 계산은 브라우저에서는 어려우므로,
    # 클래스 사용 여부로 검증
    headings = page.all("h1, h2, h3")
    headings.each do |heading|
      assert heading[:class].include?("text-warm-gray-800") ||
             heading[:class].include?("text-white") ||
             heading[:class].include?("text-primary"),
        "제목에 충분한 대비 색상 클래스가 없음"
    end
  end

  # 12.2 터치 타겟 크기 테스트
  test "interactive elements meet minimum touch target size" do
    visit root_path

    # 탭바 아이템 크기 확인 (최소 48px)
    tab_items = page.all(".tab-item")
    tab_items.each do |item|
      height = page.evaluate_script("
        const el = arguments[0];
        const rect = el.getBoundingClientRect();
        rect.height;
      ", item)

      assert height >= 48, "탭 아이템 터치 타겟이 48px 미만: #{height}px"
    end

    # FAB 버튼 크기 확인 (56px = 14 * 4)
    fab = page.find(".w-14.h-14", match: :first)
    fab_size = page.evaluate_script("
      const el = arguments[0];
      const rect = el.getBoundingClientRect();
      Math.min(rect.width, rect.height);
    ", fab)

    assert fab_size >= 48, "FAB 버튼이 48px 미만: #{fab_size}px"
  end

  test "buttons have adequate spacing" do
    visit settings_profile_path

    buttons = page.all("button")
    if buttons.length > 1
      # 버튼 간 간격 확인 (최소 8px)
      # 실제로는 레이아웃에 따라 다르므로, gap 클래스 사용 여부로 검증
      button_containers = page.all(".flex, .grid").select { |el|
        el.all("button").length > 1
      }

      button_containers.each do |container|
        assert container[:class].match?(/gap-\d+/),
          "버튼 컨테이너에 gap 클래스가 없음"
      end
    end
  end

  # 12.4 ARIA 라벨 테스트
  test "icon-only buttons have aria-label" do
    visit root_path

    # 아이콘만 있는 버튼 찾기 (텍스트가 없는 버튼)
    icon_buttons = page.all("button").select do |btn|
      # svg만 있고 텍스트가 없는 버튼
      btn.all("svg").any? && btn.text.strip.empty?
    end

    icon_buttons.each do |btn|
      assert btn["aria-label"].present?,
        "아이콘만 있는 버튼에 aria-label이 없음: #{btn.native.to_html}"
    end
  end

  test "images have alt attribute" do
    # 사진 생성
    photo = @family.photos.create!(
      uploader: @user,
      taken_at: Time.current,
      caption: "테스트 사진"
    )
    photo.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/photo.jpg")),
      filename: "test.jpg",
      content_type: "image/jpeg"
    )

    visit family_photos_path(@family)

    # 모든 img 태그에 alt 속성이 있는지 확인
    images = page.all("img")
    images.each do |img|
      assert img["alt"].present?,
        "이미지에 alt 속성이 없음: #{img['src']}"
    end
  end

  # 12.3 포커스 상태 테스트
  test "interactive elements have visible focus state" do
    visit root_path

    # 주요 인터랙티브 요소들
    buttons = page.all("button, a.btn-primary, a.tab-item")

    buttons.first(5).each do |element|
      # 포커스 스타일 클래스 확인
      assert element[:class].include?("focus:") ||
             element[:class].include?("focus-visible:"),
        "인터랙티브 요소에 포커스 스타일이 없음: #{element[:class]}"
    end
  end

  test "focus ring is visible on form inputs" do
    visit new_family_photo_path(@family)

    # 입력 필드에 포커스
    input = page.find("textarea", match: :first)
    input.click

    # focus:ring 클래스 확인
    assert input[:class].include?("focus:ring"),
      "입력 필드에 포커스 링이 없음"
  end

  # 12.5 키보드 네비게이션 테스트
  test "can navigate with keyboard" do
    visit root_path

    # Tab 키로 이동 가능한지 확인
    page.driver.browser.action
      .send_keys(:tab)
      .send_keys(:tab)
      .perform

    # 포커스된 요소가 있는지 확인
    focused = page.evaluate_script("document.activeElement.tagName")
    assert [ "BUTTON", "A", "INPUT" ].include?(focused),
      "Tab 키로 포커스 이동 불가"
  end

  test "escape key closes modals" do
    skip "모달이 구현되면 테스트 추가"
    # 모달 열기
    # ESC 키 누르기
    # 모달이 닫혔는지 확인
  end

  # 12.6 시맨틱 HTML 테스트
  test "uses semantic HTML elements" do
    visit root_path

    # 시맨틱 요소들이 올바르게 사용되는지 확인
    assert_selector "header", count: 1
    assert_selector "main", count: 1
    assert_selector "nav", count: 1 if logged_in?

    # 제목 계층 구조 확인
    headings = page.all("h1, h2, h3, h4, h5, h6")
    assert headings.any?, "제목 요소가 없음"

    # h1이 페이지당 1개인지 확인 (선택사항)
    h1_count = page.all("h1").length
    assert h1_count <= 1, "h1이 여러 개 있음: #{h1_count}개"
  end

  # 12.7 색상만으로 정보를 전달하지 않는지 테스트
  test "does not rely solely on color for information" do
    visit root_path

    # 뱃지에 텍스트가 있는지 확인
    badges = page.all(".badge")
    badges.each do |badge|
      assert badge.text.present?,
        "뱃지에 텍스트가 없음 (색상만으로 정보 전달)"
    end
  end

  # 터치 인터랙션 테스트
  test "tap highlight is disabled for better UX" do
    visit root_path

    # tap-highlight-none 클래스 사용 확인
    tap_elements = page.all(".tap-highlight-none")
    assert tap_elements.any?,
      "터치 최적화(tap-highlight-none)가 적용되지 않음"
  end

  # Safe Area 지원 테스트 (iOS)
  test "respects safe area insets" do
    visit root_path

    # 헤더와 탭바에 safe-area 클래스가 있는지 확인
    header = page.find("header")
    assert header[:class].include?("safe-area-inset-top"),
      "헤더에 safe-area-inset-top이 없음"

    if logged_in?
      nav = page.find("nav")
      assert nav[:class].include?("safe-area-inset-bottom"),
        "탭바에 safe-area-inset-bottom이 없음"
    end
  end

  private

  def sign_in(user)
    visit root_path
    # 실제 로그인 로직은 프로젝트에 맞게 구현
    post sessions_path, params: { user_id: user.id } if defined?(sessions_path)
  end

  def logged_in?
    # 로그인 상태 확인 로직
    page.has_selector?("nav")
  end
end
