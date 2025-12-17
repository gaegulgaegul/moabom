# frozen_string_literal: true

require "test_helper"

class SettingsUiTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:mom)
    post login_path, params: { user_id: @user.id }
  end

  # ========================================
  # 7.5.1 TailwindCSS 스타일링 테스트
  # ========================================

  test "profile page should have TailwindCSS styled form" do
    get settings_profile_path

    assert_response :success
    # 카드 레이아웃 확인
    assert_select "div[class*='card-solid']"
    # 폼 스타일 확인
    assert_select "form[class*='space-y']"
    # 입력 필드에 스타일 클래스
    assert_select "input[type=text][class*='input']"
  end

  test "notifications page should have TailwindCSS styled form" do
    get settings_notifications_path

    assert_response :success
    # 카드 레이아웃 확인
    assert_select "div[class*='card-solid']"
    # 토글 버튼 확인 (체크박스 대신)
    assert_select "button[data-controller='toggle']"
    # 레이블 확인
    assert_select "label"
  end

  test "profile page should have responsive layout" do
    get settings_profile_path

    assert_response :success
    # px-* 클래스로 반응형 패딩 설정 (모바일 먼저)
    assert_select "[class*='px-']"
    # 폼은 space-y로 내부 간격 설정
    assert_select "form[class*='space-y']"
  end

  test "profile page should display error messages with proper styling" do
    patch settings_profile_path, params: { user: { nickname: "!" } }

    assert_response :unprocessable_entity
    # 에러 영역 스타일 확인
    assert_select "div.alert-error"
    assert_select "div.alert-error p"
  end
end
