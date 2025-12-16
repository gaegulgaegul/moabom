# frozen_string_literal: true

require "test_helper"

class ApiErrorResponseTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    post login_path, params: { user_id: @user.id }
  end

  # ========================================
  # 7.5.7 API 에러 응답 표준화 테스트
  # ========================================

  test "should return standardized error format for validation failures" do
    # 유효하지 않은 사진 업로드 시도 (taken_at 누락)
    post family_photos_path(@family),
         params: { photo: { caption: "테스트" } },
         as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)

    # 표준 에러 형식 확인
    assert json["errors"].present?
    # errors는 해시 또는 배열 형식이어야 함
    assert json["errors"].is_a?(Hash) || json["errors"].is_a?(Array)
  end

  test "should include field-specific error messages" do
    # 닉네임 유효성 검증 실패
    put settings_profile_path,
        params: { user: { nickname: "!" } },
        as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)

    assert json["errors"].present?
  end

  test "should return proper HTTP status codes for different error types" do
    # 404 - Not Found
    get family_photo_path(@family, id: 99999), as: :json
    assert_response :not_found
    json = JSON.parse(response.body)
    assert json["error"].present?

    # 400 - Bad Request (잘못된 JSON)
    post batch_family_photos_path(@family),
         params: "{ invalid }",
         headers: { "CONTENT_TYPE" => "application/json" }
    assert_response :bad_request
    json = JSON.parse(response.body)
    assert json["error"].present?
  end
end
