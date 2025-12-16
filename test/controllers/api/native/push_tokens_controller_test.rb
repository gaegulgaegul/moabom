# frozen_string_literal: true

require "test_helper"

class Api::Native::PushTokensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:mom)
  end

  # Authentication tests
  test "create should require authentication" do
    post api_native_push_tokens_path, params: valid_params, as: :json, headers: api_headers

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "unauthorized", json_response["error"]["code"]
  end

  test "destroy should require authentication" do
    delete api_native_push_token_path(id: 1), as: :json, headers: api_headers

    assert_response :unauthorized
  end

  # Create tests
  test "should create new device with push token" do
    login_as(@user)

    assert_difference("Device.count", 1) do
      post api_native_push_tokens_path, params: valid_params, as: :json, headers: api_headers
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "success", json_response["status"]
    assert_not_nil json_response["device"]
    assert_equal @user.id, json_response["device"]["user_id"]
    assert_equal "test-device-123", json_response["device"]["device_id"]
    assert_equal "ios", json_response["device"]["platform"]
  end

  test "should update existing device push token" do
    login_as(@user)

    # Create initial device
    device = @user.devices.create!(
      platform: "ios",
      device_id: "test-device-123",
      push_token: "old-token"
    )

    assert_no_difference("Device.count") do
      post api_native_push_tokens_path,
           params: valid_params.merge(push_token: "new-token"),
           as: :json,
           headers: api_headers
    end

    assert_response :created
    device.reload
    assert_equal "new-token", device.push_token
  end

  test "should handle missing required parameters" do
    login_as(@user)

    post api_native_push_tokens_path,
         params: { platform: "ios" }, # missing device_id
         as: :json,
         headers: api_headers

    assert_response :bad_request
  end

  test "should reject invalid platform" do
    login_as(@user)

    post api_native_push_tokens_path,
         params: valid_params.merge(platform: "windows"),
         as: :json,
         headers: api_headers

    assert_response :unprocessable_entity
  end

  # Destroy tests
  test "should destroy device by device_id" do
    login_as(@user)

    device = @user.devices.create!(
      platform: "ios",
      device_id: "test-device-123",
      push_token: "test-token"
    )

    assert_difference("Device.count", -1) do
      delete api_native_push_token_path(id: device.device_id), as: :json, headers: api_headers
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "success", json_response["status"]
  end

  test "should return not_found for non-existent device" do
    login_as(@user)

    delete api_native_push_token_path(id: "non-existent"), as: :json, headers: api_headers

    assert_response :not_found
  end

  test "should not allow destroying other user's device" do
    login_as(@user)
    other_user = users(:dad)

    device = other_user.devices.create!(
      platform: "ios",
      device_id: "other-device-123",
      push_token: "other-token"
    )

    assert_no_difference("Device.count") do
      delete api_native_push_token_path(id: device.device_id), as: :json, headers: api_headers
    end

    assert_response :not_found
  end

  private

  def valid_params
    {
      platform: "ios",
      device_id: "test-device-123",
      push_token: "test-push-token",
      app_version: "1.0.0",
      os_version: "17.0"
    }
  end

  def login_as(user)
    post login_path, params: { user_id: user.id }
  end
end
