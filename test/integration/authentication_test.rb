# frozen_string_literal: true

require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "current_user is nil when not logged in" do
    get login_path

    assert_response :success
    assert_nil controller.send(:current_user)
  end

  test "current_user returns user when logged in" do
    user = users(:mom)
    post login_path, params: { user_id: user.id }

    get root_path

    assert_response :success
    assert_equal user, controller.send(:current_user)
  end

  test "logged_in? returns false when not logged in" do
    get login_path

    assert_response :success
    assert_not controller.send(:logged_in?)
  end

  test "logged_in? returns true when logged in" do
    user = users(:mom)
    post login_path, params: { user_id: user.id }

    get root_path

    assert_response :success
    assert controller.send(:logged_in?)
  end

  # Authentication filter tests
  test "unauthenticated user should be redirected to login" do
    get root_path

    assert_redirected_to login_path
    assert_equal "로그인이 필요합니다.", flash[:alert]
  end

  test "authenticated user should access protected pages" do
    user = users(:mom)
    post login_path, params: { user_id: user.id }

    get root_path

    assert_response :success
  end

  # 온보딩 완료 추적 테스트
  test "user without completed onboarding should be redirected to onboarding" do
    user = users(:incomplete_onboarding_user)
    post login_path, params: { user_id: user.id }

    get root_path

    assert_redirected_to onboarding_profile_path
    assert_equal "가족 설정이 필요합니다.", flash[:alert]
  end

  test "user with completed onboarding should access home" do
    user = users(:mom)  # mom fixture has completed onboarding
    post login_path, params: { user_id: user.id }

    get root_path

    assert_response :success
  end
end
