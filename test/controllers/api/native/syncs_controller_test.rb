# frozen_string_literal: true

require "test_helper"

class Api::Native::SyncsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:mom)
  end

  # Authentication tests
  test "should require authentication" do
    get api_native_sync_path, as: :json

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "unauthorized", json_response["error"]["code"]
  end

  # Success case
  test "should return sync data when authenticated" do
    login_as(@user)

    get api_native_sync_path, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)

    # Check structure
    assert_not_nil json_response["user"]
    assert_not_nil json_response["families"]
    assert_not_nil json_response["children"]

    # Check user data
    assert_equal @user.id, json_response["user"]["id"]
    assert_equal @user.email, json_response["user"]["email"]
    assert_equal @user.nickname, json_response["user"]["nickname"]

    # Check families data
    assert_equal @user.families.count, json_response["families"].length
    first_family = json_response["families"].first
    assert_not_nil first_family["id"]
    assert_not_nil first_family["name"]

    # Check children data
    children_count = @user.families.flat_map(&:children).count
    assert_equal children_count, json_response["children"].length
  end

  test "should include family memberships in families data" do
    login_as(@user)

    get api_native_sync_path, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)

    first_family = json_response["families"].first
    assert_not_nil first_family["members"]
    assert first_family["members"].is_a?(Array)
  end

  test "should include child details" do
    login_as(@user)

    get api_native_sync_path, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)

    return if json_response["children"].empty?

    first_child = json_response["children"].first
    assert_not_nil first_child["id"]
    assert_not_nil first_child["name"]
    assert_not_nil first_child["birthdate"]
    assert_not_nil first_child["family_id"]
  end

  private

  def login_as(user)
    post login_path, params: { user_id: user.id }
  end
end
