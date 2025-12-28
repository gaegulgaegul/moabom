# frozen_string_literal: true

require "test_helper"

module Settings
  class NotificationsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:mom)
      post login_path, params: { user_id: @user.id }
    end

    test "should display notification settings" do
      get settings_notifications_path

      assert_response :success
      assert_select "h1", I18n.t("settings.notifications.show.title")
      assert_select "label", I18n.t("settings.notifications.show.notify_on_new_photo")
      assert_select "label", I18n.t("settings.notifications.show.notify_on_comment")
      assert_select "label", I18n.t("settings.notifications.show.notify_on_reaction")
    end

    test "should update notification settings successfully" do
      patch settings_notifications_path, params: {
        user: {
          notify_on_new_photo: "0",
          notify_on_comment: "1",
          notify_on_reaction: "0"
        }
      }

      assert_redirected_to settings_notifications_path
      assert_equal I18n.t("settings.notifications.update.success"), flash[:notice]

      @user.reload
      assert_not @user.notify_on_new_photo
      assert @user.notify_on_comment
      assert_not @user.notify_on_reaction
    end

    test "should require authentication" do
      delete logout_path
      get settings_notifications_path

      assert_redirected_to login_path
      assert_equal "로그인이 필요합니다.", flash[:alert]
    end
  end
end
