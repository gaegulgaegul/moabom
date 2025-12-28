# frozen_string_literal: true

require "test_helper"

module Settings
  class ProfilesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:mom)
      post login_path, params: { user_id: @user.id }
    end

    test "should display profile settings" do
      get settings_profile_path

      assert_response :success
      assert_select "h1", I18n.t("settings.profiles.show.title")
      assert_select "h2", "프로필 정보"
      assert_select "input[name=?]", "user[nickname]"
    end

    test "should update nickname successfully" do
      patch settings_profile_path, params: {
        user: { nickname: "새로운닉네임" }
      }

      assert_redirected_to settings_profile_path
      assert_equal I18n.t("settings.profiles.update.success"), flash[:notice]

      @user.reload
      assert_equal "새로운닉네임", @user.nickname
    end

    test "should show error when nickname is blank" do
      patch settings_profile_path, params: {
        user: { nickname: "" }
      }

      assert_response :unprocessable_entity
      # 에러 메시지 확인 - Sketch AlertComponent
      assert_select ".sketch-alert"
      assert_select "p", /닉네임/
    end

    test "should require authentication" do
      delete logout_path
      get settings_profile_path

      assert_redirected_to login_path
      assert_equal "로그인이 필요합니다.", flash[:alert]
    end
  end
end
