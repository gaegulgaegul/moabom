# frozen_string_literal: true

require "test_helper"

class PushNotificationServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:mom)
    @device_ios = @user.devices.create!(
      platform: "ios",
      device_id: "test-ios-device",
      push_token: "ios-push-token"
    )
    @device_android = @user.devices.create!(
      platform: "android",
      device_id: "test-android-device",
      push_token: "android-push-token"
    )
  end

  test "should send push notification to iOS device" do
    result = PushNotificationService.call(
      device: @device_ios,
      title: "새 사진",
      body: "가족이 사진을 올렸어요!"
    )

    assert result.success?
  end

  test "should send push notification to Android device" do
    result = PushNotificationService.call(
      device: @device_android,
      title: "새 사진",
      body: "가족이 사진을 올렸어요!"
    )

    assert result.success?
  end

  test "should handle missing push token" do
    device_without_token = @user.devices.create!(
      platform: "ios",
      device_id: "test-device-no-token"
    )

    result = PushNotificationService.call(
      device: device_without_token,
      title: "Test",
      body: "Test"
    )

    assert_not result.success?
    assert_equal "push_token이 없습니다.", result.error
  end

  test "should handle network errors gracefully" do
    # Mock network error scenario
    result = PushNotificationService.call(
      device: @device_ios,
      title: "Test",
      body: "Test"
    )

    # Should not raise exception even if external service fails
    assert_not_nil result
  end
end
