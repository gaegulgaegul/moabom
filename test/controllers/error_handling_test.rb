# frozen_string_literal: true

require "test_helper"

class ErrorHandlingTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
  end

  # RecordNotFound → 404 (Child 리소스로 테스트)
  test "returns 404 for non-existent child (HTML)" do
    post login_path, params: { user_id: @user.id }

    get family_child_path(@family, id: 999999)

    assert_response :not_found
  end

  test "returns 404 JSON for non-existent child" do
    post login_path, params: { user_id: @user.id }

    get family_child_path(@family, id: 999999),
        headers: { "Accept" => "application/json" }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "not_found", json["error"]["code"]
  end

  # ParameterMissing → 400
  test "returns 400 for missing required parameters (HTML)" do
    post login_path, params: { user_id: @user.id }

    patch family_path(@family), params: {}

    assert_response :bad_request
  end

  test "returns 400 JSON for missing required parameters" do
    post login_path, params: { user_id: @user.id }

    patch family_path(@family),
          params: {},
          headers: { "Accept" => "application/json" }

    assert_response :bad_request
    json = JSON.parse(response.body)
    assert_equal "bad_request", json["error"]["code"]
  end

  # HTML 응답 형식 분기
  test "404 HTML response renders error page" do
    post login_path, params: { user_id: @user.id }

    get family_child_path(@family, id: 999999)

    assert_response :not_found
    assert_select "h1", /찾을 수 없/i
  end

  test "400 HTML response renders error page" do
    post login_path, params: { user_id: @user.id }

    patch family_path(@family), params: {}

    assert_response :bad_request
    assert_select "h1", /잘못된 요청/i
  end

  # InvalidAuthenticityToken 처리
  test "handles invalid authenticity token gracefully" do
    post login_path, params: { user_id: @user.id }

    # CSRF 토큰 검증을 우회하지 않고 테스트
    ActionController::Base.allow_forgery_protection = true

    begin
      patch family_path(@family),
            params: { family: { name: "test" } },
            headers: { "X-CSRF-Token" => "invalid_token" }

      # 422 또는 302 redirect (세션 만료 시 재로그인 유도)
      assert_includes [ 422, 302 ], response.status
    ensure
      ActionController::Base.allow_forgery_protection = false
    end
  end
end
