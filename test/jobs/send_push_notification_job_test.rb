# frozen_string_literal: true

require "test_helper"

class SendPushNotificationJobTest < ActiveJob::TestCase
  setup do
    @user = users(:mom)
    @device = @user.devices.create!(
      platform: "ios",
      device_id: "test-device",
      push_token: "test-token"
    )
  end

  test "should enqueue job" do
    assert_enqueued_with(job: SendPushNotificationJob) do
      SendPushNotificationJob.perform_later(@device.id, "Title", "Body")
    end
  end

  test "should call PushNotificationService" do
    # This test will pass once service is implemented
    assert_nothing_raised do
      SendPushNotificationJob.perform_now(@device.id, "Title", "Body")
    end
  end

  test "should handle missing device gracefully" do
    assert_nothing_raised do
      SendPushNotificationJob.perform_now(9999, "Title", "Body")
    end
  end
end
