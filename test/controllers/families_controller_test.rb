# frozen_string_literal: true

require "test_helper"

class FamiliesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:kim_family)
    @owner = users(:mom)
    @admin = users(:dad)
    @viewer = users(:grandma)
  end

  # show 테스트
  test "owner should see family info" do
    post login_path, params: { user_id: @owner.id }

    get family_path(@family)

    assert_response :success
    assert_select "h1", /#{@family.name}/
  end

  test "member should see family info" do
    post login_path, params: { user_id: @viewer.id }

    get family_path(@family)

    assert_response :success
  end

  test "non-member should not access family" do
    other_user = users(:other_family_user)
    post login_path, params: { user_id: other_user.id }

    get family_path(@family)

    assert_redirected_to root_path
    assert_equal "접근 권한이 없습니다.", flash[:alert]
  end

  test "guest should be redirected to login" do
    get family_path(@family)

    assert_redirected_to login_path
  end

  # update 테스트
  test "owner should update family name" do
    post login_path, params: { user_id: @owner.id }

    patch family_path(@family), params: { family: { name: "새 가족 이름" } }

    assert_redirected_to family_path(@family)
    assert_equal "가족 정보가 수정되었습니다.", flash[:notice]

    @family.reload
    assert_equal "새 가족 이름", @family.name
  end

  test "admin should update family name" do
    post login_path, params: { user_id: @admin.id }

    patch family_path(@family), params: { family: { name: "관리자 수정" } }

    assert_redirected_to family_path(@family)
    @family.reload
    assert_equal "관리자 수정", @family.name
  end

  test "viewer should not update family name" do
    post login_path, params: { user_id: @viewer.id }

    patch family_path(@family), params: { family: { name: "뷰어 수정 시도" } }

    assert_redirected_to family_path(@family)
    assert_equal "수정 권한이 없습니다.", flash[:alert]

    @family.reload
    assert_equal "김씨 가족", @family.name
  end

  test "update with invalid params should re-render form" do
    post login_path, params: { user_id: @owner.id }

    patch family_path(@family), params: { family: { name: "" } }

    assert_response :unprocessable_entity
  end
end
