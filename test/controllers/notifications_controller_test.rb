# frozen_string_literal: true

require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:mom)
    sign_in @user
  end

  test "should get index" do
    get notifications_path
    assert_response :success
  end
end
