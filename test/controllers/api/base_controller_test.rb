# frozen_string_literal: true

require "test_helper"

module Api
  class BaseControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:mom)
    end

    # BaseController는 추상 클래스이므로 실제 컨트롤러로 테스트
    # SyncsController를 사용하여 BaseController의 동작 확인

    test "should reject request without Origin header" do
      sign_in @user

      get api_native_sync_url

      assert_response :forbidden
      assert_equal "forbidden", response.parsed_body["error"]["code"]
      assert_equal "Origin 헤더가 필요합니다.", response.parsed_body["error"]["message"]
    end

    test "should reject request with invalid Origin header" do
      sign_in @user

      get api_native_sync_url, headers: { "Origin" => "https://malicious-site.com" }

      assert_response :forbidden
      assert_equal "forbidden", response.parsed_body["error"]["code"]
    end

    test "should allow request with valid Origin header" do
      sign_in @user

      get api_native_sync_url, headers: { "Origin" => "capacitor://localhost" }

      assert_response :success
    end

    test "should allow request from localhost in development" do
      sign_in @user

      get api_native_sync_url, headers: { "Origin" => "http://localhost:3000" }

      assert_response :success
    end

    test "should require authentication" do
      get api_native_sync_url, headers: { "Origin" => "capacitor://localhost" }

      assert_response :unauthorized
      assert_equal "unauthorized", response.parsed_body["error"]["code"]
    end

    test "should use session-based authentication" do
      sign_in @user

      get api_native_sync_url, headers: { "Origin" => "capacitor://localhost" }

      assert_response :success
      assert_not_nil response.parsed_body["user"]
      assert_equal @user.id, response.parsed_body["user"]["id"]
    end
  end
end
