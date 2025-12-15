# frozen_string_literal: true

require "test_helper"

class SettingsI18nTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:mom)
    post login_path, params: { user_id: @user.id }
  end

  # ========================================
  # 7.5.3 i18n 메시지 적용 테스트
  # ========================================

  test "profile page title should use i18n" do
    get settings_profile_path

    assert_response :success
    assert_select "h1", I18n.t("settings.profiles.show.title")
  end

  test "profile form labels should use i18n" do
    get settings_profile_path

    assert_response :success
    # 닉네임 레이블
    assert_select "label", I18n.t("activerecord.attributes.user.nickname")
    # 이메일 레이블
    assert_select "label", I18n.t("activerecord.attributes.user.email")
  end

  test "profile save button should use i18n" do
    get settings_profile_path

    assert_response :success
    assert_select "input[type=submit][value=?]", I18n.t("helpers.submit.save")
  end

  test "notifications page title should use i18n" do
    get settings_notifications_path

    assert_response :success
    assert_select "h1", I18n.t("settings.notifications.show.title")
  end

  test "flash message should use i18n on successful update" do
    patch settings_profile_path, params: { user: { nickname: "새닉네임" } }

    assert_redirected_to settings_profile_path
    assert_equal I18n.t("settings.profiles.update.success"), flash[:notice]
  end

  # ========================================
  # 7.5.4 뷰 레이블 i18n 테스트
  # ========================================

  test "notification labels should use i18n" do
    get settings_notifications_path

    assert_response :success
    assert_select "label", I18n.t("settings.notifications.show.notify_on_new_photo")
    assert_select "label", I18n.t("settings.notifications.show.notify_on_comment")
    assert_select "label", I18n.t("settings.notifications.show.notify_on_reaction")
  end
end
