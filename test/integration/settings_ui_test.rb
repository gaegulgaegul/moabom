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
    assert_select "form" do
      # 폼 컨테이너에 스타일 클래스
      assert_select "[class*='space-y']"
      # 입력 필드에 스타일 클래스
      assert_select "input[type=text][class*='rounded']"
      # 버튼에 스타일 클래스
      assert_select "input[type=submit][class*='bg-']"
    end
  end

  test "notifications page should have TailwindCSS styled form" do
    get settings_notifications_path

    assert_response :success
    assert_select "form" do
      # 폼 컨테이너에 스타일 클래스
      assert_select "[class*='space-y']"
      # 체크박스에 스타일 클래스
      assert_select "input[type=checkbox]"
      # 버튼에 스타일 클래스
      assert_select "input[type=submit][class*='bg-']"
    end
  end

  test "profile page should have responsive layout" do
    get settings_profile_path

    assert_response :success
    # max-w-* 클래스로 반응형 너비 제한
    assert_select "[class*='max-w-']"
  end

  test "profile page should display error messages with proper styling" do
    patch settings_profile_path, params: { user: { nickname: "!" } }

    assert_response :unprocessable_entity
    # 에러 메시지에 스타일 클래스
    assert_select "[class*='bg-red']"
  end
end
