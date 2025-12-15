# frozen_string_literal: true

require "test_helper"

class ErrorHandlingTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
  end

  # ========================================
  # 5.6.5 JSON 파싱 에러 처리 테스트
  # ========================================

  test "should return 400 for malformed JSON in API requests" do
    post login_path, params: { user_id: @user.id }

    # 잘못된 JSON을 전송
    post batch_family_photos_path(@family),
         params: "{ invalid json }",
         headers: { "CONTENT_TYPE" => "application/json" }

    assert_response :bad_request
    json = JSON.parse(response.body)
    assert json["error"].present?
    assert_equal "bad_request", json["error"]["code"]
    assert_match(/JSON|파싱|형식/, json["error"]["message"])
  end

  test "should return user-friendly message for JSON parse errors" do
    post login_path, params: { user_id: @user.id }

    # 빈 바디로 JSON 요청
    post batch_family_photos_path(@family),
         params: "",
         headers: { "CONTENT_TYPE" => "application/json" }

    # 빈 요청도 적절히 처리되어야 함
    assert_response :bad_request
  end
end
