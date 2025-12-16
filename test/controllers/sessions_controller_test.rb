# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should logout and redirect to root" do
    user = users(:mom)

    # Login first
    post login_path, params: { user_id: user.id }
    assert_equal user.id, session[:user_id]

    # Logout
    delete logout_path

    assert_nil session[:user_id]
    assert_redirected_to root_path
    assert_equal "로그아웃되었습니다.", flash[:notice]
  end

  test "should redirect to root when logging out without session" do
    delete logout_path

    assert_nil session[:user_id]
    assert_redirected_to root_path
  end
end
