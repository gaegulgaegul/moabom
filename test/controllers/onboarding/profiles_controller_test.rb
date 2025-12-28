# frozen_string_literal: true

require "test_helper"

module Onboarding
  class ProfilesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:mom)
      post login_path, params: { user_id: @user.id }
    end

    test "should display profile form" do
      get onboarding_profile_path

      assert_response :success
      assert_select "form[action=?]", onboarding_profile_path
      assert_select "input[name=?]", "user[nickname]"
    end

    test "should update nickname and redirect to next step" do
      patch onboarding_profile_path, params: {
        user: { nickname: "새닉네임" }
      }

      assert_redirected_to onboarding_child_path
      @user.reload
      assert_equal "새닉네임", @user.nickname
    end

    test "should show error when nickname is blank" do
      patch onboarding_profile_path, params: {
        user: { nickname: "" }
      }

      assert_response :unprocessable_entity
      assert_select ".sketch-alert", /닉네임/
    end

    test "should require authentication" do
      delete logout_path
      get onboarding_profile_path

      assert_redirected_to root_path
    end
  end
end
