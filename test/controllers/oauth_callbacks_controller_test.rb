# frozen_string_literal: true

require "test_helper"

class OauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  teardown do
    OmniAuth.config.mock_auth[:kakao] = nil
  end

  test "should create new user from kakao oauth callback" do
    OmniAuth.config.mock_auth[:kakao] = OmniAuth::AuthHash.new(
      provider: "kakao",
      uid: "new_kakao_123",
      info: {
        email: "newuser@kakao.com",
        nickname: "새사용자",
        image: "https://example.com/avatar.jpg"
      }
    )

    assert_difference("User.count", 1) do
      get "/auth/kakao/callback"
    end

    user = User.find_by(uid: "new_kakao_123")
    assert_not_nil user
    assert_equal "kakao", user.provider
    assert_equal "newuser@kakao.com", user.email
    assert_equal "새사용자", user.nickname

    assert_redirected_to root_path
    assert_equal user.id, session[:user_id]
  end

  test "should login existing user from kakao oauth callback" do
    existing_user = users(:mom)

    OmniAuth.config.mock_auth[:kakao] = OmniAuth::AuthHash.new(
      provider: existing_user.provider,
      uid: existing_user.uid,
      info: {
        email: existing_user.email,
        nickname: existing_user.nickname,
        image: "https://example.com/avatar.jpg"
      }
    )

    assert_no_difference("User.count") do
      get "/auth/kakao/callback"
    end

    assert_redirected_to root_path
    assert_equal existing_user.id, session[:user_id]
  end

  test "should handle oauth failure" do
    OmniAuth.config.mock_auth[:kakao] = :invalid_credentials

    get "/auth/kakao/callback"

    assert_redirected_to root_path
    assert_equal "로그인에 실패했습니다.", flash[:alert]
  end
end
