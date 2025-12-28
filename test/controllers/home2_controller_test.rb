# frozen_string_literal: true

require "test_helper"

class Home2ControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
  end

  test "should redirect to login when not logged in" do
    get root_path
    assert_redirected_to login_path
  end

  test "should show home page when logged in" do
    sign_in @user

    get root_path
    assert_response :success
    assert_select "h1", text: /안녕하세요, #{@user.nickname}님!/
  end

  test "should show child filter" do
    sign_in @user

    get root_path
    assert_response :success
    # Story filter 영역 확인
    assert_select "[data-controller='story-filter']"
  end

  test "should show gallery cards" do
    sign_in @user

    get root_path
    assert_response :success
    # Gallery card 영역 확인
    assert_select ".gallery-card-grid"
  end

  test "should redirect to onboarding when not completed" do
    @family.update!(onboarding_completed_at: nil)
    sign_in @user

    get root_path
    assert_redirected_to onboarding_profile_path
  end

  test "should not redirect invited member to onboarding" do
    # dad is admin (non-owner)
    user = users(:dad)
    @family.update!(onboarding_completed_at: nil)
    sign_in user

    get root_path
    assert_response :success
  end

  test "should filter by child_id" do
    child = children(:baby_kim)
    sign_in @user

    get root_path, params: { child_id: child.id }
    assert_response :success
  end

  test "should show empty state when no photos" do
    @family.photos.destroy_all
    sign_in @user

    get root_path
    assert_response :success
    assert_select ".sketch-empty-state"
  end

  test "should redirect to onboarding when no family" do
    # User with no family
    user = users(:incomplete_onboarding_user)
    user.families.destroy_all
    sign_in user

    get root_path
    assert_redirected_to onboarding_profile_path
  end
end
