# frozen_string_literal: true

require "test_helper"

module Families
  class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:kim_family)
    @owner = users(:mom)
    @admin = users(:dad)
    @viewer = users(:grandma)
    @viewer_membership = family_memberships(:grandma_kim_family)
    @admin_membership = family_memberships(:dad_kim_family)
  end

  # index 테스트
  test "owner should see member list" do
    post login_path, params: { user_id: @owner.id }

    get family_members_path(@family)

    assert_response :success
    assert_select "[class*='bg-sketch-paper']" # Sketch CardComponent
  end

  test "viewer should see member list" do
    post login_path, params: { user_id: @viewer.id }

    get family_members_path(@family)

    assert_response :success
  end

  test "non-member should not access member list" do
    other_user = users(:other_family_user)
    post login_path, params: { user_id: other_user.id }

    get family_members_path(@family)

    assert_redirected_to root_path
  end

  # update 테스트 (역할 변경)
  test "owner should update member role" do
    post login_path, params: { user_id: @owner.id }

    patch family_member_path(@family, @viewer_membership),
          params: { family_membership: { role: "member" } }

    assert_redirected_to family_members_path(@family)
    assert_equal "역할이 변경되었습니다.", flash[:notice]

    @viewer_membership.reload
    assert @viewer_membership.role_member?
  end

  test "admin should update member role" do
    post login_path, params: { user_id: @admin.id }

    patch family_member_path(@family, @viewer_membership),
          params: { family_membership: { role: "member" } }

    assert_redirected_to family_members_path(@family)
    @viewer_membership.reload
    assert @viewer_membership.role_member?
  end

  test "viewer should not update member role" do
    post login_path, params: { user_id: @viewer.id }

    patch family_member_path(@family, @admin_membership),
          params: { family_membership: { role: "viewer" } }

    assert_redirected_to family_members_path(@family)
    assert_equal "권한이 없습니다.", flash[:alert]

    @admin_membership.reload
    assert @admin_membership.role_admin?
  end

  test "owner cannot change own role" do
    owner_membership = family_memberships(:mom_kim_family)
    post login_path, params: { user_id: @owner.id }

    patch family_member_path(@family, owner_membership),
          params: { family_membership: { role: "admin" } }

    assert_redirected_to family_members_path(@family)
    assert_equal "자신의 역할은 변경할 수 없습니다.", flash[:alert]

    owner_membership.reload
    assert owner_membership.role_owner?
  end

  # destroy 테스트 (구성원 내보내기)
  test "owner should remove member" do
    post login_path, params: { user_id: @owner.id }

    assert_difference "FamilyMembership.count", -1 do
      delete family_member_path(@family, @viewer_membership)
    end

    assert_redirected_to family_members_path(@family)
    assert_equal "구성원이 제거되었습니다.", flash[:notice]
  end

  test "admin should remove member" do
    post login_path, params: { user_id: @admin.id }

    assert_difference "FamilyMembership.count", -1 do
      delete family_member_path(@family, @viewer_membership)
    end

    assert_redirected_to family_members_path(@family)
  end

  test "viewer should not remove member" do
    post login_path, params: { user_id: @viewer.id }

    assert_no_difference "FamilyMembership.count" do
      delete family_member_path(@family, @admin_membership)
    end

    assert_redirected_to family_members_path(@family)
    assert_equal "권한이 없습니다.", flash[:alert]
  end

  test "owner cannot remove self" do
    owner_membership = family_memberships(:mom_kim_family)
    post login_path, params: { user_id: @owner.id }

    assert_no_difference "FamilyMembership.count" do
      delete family_member_path(@family, owner_membership)
    end

    assert_redirected_to family_members_path(@family)
    assert_equal "자신은 내보낼 수 없습니다.", flash[:alert]
  end
  end
end
